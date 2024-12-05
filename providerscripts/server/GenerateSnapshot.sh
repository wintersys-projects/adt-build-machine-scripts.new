cloudhost="${1}"
machine_name="${2}"
default_user="${3}"


BUILD_HOME="`/bin/cat /home/buildhome.dat`"
BUILD_IDENTIFIER="`${BUILD_HOME}/runtimedata/ACTIVE_BUILD_IDENTIFIER`"

if ( [ "${cloudhost}" = "exoscale" ] )
then
  REGION_ID="`/bin/cat ${BUILD_HOME}/runtimedata/${cloudhost}/${BUILD_IDENTIFIER}/CURRENTREGION`"
  machine_id="`${BUILD_HOME}/providerscripts/server/ListServerIDs.sh ${machine_name} ${cloudhost}`"  
  /usr/bin/exo compute instance snapshot create -z ${REGION_ID} ${machine_id}
  snapshot_id="`/usr/bin/exo -O json  compute instance snapshot list  | /usr/bin/jq -r '.[] | select (.instance == "'${machine_name}'") | select (.zone == "'${REGION_ID}'").id'`"
  /usr/bin/exo compute instance-template register --boot-mode legacy --disable-password --from-snapshot ${snapshot_id} --zone ${REGION_ID} --username ${default_user} ${machine_name}
fi
