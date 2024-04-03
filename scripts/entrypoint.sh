#!/usr/bin/env bash

# Import the auxiliary functions
source ./utils/auxiliary_functions.sh

validate_env_variables

# Start Tomcat
catalina.sh start

# Wait for Tomcat to start
check_tomcat_started

# Check for or start the OpenAM server
setup_openam_server

tail -f $CATALINA_HOME/logs/catalina.out
