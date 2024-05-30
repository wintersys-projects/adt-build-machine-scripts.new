**HARDCORE BUILD PROCESS**

1. On your laptop perform the following command:  

>     git clone https://github.com/wintersys-projects/adt-build-machine-scripts.git

We need several pieces of information from our cloud host and 3rd party services for a successful build to be possible:

I am going to use the example of joomla to build from and so this example will build a virgin installation of the latest version of joomla

This tutorial will deploy the latest version of Joomla using template 1 which you can read about here with the clone you have just made onto your laptop:  

>     ./adt-build-machine-scripts/templatedconfigurations/templates/exoscale/exoscale1.description and the hardcore method.

---------------------------------------

To find the latest version of Joomla, I go to this URL in my browser:

[Joomla Latest](https://downloads.joomla.org/)

And I note the latest version in a separate text file:

>     joomla_version="4.0.4"  

You can of course use a legacy version of joomla also by choosing a different version numnber. 

-------------------------------------

I then need a set of compute access keys so, I go to the IAM option on my exoscale dashboard and generate an IAM key with compute access. In my separate text file, I record:

>     exoscale_access_key_compute="XXXXX"  where XXXXX and YYYYY are the actual values generated when I click "Add Key"
>     exoscale_secret_key_compute="YYYYY"

I then need a set of Object Storage (S3) access keys so, I go to the IAM option on my exoscale dashboard and generate an IAM key with S3 access. In my separate text file, I record:

>     exoscale_access_key_s3="AAAAA"  where AAAAA and BBBBB are the actual values generated when I click "Add Key"
>     exoscale_secret_key_s3="BBBBB"


I then need a set of DNS access keys so, I go to the IAM option on my exoscale dashboard and generate an IAM key with DNS access. In my separate text file, I record:

>     exoscale_access_key_dns="CCCCC"  where CCCCC and DDDDD are the actual values generated when I click "Add Key"
>     exoscale_secret_key_dns="DDDDD"

**NOTE:** Alternatively you could generate one set of IAM keys and give that one set all three permissions, Compute, DNS and S3. You wouldn't have to juggle three set of keys then and could use the same key pair in all three cases.

-----------------------------------

You now need to make a note of the email address that you have registered with your exoscale account:

>     exoscale_email="testemail@testemail.com"

-----------------------------------

You then need the url that you want to use for your website. If you don't have a DNS URL for your website, you need to purchase one and set the nameservers to exoscale as described in ./adt-build-machine-scripts/blob/master/doco/AgileToolkitDeployment/Nameservers.md

>     exoscale_dns_name="www.testsocialnetwork.org.uk"

-------------------------------

You then need the username and owner of you git provider application repositories.
To do this, if you don't have a git account sign up with one (in this case using github, but, you have the choice of bitbucket and gitlab as well) and record the username that you sign up with:

>     gitusername="mytestgituser"

Then create a "personal access token" by following: 

[Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) making sure you give it all "repo" permissions as well as the "delete repository" permission

>     gitpersonalaccesstoken="KKKKK" where KKKKK represents your actual personal access token

--------------------------------

To keep this as simple as possible, I have missed out the SMTP credentials, but, you can find out more about them ./wintersys-projects/adt-build-machine-scripts/blob/master/doco/AgileToolkitDeployment/DeployingSMTPService.md. If you wish to include SMTP credentials you will need to have a service offering set up with either sendpulse, mailjet or AWS SES.

So, that should be all the core credentials that I need to make a deployment. I can save my text file now (and keep it secure) because I might want to use these credentials again for other deployments or redeployments. 

--------------------------------------------
--------------------------------------------

So, to begin an hardcore build process, I need to:

>     vi ./adt-build-machine-scripts/templatedconfigurations/templates/exoscale/exoscale1.tmpl

This file looks like this (I have put a dashes before each line I wish to modify for this deployment which is for illustrative purposes only):

>     ###############################################################################################  
>     # Refer to: ${BUILD_HOME}/templatedconfigurations/specification.md  
>     ###############################################################################################  
>     ------export APPLICATION=""  
>     export JOOMLA_VERSION="" #MANDATORY - change this to the version you want to deploy, for example 4.0.3 set it to "" if you are deploying anything but joomla  
>     export DRUPAL_VERSION=""  #MANDATORY - change this to the version you want to deploy, for example, 9.2.6 set it to "" if you are deploying anything but drupal  
>     ------export APPLICATION_BASELINE_SOURCECODE_REPOSITORY="" #MANDATORY  
>     #^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  
>     # change this to, for example, JOOMLA:4.0.3 if you are deploying drupal (APPLICATION=joomla)  
>     # change this to, WORDPRESS if you are deploying wordpress  
>     # change this to, for example, DRUPAL:9.2.6 if you are deploying drupal (APPLICATION=drupal)  
>     # change this to, MOODLE if you are deploying moodle  
>     #############################################################################################  
>     ------export S3_ACCESS_KEY=""  #MANDATORY  
>     ------export S3_SECRET_KEY=""  #MANDATORY  
>     export S3_HOST_BASE="sos-ch-gva-2.exo.io" #MANDATORY  
>     export S3_LOCATION="US" #For exoscale, this always needs to be set to "US"  
>     export TOKEN="" #NOT REQUIRED  
>     ------export ACCESS_KEY=""   #MANDATORY  
>     ------export SECRET_KEY=""   #MANDATORY  
>     ------export DNS_USERNAME=""  #MANDATORY  
>     ------export DNS_SECURITY_KEY=""   #MANDATORY - This is your access key and your secret key, written: DNS_SECURITY_KEY="${ACCESS_KEY}:${SECRET_KEY}"  
>     export DNS_CHOICE="exoscale" #MANDATORY - you will need to set your DNS nameservers according to this choice  
>     ------export CLOUDHOST_EMAIL_ADDRESS="" #MANDATORY  
>     export BUILDOS="debian" #MANDATORY one of ubuntu|debian  
>     export BUILDOS_VERSION="11" #MANDATORY one of 20.04|10 11  
>     export DEFAULT_USER="debian" #MANDATORY - - This must be "ubuntu" if you are deploying ubuntu and "debian" if you are deploying debian  
>     ------export WEBSITE_DISPLAY_NAME="" #MANDATORY  
>   
>     ------export WEBSITE_NAME="" #MANDATORY - This is the exact value of the core of your WEBSITE_URL, for example, www.nuocial.org.uk would be nuocial
>     ------export WEBSITE_URL=""  #MANDATORY
>     export APPLICATION_REPOSITORY_PROVIDER="github" #MANDATORY
>     ------export APPLICATION_REPOSITORY_OWNER="" #MANDATORY
>     ------export APPLICATION_REPOSITORY_USERNAME="" #MANDATORY
>     export APPLICATION_REPOSITORY_PASSWORD="" #MANDATORY
>     ------export APPLICATION_REPOSITORY_TOKEN="" #MANDATORY
>     export SYSTEM_EMAIL_PROVIDER="" #MANDATORY
>     export SYSTEM_TOEMAIL_ADDRESS="" #MANDATORY
>     export SYSTEM_FROMEMAIL_ADDRESS="" #MANDATORY
>     export SYSTEM_EMAIL_USERNAME="" #MANDATORY
>     export SYSTEM_EMAIL_PASSWORD="" #MANDATORY
>     export DIRECTORIES_TO_MOUNT="" #This should always be unset for a virgin deployments
>     export DB_PORT="2035"
>     export SSH_PORT="1035"
>     export GATEWAY_GUARDIAN="0"
>     export PRODUCTION="0"
>     export DEVELOPMENT="1"
>     export BUILD_CHOICE="0"
>     ------export WEBSERVER_CHOICE="APACHE"
>     export NO_AUTOSCALERS="1"
>     export NUMBER_WS="1"
>     export SUPERSAFE_WEBROOT="1"
>     export SUPERSAFE_DB="1"
>     ------export DATABASE_INSTALLATION_TYPE="MySQL"
>     export PERSIST_ASSETS_TO_CLOUD="0" #This should always be set to 0 for a virgin deployment
>     export DISABLE_HOURLY="0"
>     export SERVER_TIMEZONE_CONTINENT="Europe"
>     export SERVER_TIMEZONE_CITY="London"
>     export BASELINE_DB_REPOSITORY="VIRGIN"
>     export BUILD_ARCHIVE_CHOICE="virgin"
>     export APPLICATION_LANGUAGE="PHP"
>     ------export APPLICATION_IDENTIFIER="3"
>     ------export PHP_VERSION="7.4"
>     export REGION=""
>     export REGION_ID="1128bd56-b4d9-4ac6-a7b9-c715b187ce11"
>     export DB_SIZE="10G"
>     export DB_SERVER_TYPE="b6cd1ff5-3a2f-4e9d-a4d1-8988c1191fe8"
>     export WS_SIZE="10G"
>     export WS_SERVER_TYPE="b6cd1ff5-3a2f-4e9d-a4d1-8988c1191fe8"
>     export AS_SIZE="10G"
>     export AS_SERVER_TYPE="b6cd1ff5-3a2f-4e9d-a4d1-8988c1191fe8"
>     export CLOUDHOST="exoscale"
>     export MACHINE_TYPE="EXOSCALE"
>     export ALGORITHM="rsa"
>     export USER="root"
>     export CLOUDHOST_USERNAME="root"
>     export CLOUDHOST_PASSWORD=""
>     export PUBLIC_KEY_NAME="AGILE_TOOLKIT_PUBLIC_KEY"
>     export PREVIOUS_BUILD_CONFIG="0"
>     export GIT_USER="Templated User"
>     export GIT_EMAIL_ADDRESS="templateduser@dummyemailZ123.com"
>     export INFRASTRUCTURE_REPOSITORY_PROVIDER="github"
>     export INFRASTRUCTURE_REPOSITORY_OWNER="wintersys-projects"
>     export INFRASTRUCTURE_REPOSITORY_USERNAME="wintersys-projects"
>     export INFRASTRUCTURE_REPOSITORY_PASSWORD="none"
>     export DATASTORE_CHOICE="exoscale"
>     export SSL_GENERATION_METHOD="AUTOMATIC"
>     export SSL_GENERATION_SERVICE="LETSENCRYPT"
>     export BYPASS_DB_LAYER="0"
>     export DBaaS_HOSTNAME=""
>     export DBaaS_USERNAME=""
>     export DBaaS_PASSWORD=""
>     export DBaaS_DBNAME=""
>     export DATABASE_DBaaS_INSTALLATION_TYPE=""
>     export DBaaSDBSECURITYGROUP=""
>     export DBIP=""
>     export DBIP_PRIVATE=""
>     export WSIP=""
>     export WSIP_PRIVATE=""
>     export ASIP=""
>     export ASIP_PRIVATE=""
>     export APPLICATION_NAME=""
>     export MAPS_API_KEY=""
>     export PHP_MODE=""
>     export PHP_MAX_CHILDREN=""
>     export PHP_START_SERVERS=""
>     export PHP_MIN_SPARE_SERVERS=""
>     export PHP_MAX_SPARE_SERVERS=""
>     export PHP_PROCESS_IDLE_TIMEOUT=""
>     export IN_MEMORY_CACHING=""
>     export IN_MEMORY_CACHING_PORT=""
>     export IN_MEMORY_CACHING_HOST=""
>     export IN_MEMORY_CACHING_SECURITY_GROUP=""
>     export ENABLE_EFS=""
>     export SUBNET_ID=""
>     export AUTOSCALE_FROM_SNAPSHOTS=""
>     export GENERATE_SNAPSHOTS=""
>     export SNAPSHOT_ID=""
>     export WEBSERVER_IMAGE_ID=""
>     export AUTOSCALER_IMAGE_ID=""
>     export DATABASE_IMAGE_ID=""
>     export BUILD_HOME="/home/wintersys-projects/adt-build-machine-scripts"
>     export BUILD_CLIENT_IP="185.19.29.134"
>     export BUILD_IDENTIFIER="nuocial"
>     export PUBLIC_KEY_ID="AGILE_TOOLKIT_PUBLIC_KEY-nuocial"

So, I have referred to the specification and I have freely chosen to modify the  

**WEBSERVER_CHOICE to "NGINX"**  
**PHP_VERSION to "8.0"**  
**APPLICATION_IDENTIFIER to "1"**  
**DATABASE_INSTALLATION_TYPE to "Postgres"**  

So, editing  

>     vi ./adt-build-machine-scripts/templatedconfigurations/templates/exoscale/exoscale1.tmpl   

and using the values I recorded in my text file earlier, I modify the file as follows, the lines beginning with dashes have been modified


>     ###############################################################################################
>     # Refer to: ${BUILD_HOME}/templatedconfigurations/specification.md
>     ###############################################################################################
>     ------export APPLICATION="joomla"
>     ------export JOOMLA_VERSION="4.0.4" #MANDATORY - change this to the version you want to deploy, for example 4.0.3 set it to "" if you are deploying anything but joomla
>     export DRUPAL_VERSION=""  #MANDATORY - change this to the version you want to deploy, for example, 9.2.6 set it to "" if you are deploying anything but drupal
>     -------export APPLICATION_BASELINE_SOURCECODE_REPOSITORY="JOOMLA:4.0.4" #MANDATORY 
>     #^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>     # change this to, for example, JOOMLA:4.0.3 if you are deploying drupal (APPLICATION=joomla)
>     # change this to, WORDPRESS if you are deploying wordpress
>     # change this to, for example, DRUPAL:9.2.6 if you are deploying drupal (APPLICATION=drupal)
>     # change this to, MOODLE if you are deploying moodle
>     #############################################################################################
>     ------export S3_ACCESS_KEY="AAAAA"  #MANDATORY
>     ------export S3_SECRET_KEY="BBBBB"  #MANDATORY
>     export S3_HOST_BASE="sos-ch-gva-2.exo.io" #MANDATORY
>     export S3_LOCATION="US" #For exoscale, this always needs to be set to "US"
>     export TOKEN="" #NOT REQUIRED
>     ------export ACCESS_KEY="XXXXX"   #MANDATORY
>     ------export SECRET_KEY="YYYYY"   #MANDATORY
>     ------export DNS_USERNAME="testemail@testemail.com"  #MANDATORY
>     ------export DNS_SECURITY_KEY="CCCCC:DDDDD"   #MANDATORY - This is your access key and your secret key, written: DNS_SECURITY_KEY="${ACCESS_KEY}:${SECRET_KEY}"
>     export DNS_CHOICE="exoscale" #MANDATORY - you will need to set your DNS nameservers according to this choice
>     ------export CLOUDHOST_EMAIL_ADDRESS="testemail@testemail.com" #MANDATORY
>     export BUILDOS="debian" #MANDATORY one of ubuntu|debian
>     export BUILDOS_VERSION="11" #MANDATORY one of 20.04|10 11
>     export DEFAULT_USER="debian" #MANDATORY - - This must be "ubuntu" if you are deploying ubuntu and "debian" if you are deploying debian
>     ------export WEBSITE_DISPLAY_NAME="Test Social Network" #MANDATORY
>     ------export WEBSITE_NAME="testsocialnetwork" #MANDATORY - This is the exact value of the core of your WEBSITE_URL, for example, www.nuocial.org.uk would be nuocial
>     ------export WEBSITE_URL="www.testsocialnetwork.org.uk"  #MANDATORY
>     export APPLICATION_REPOSITORY_PROVIDER="github" #MANDATORY
>     ------export APPLICATION_REPOSITORY_OWNER="mytestgituser" #MANDATORY
>     ------export APPLICATION_REPOSITORY_USERNAME="mytestgituser" #MANDATORY
>     export APPLICATION_REPOSITORY_PASSWORD="" #MANDATORY
>     ------export APPLICATION_REPOSITORY_TOKEN="KKKKK" #MANDATORY
>     export SYSTEM_EMAIL_PROVIDER="" #MANDATORY
>     export SYSTEM_TOEMAIL_ADDRESS="" #MANDATORY
>     export SYSTEM_FROMEMAIL_ADDRESS="" #MANDATORY
>     export SYSTEM_EMAIL_USERNAME="" #MANDATORY
>     export SYSTEM_EMAIL_PASSWORD="" #MANDATORY
>     export DIRECTORIES_TO_MOUNT="" #This should always be unset for a virgin deployments
>     export DB_PORT="2035"
>     export SSH_PORT="1035"
>     export GATEWAY_GUARDIAN="0"
>     export PRODUCTION="0"
>     export DEVELOPMENT="1"
>     export BUILD_CHOICE="0"
>     ------export WEBSERVER_CHOICE="NGINX"
>     export NO_AUTOSCALERS="1"
>     export NUMBER_WS="1"
>     export SUPERSAFE_WEBROOT="1"
>     export SUPERSAFE_DB="1"
>     ------export DATABASE_INSTALLATION_TYPE="Postgres"
>     export PERSIST_ASSETS_TO_CLOUD="0" #This should always be set to 0 for a virgin deployment
>     export DISABLE_HOURLY="0"
>     export SERVER_TIMEZONE_CONTINENT="Europe"
>     export SERVER_TIMEZONE_CITY="London"
>     export BASELINE_DB_REPOSITORY="VIRGIN"
>     export BUILD_ARCHIVE_CHOICE="virgin"
>     export APPLICATION_LANGUAGE="PHP"
>     ------export APPLICATION_IDENTIFIER="1"**
>     ------export PHP_VERSION="8.0"**
>     export REGION=""
>     export REGION_ID="1128bd56-b4d9-4ac6-a7b9-c715b187ce11"
>     export DB_SIZE="10G"
>     export DB_SERVER_TYPE="b6cd1ff5-3a2f-4e9d-a4d1-8988c1191fe8"
>     export WS_SIZE="10G"
>     export WS_SERVER_TYPE="b6cd1ff5-3a2f-4e9d-a4d1-8988c1191fe8"
>     export AS_SIZE="10G"
>     export AS_SERVER_TYPE="b6cd1ff5-3a2f-4e9d-a4d1-8988c1191fe8"
>     export CLOUDHOST="exoscale"
>     export MACHINE_TYPE="EXOSCALE"
>     export ALGORITHM="rsa"
>     export USER="root"
>     export CLOUDHOST_USERNAME="root"
>     export CLOUDHOST_PASSWORD=""
>     export PUBLIC_KEY_NAME="AGILE_TOOLKIT_PUBLIC_KEY"
>     export PREVIOUS_BUILD_CONFIG="0"
>     export GIT_USER="Templated User"
>     export GIT_EMAIL_ADDRESS="templateduser@dummyemailZ123.com"
>     export INFRASTRUCTURE_REPOSITORY_PROVIDER="github"
>     export INFRASTRUCTURE_REPOSITORY_OWNER="wintersys-projects"
>     export INFRASTRUCTURE_REPOSITORY_USERNAME="wintersys-projects"
>     export INFRASTRUCTURE_REPOSITORY_PASSWORD="none"
>     export DATASTORE_CHOICE="exoscale"
>     export SSL_GENERATION_METHOD="AUTOMATIC"
>     export SSL_GENERATION_SERVICE="LETSENCRYPT"
>     export BYPASS_DB_LAYER="0"
>     export DBaaS_HOSTNAME=""
>     export DBaaS_USERNAME=""
>     export DBaaS_PASSWORD=""
>     export DBaaS_DBNAME=""
>     export DATABASE_DBaaS_INSTALLATION_TYPE=""
>     export DBaaSDBSECURITYGROUP=""
>     export DBIP=""
>     export DBIP_PRIVATE=""
>     export WSIP=""
>     export WSIP_PRIVATE=""
>     export ASIP=""
>     export ASIP_PRIVATE=""
>     export APPLICATION_NAME=""
>     export MAPS_API_KEY=""
>     export PHP_MODE=""
>     export PHP_MAX_CHILDREN=""
>     export PHP_START_SERVERS=""
>     export PHP_MIN_SPARE_SERVERS=""
>     export PHP_MAX_SPARE_SERVERS=""
>     export PHP_PROCESS_IDLE_TIMEOUT=""
>     export IN_MEMORY_CACHING=""
>     export IN_MEMORY_CACHING_PORT=""
>     export IN_MEMORY_CACHING_HOST=""
>     export IN_MEMORY_CACHING_SECURITY_GROUP=""
>     export ENABLE_EFS=""
>     export SUBNET_ID=""
>     export AUTOSCALE_FROM_SNAPSHOTS=""
>     export GENERATE_SNAPSHOTS=""
>     export SNAPSHOT_ID=""
>     export WEBSERVER_IMAGE_ID=""
>     export AUTOSCALER_IMAGE_ID=""
>     export DATABASE_IMAGE_ID=""
>     export BUILD_HOME="/home/wintersys-projects/adt-build-machine-scripts"
>     export BUILD_CLIENT_IP="185.19.29.134"
>     export BUILD_IDENTIFIER="nuocial"
>     export PUBLIC_KEY_ID="AGILE_TOOLKIT_PUBLIC_KEY-nuocial"

If all the dashes I have added are removed, then this file (with live values and not symbolic ones) would be ready for deployment.  

You now need to copy your template as follows:  

>     /bin/mkdir ./adt-build-machine-scripts/overridescripts/
>     /bin/cp ./adt-build-machine-scripts/templatedconfigurations/templates/exoscale/exoscale1.tmpl ./adt-build-machine-scripts/overridescripts/exoscale1override.tmpl  

Then you need to run the script:

>     cd helperscripts

>     ./GenerateHardcoreUserDataScript.sh

This will leave you with a script:

>    ../userdatascripts/${userdatascript}   

where ${userdatascript} is the descriptive name you gave when prompted.  

It is mandatory to edit your userdata script and modify these values within it to your liking:

>     export BUILDMACHINE_USER="agile-user"
>     export BUILDMACHINE_PASSWORD="Hjdhfb34hd£" #Make sure any password you choose is strong enough to pass any strength enforcement rules of your OS
>     export BUILDMACHINE_SSH_PORT="1035"
>     export LAPTOP_IP="111.111.111.111"

>     export SSH=\"\" #paste your public key here

------------------------------------------

Now you have your userdata script take a copy of the entirity of it using copy and paste and then follow [these](./buildmachine-hardcore.md) instructions PASTING THE SCRIPT YOU HAVE JUST COPIED INTO THE USERDATA AREA OF YOUR EXOSCALE MACHINE INSTEAD OF THE MODIFIED TEMPLATE. The build machine will then install **AND**  run the agile deployment toolkit. This is just an alternative method to the expedited build process which you may or may not perfer.


At this point, your build machine should be up and running. Please review  
  
[Tighten Build Machine](../../../doco/AgileToolkitDeployment/TightenBuildMachineAccess.md)  
At this point, your build machine will only accept connections from your laptop. If you need access from other ip addresses you need to use the technique described in "Tightening Build Machine Access" to grant access to additional IP addresses. This will be the case every time your laptop changes its IP address as you travel about, so, you might want to setup and configure an S3 client on your laptop to enable you to grant access to new IP addresses easily. 


---------------------------

Assuming that you have your Joomla application online now after following that video, what I would do if I wanted to build a Wordpress, Moodle or Drupal installation would be to follow the same procedure with the same template, but, minimally change the template as follows:

#### For Wordpress:

>     export APPLICATION="wordpress"
>     export APPLICATION_BASELINE_SOURCECODE_REPOSITORY="WORDPRESS" #MANDATORY 
>     export APPLICATION_IDENTIFIER="2"
>     export DATABASE_INSTALLATION_TYPE="MySQL" #I don't support Wordpress using Postgres

#### For Drupal:

>     export APPLICATION="drupal"
>     export DRUPAL_VERSION="9.2.6" 
>     export APPLICATION_BASELINE_SOURCECODE_REPOSITORY="DRUPAL:9.2.6" #MANDATORY 
>     export APPLICATION_IDENTIFIER="3"

#### For Moodle:

>     export APPLICATION="moodle"
>     export APPLICATION_BASELINE_SOURCECODE_REPOSITORY="MOODLE" #MANDATORY 
>     export APPLICATION_IDENTIFIER="4"

So, you have a template now that you can use over and over again for deploying different installations of these CMS systems. You can study the spec and learn how to modify the template in order to change machine sizes, regions, PHP settings and so on. 
