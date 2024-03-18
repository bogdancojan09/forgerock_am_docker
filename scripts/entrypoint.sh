#!/usr/bin/env bash

# Start Tomcat
catalina.sh start

# Wait for Tomcat to start
while true; do
    response=$(curl --write-out '%{http_code}' --silent --output /dev/null http://openam.example.com:8080/openam/)

    if [ "$response" -eq 302 ]; then
        echo "Tomcat started successfully"
        break
    else
        echo "Waiting for Tomcat..."
        sleep 5
    fi
done

./amster/amster <<< "install-openam --serverUrl http://openam.example.com:8080/openam --adminPwd password --acceptLicense"

# Here we should run the create_authentication_tree_script script so that it creates an authentication tree in the OpenAM server
./create_authentication_tree_script.sh

tail -f $CATALINA_HOME/logs/catalina.out
