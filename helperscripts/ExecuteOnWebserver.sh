#!/bin/sh
######################################################################################################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : This script will connect you to your webserver(s) via ssh
######################################################################################################################################################
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

WEB_IP=""

if ( [ ! -f  ./ExecuteOnWebserver.sh ] )
then
	/bin/echo "Sorry, this script has to be run from the helperscripts subdirectory"
	exit
fi

command="${1}"

if ( [ "${command}" = "" ] )
then
	/bin/echo "Sorry, this scipt needs to be passed a command as a parameter"
	exit
fi

BUILD_HOME="`/bin/cat /home/buildhome.dat`"

/bin/echo "Which Cloudhost are you using? 1) Digital Ocean 2) Exoscale 3)Linode 4)Vultr. Please Enter the number for your cloudhost"
read response
if ( [ "${response}" = "1" ] )
then
	CLOUDHOST="digitalocean"
	token_to_match="webserver"
elif ( [ "${response}" = "2" ] )
then
	CLOUDHOST="exoscale"
	token_to_match="webserver"
elif ( [ "${response}" = "3" ] )
then
	CLOUDHOST="linode"
	token_to_match="webserver"
elif ( [ "${response}" = "4" ] )
then
	CLOUDHOST="vultr"
	token_to_match="webserver"
else
	/bin/echo "Unrecognised  cloudhost. Exiting ...."
	exit
fi

/bin/echo "What is the build Identifer for your build?"
/bin/echo "You have these builds to choose from: "

/bin/ls ${BUILD_HOME}/runtimedata/${CLOUDHOST}

/bin/echo "Please enter the name of the build of the server you wish to connect with"
read BUILD_IDENTIFIER

if ( [ -f ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/VPC-ACTIVE ] )
then
	ips="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh ${token_to_match} ${CLOUDHOST} ${BUILD_HOME}`"
else
	ips="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh ${token_to_match} ${CLOUDHOST} ${BUILD_HOME}`"
fi

if ( [ "${ips}" = "" ] )
then
	/bin/echo "There doesn't seem to be any webservers running"
	exit
fi

/bin/echo "Which webserver would you like to connect to?"
count=1
for ip in ${ips}
do
	/bin/echo "${count}:   ${ip}"
	/bin/echo "Press Y/N to connect..."
	read response
	if ( [ "${response}" = "Y" ] || [ "${response}" = "y" ] )
	then
		WEB_IP=${ip}
		break
	fi
	count="`/usr/bin/expr ${count} + 1`"
done

if ( [ "${response}" = "N" ] )
then
    exit
fi

SERVER_USERNAME="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/credentials/SERVERUSER`"
SSH_PORT="`/bin/grep SSH_PORT ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/build_environment | /bin/sed 's/"//g' | /usr/bin/awk -F'=' '{print $NF}'`"
WEBSERVER_PUBLIC_KEYS="${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/webserver_${WEB_IP}keys"

if ( [ ! -f ${WEBSERVER_PUBLIC_KEYS} ] )
then
	/usr/bin/ssh-keyscan -p ${SSH_PORT} ${WEB_IP} > ${WEBSERVER_PUBLIC_KEYS}    
else
	/bin/echo "#####################################################################################################################################################################"
	/bin/echo "Do you want to initiate a fresh ssh key scan (might be necessary if you can't connect) or  do you want to use previously generated keys"
	/bin/echo "You should always use previously generated keys unless you can't connect (an previously used ip address might have been reallocated as part of scaling or redeployment"
	/bin/echo "#####################################################################################################################################################################"
	/bin/echo "Enter 'Y' to regenerate your SSH public keys anything else to keep the keys you have got. You should only need to regenerate the keys very occassionally if at all"    
	read response
	if ( [ "${response}" = "Y" ] || [ "${response}" = "y" ] )
	then
		/usr/bin/ssh-keyscan  -p ${SSH_PORT} ${WEB_IP} > ${WEBSERVER_PUBLIC_KEYS}
	fi
fi

if ( [ "`/bin/cat ${WEBSERVER_PUBLIC_KEYS}`" = "" ] )
then
	/bin/echo "Couldn't initiate ssh key scan please try again (make sure the machine is online"
	/bin/rm ${WEBSERVER_PUBLIC_KEYS}
	exit
fi

/bin/echo "Does your server use Elliptic Curve Digital Signature Algorithm or the Rivest Shamir Adleman Algorithm for authenitcation?"
/bin/echo "If you are not sure, please try one and then the other. If you are prompted for a password, it is the wrong one"
/bin/echo "Please select (1) RSA (2) ECDSA"
read response


if ( [ "${response}" = "1" ] )
then
	/usr/bin/ssh -o ConnectTimeout=5 -o ConnectionAttempts=2 -o UserKnownHostsFile=${WEBSERVER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} -i ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/id_rsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${WEB_IP} "${command}"
	if ( [ "$?" != "0" ] )
	then
		/usr/bin/ssh -o ConnectTimeout=5 -o ConnectionAttempts=2 -o UserKnownHostsFile=${WEBSERVER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -i ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/id_rsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${WEB_IP} "${command}"
		 if ( [ "$?" != "0" ] )
		then
			/bin/echo "COMMAND FAILED ... SORRY"
		fi
	fi
elif ( [ "${response}" = "2" ] )
then
	/usr/bin/ssh -o ConnectTimeout=5 -o ConnectionAttempts=2 -o UserKnownHostsFile=${WEBSERVER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} -i ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/id_ecdsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${WEB_IP} "${command}"
	if ( [ "$?" != "0" ] )
	then
		/usr/bin/ssh -o ConnectTimeout=5 -o ConnectionAttempts=2 -o UserKnownHostsFile=${WEBSERVER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -i ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/id_ecdsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${WEB_IP} "${command}"
		if ( [ "$?" != "0" ] )
		then
			/bin/echo "COMMAND FAILED ... SORRY"
		fi
	fi
else
	/bin/echo "Unrecognised selection, please select only 1 or 2"
fi
