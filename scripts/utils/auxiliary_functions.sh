#!/usr/bin/env bash

# import the regex_validations.sh script
source ./utils/regex_validations.sh

# Main function to set up the OpenAM server within the ForgeRock setup.
# It will check if there is any contents in the /${AM_REMOTE_FILENAME}/var/.version file.
# If there is, then the OpenAM server is installed.
# If the file does not exist, then the process of setting up the OpenAM server is started.
setup_openam_server() {
    if test -e "/root/${AM_REMOTE_FILENAME}/var/.version"; then
        echo "OpenAM server installed: $(cat /root/${AM_REMOTE_FILENAME}/var/.version)"
    else
        echo "OpenAM server is not installed, going through the installation process..."

        ./amster/amster <<< "install-openam --serverUrl http://${AM_HOSTNAME}:${AM_REMOTE_PORT}/${AM_REMOTE_FILENAME} --adminPwd ${AM_ADMIN_PASSWORD} --acceptLicense"

        # Here we should run the change_session_cookie_name.sh script so that we change the initial name of the user session cookie
        ./change_session_cookie_name.sh 

        # Wait for Tomcat to successfully restart
        check_tomcat_started

        # Here we should run the create_authentication_tree_script script so that it creates an authentication tree in the OpenAM server
        ./create_authentication_tree_script.sh
    fi
}

# Auxiliary function to check if Tomcat started successfully.
# It will check if the response code is minimum 302, which means that the request was redirected to the login page.
# If it is, it means that Tomcat started successfully and the script should continue.
# If it is not, it means that Tomcat has not started yet and the script should wait for it.
check_tomcat_started() {
    while true; do
        response=$(curl --write-out '%{http_code}' --silent --output /dev/null http://${AM_HOSTNAME}:${AM_REMOTE_PORT}/${AM_REMOTE_FILENAME}/)
        if [ "$response" -ne 0  ] && [ "$response" -le 302 ]; then
            echo "Tomcat started successfully"
            break
        else
            echo "Waiting for Tomcat..."
            sleep 5
        fi
    done
}

# Validation auxiliary function to check all .env variables using is_pattern function from regex_validations.sh
# It will check if all variables are set and if they follow the correct pattern.
validate_env_variables() {
    if [ -z "$AM_HOSTNAME" ] || [ -z "$AM_REMOTE_PORT" ] || [ -z "$AM_REMOTE_FILENAME" ] || [ -z "$AM_ADMIN_PASSWORD" ] || [ -z "$AM_SESSION_COOKIE_NAME" ]; then
        echo "One or more environment variables are empty. Exiting script run."
        exit 1
    fi

    if [ "$(is_pattern $AM_HOSTNAME '^[a-zA-Z0-9]+\.[a-zA-Z0-9]+\.[a-z]+$')" == "false" ]; then
        echo "AM_HOSTNAME does not follow the correct pattern. Exiting script run."
        exit 1
    fi

    if [ "$(is_pattern $AM_REMOTE_PORT '^[0-9]+$')" == "false" ]; then
        echo "AM_REMOTE_PORT does not follow the correct pattern. Exiting script run."
        exit 1
    fi

    if [ "$(is_pattern $AM_REMOTE_FILENAME '^[a-z]+$')" == "false" ]; then
        echo "AM_REMOTE_FILENAME does not follow the correct pattern. Exiting script run."
        exit 1
    fi

    if [ "$(is_pattern $AM_ADMIN_PASSWORD '^[a-zA-Z0-9]+$')" == "false" ]; then
        echo "AM_ADMIN_PASSWORD does not follow the correct pattern. Exiting script run."
        exit 1
    fi

    if [ "$(is_pattern $AM_SESSION_COOKIE_NAME '^[a-zA-Z]+$')" == "false" ]; then
        echo "AM_SESSION_COOKIE_NAME does not follow the correct pattern. Exiting script run."
        exit 1
    fi
}
