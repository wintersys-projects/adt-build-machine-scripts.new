#!/bin/sh
####################################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will copy a file, passed as a parameter to your selected webserver
####################################################################################################
# License Agreement:
# This file is part of The Agile Deployment Toolkit.
# The Agile Deployment Toolkit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# The Agile Deployment Toolkit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with The Agile Deployment Toolkit.  If not, see <http://www.gnu.org/licenses/>.
#######################################################################################################
#######################################################################################################
#set -x

DB_IP=""

if ( [ ! -f  ./CopyToWebserver.sh ] )
then
	/bin/echo "Sorry, this script has to be run from the helperscripts subdirectory"
	exit
fi

BUILD_HOME="`/bin/cat /home/buildhome.dat`"

sourcefile="${1}"

if ( [ "${sourcefile}" = "" ] )
then
	/bin/echo "Please tell me the full path to the location of the file you wish to copy to the Database server for example, '/tmp/file.dat'"
	read sourcefile
	while ( [ "`/bin/ls ${sourcefile}`" = "" ] )
	do
		/bin/echo "Sorry, can't find that file please tell me again"
		/bin/echo "Please tell me the full path to the location of the file you wish to copy to the Database server for example, '/tmp/file.dat'"
		read sourcefile
	done
fi

/bin/echo "Which Cloudhost are you using for this server?"
/bin/echo "(1) Digital Ocean (2) Exoscale (3) Linode (4) Vultr"
read response

if ( [ "${response}" = "1" ] )
then
	CLOUDHOST="digitalocean"
	token_to_match="*database*"
elif ( [ "${response}" = "2" ] )
then
	CLOUDHOST="exoscale"
	token_to_match="database"
elif ( [ "${response}" = "3" ] )
then
	CLOUDHOST="linode"
	token_to_match="database"
elif ( [ "${response}" = "4" ] )
then
	CLOUDHOST="vultr"
	token_to_match="database"
fi

/bin/echo "What is the build identifier you want to connect to?"
/bin/echo "You have these builds to choose from: "
/bin/ls ${BUILD_HOME}/buildconfiguration/${CLOUDHOST} | /bin/grep -v credentials
/bin/echo "Please enter the name of the build of the server you wish to connect with"
read BUILD_IDENTIFIER

if ( [ -f ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/VPC-ACTIVE ] )
then
	ips="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh ${token_to_match} ${CLOUDHOST} ${BUILD_HOME}`"
else
	ips="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh ${token_to_match} ${CLOUDHOST} ${BUILD_HOME}`"
fi

if ( [ "${ips}" = "" ] )
then
	/bin/echo "There doesn't seem to be any databases running"
	exit
fi

/bin/echo "Which database would you like to connect to?"
count=1
for ip in ${ips}
do
	/bin/echo "${count}:   ${ip}"
	/bin/echo "Press Y/N to connect..."
	read response
	if ( [ "${response}" = "Y" ] || [ "${response}" = "y" ] )
	then
		DB_IP=${ip}
		break
	fi
	count="`/usr/bin/expr ${count} + 1`"
done

if ( [ "${response}" = "N" ] )
then
    exit
fi

SSH_PORT="`/bin/grep SSH_PORT ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER} | /bin/sed 's/"//g' | /usr/bin/awk -F'=' '{print $NF}'`"
SERVER_USER="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/SERVERUSER`"

DATABASE_PUBLIC_KEYS="${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/database_${DB_IP}-keys"

if ( [ ! -f ${DATABASE_PUBLIC_KEYS} ] )
then
	/usr/bin/ssh-keyscan  -p ${SSH_PORT} ${DB_IP} > ${DATABASE_PUBLIC_KEYS}    
else
	/bin/echo "#####################################################################################################################################################################"
	/bin/echo "Do you want to initiate a fresh ssh key scan (might be necessary if you can't connect) or  do you want to use previously generated keys"
	/bin/echo "You should always use previously generated keys unless you can't connect (an previously used ip address might have been reallocated as part of scaling or redeployment"
	/bin/echo "#####################################################################################################################################################################"
	/bin/echo "Enter 'Y' to regenerate your SSH public keys anything else to keep the keys you have got. You should only need to regenerate the keys very occassionally if at all"    
	read response
	if ( [ "${response}" = "Y" ] || [ "${response}" = "y" ] )
	then
		/usr/bin/ssh-keyscan  -p ${SSH_PORT} ${DB_IP} > ${DATABASE_PUBLIC_KEYS}
	fi
fi

if ( [ "`/bin/cat ${DATABASE_PUBLIC_KEYS}`" = "" ] )
then
	/bin/echo "Couldn't initiate ssh key scan please try again (make sure the machine is online"
	/bin/rm ${DATABASE_PUBLIC_KEYS}
	exit
fi

/bin/echo "Does your server use Elliptic Curve Digital Signature Algorithm or the Rivest Shamir Adleman Algorithm for authenitcation?"
/bin/echo "If you are not sure, please try one and then the other. If you are prompted for a password, it is the wrong one"
/bin/echo "Please select (1) RSA (2) ECDSA"
read response

/bin/echo "Please enter the full path to the directory you would like to copy the file to on the remove machine"
read remotedir

if ( [ "${response}" = "1" ] )
then
	/usr/bin/scp -o ConnectTimeout=5 -o ConnectionAttempts=2 -o UserKnownHostsFile=${DATABASE_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -P ${SSH_PORT} -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_rsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${sourcefile} ${SERVER_USER}@${DB_IP}:${remotedir}
	if ( [ "$?" != "0" ] )
	then
		/usr/bin/scp -o ConnectTimeout=5 -o ConnectionAttempts=2 -o UserKnownHostsFile=${DATABASE_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_rsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${sourcefile} ${SERVER_USER}@${DB_IP}:${remotedir}
	fi
elif ( [ "${response}" = "2" ] )
then
	/usr/bin/scp -o ConnectTimeout=5 -o ConnectionAttempts=2 -o UserKnownHostsFile=${DATABASE_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -P ${SSH_PORT} -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_ecdsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${sourcefile} ${SERVER_USER}@${DB_IP}:${remotedir}
	if ( [ "$?" != "0" ] )
	then
		/usr/bin/scp -o ConnectTimeout=5 -o ConnectionAttempts=2 -o UserKnownHostsFile=${DATABASE_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_ecdsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${sourcefile} ${SERVER_USER}@${DB_IP}:${remotedir}
	fi
else
	/bin/echo "Unrecognised selection, please select only 1 or 2"
fi
