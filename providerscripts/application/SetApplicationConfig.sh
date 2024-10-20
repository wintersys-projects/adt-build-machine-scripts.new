    	. ${BUILD_HOME}/providerscripts/application/${APPLICATION}/SetApplicationConfig.sh

	if ( [ -f ${BUILD_HOME}runtimedata/linode/DBaaS_HOSTNAME ] )
 	then
  		DB_HOSTNAME="`/bin/cat ${BUILD_HOME}runtimedata/${CLOUDHOST}/DBaaS_HOSTNAME`"
    	fi

     	if ( [ "${DB_HOSTNAME}" = "" ] )
      	then
      		if ( [ "${DBIP_PRIVATE}" = "" ] )
  		then
     			DBIP_PRIVATE="`/bin/ls ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/DBPRIVATEIP:* | /usr/bin/awk -F':' '{print $NF}'`"
		fi
 
		if ( [ "${DBIP}" = "" ] )
  		then
     			DBIP="`/bin/ls ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/DBIP:* | /usr/bin/awk -F':' '{print $NF}'`"
		fi
  	fi

   	. ${BUILD_HOME}/providerscripts/datastore/configwrapper/ObtainCredentials.sh

    	. ${BUILD_HOME}/providerscripts/application/${APPLICATION}/SetApplicationConfig.sh

