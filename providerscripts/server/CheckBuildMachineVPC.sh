

BUILD_HOME="`/bin/cat /home/buildhome.dat`"

cloudhost="${1}"
server_name="${2}"

if ( [ "${cloudhost}" = "vultr" ] )
then
  if ( [ "`/usr/bin/vultr instance list -o json | /usr/bin/jq -r '.instances[] | select (.label == "'${server_name}'").id'`" = "" ] )
  then
    status "It looks like the build machine (${server_name}) is not attached to a VPC when BUILD_MACHINE_VPC=1"
    status "Will have to exit (change BUILD_MACHINE_VPC if necessary)"
    exit
  fi
fi
