#!/usr/bin/env bash

# Auxiliary function to check if Tomcat started successfully.
# It will check if the response code is minimum 302, which means that the request was redirected to the login page.
# If it is, it means that Tomcat started successfully and the script should continue.
# If it is not, it means that Tomcat has not started yet and the script should wait for it.
check_tomcat_started() {
    while true; do
        response=$(curl --write-out '%{http_code}' --silent --output /dev/null http://openam.example.com:8080/openam/)
        if [ "$response" -ne 0  ] && [ "$response" -le 302 ]; then
            echo "Tomcat started successfully"
            break
        else
            echo "Waiting for Tomcat..."
            sleep 5
        fi
    done
}

# Start Tomcat
catalina.sh start

# Wait for Tomcat to start
check_tomcat_started

./amster/amster <<< "install-openam --serverUrl http://openam.example.com:8080/openam --adminPwd password --acceptLicense"

# Here we should run the change_session_cookie_name.sh script so that we change the initial name of the user session cookie
./change_session_cookie_name.sh 

# Wait for Tomcat to successfully restart
check_tomcat_started

# Here we should run the create_authentication_tree_script script so that it creates an authentication tree in the OpenAM server
./create_authentication_tree_script.sh

tail -f $CATALINA_HOME/logs/catalina.out
