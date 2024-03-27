#!/usr/bin/env bash

# Import the auxiliary functions
source ./utils/auxiliary_functions.sh

validate_env_variables

# Start Tomcat
catalina.sh start

# Wait for Tomcat to start
check_tomcat_started

./amster/amster <<< "install-openam --serverUrl http://${AM_HOSTNAME}:${AM_REMOTE_PORT}/${AM_REMOTE_FILENAME} --adminPwd ${AM_ADMIN_PASSWORD} --acceptLicense"

# Here we should run the change_session_cookie_name.sh script so that we change the initial name of the user session cookie
./change_session_cookie_name.sh 

# Wait for Tomcat to successfully restart
check_tomcat_started

# Here we should run the create_authentication_tree_script script so that it creates an authentication tree in the OpenAM server
./create_authentication_tree_script.sh

tail -f $CATALINA_HOME/logs/catalina.out
