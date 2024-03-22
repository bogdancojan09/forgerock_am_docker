#!/usr/bin/env bash

# Change the session cookie name
# This Bash script should change the session cookie name in the OpenAM server

# The steps of the scripts are the following:

# Step 1: Create and configure a private key pair; this will be used to connect through Amster to the OpenAM server
# - the private keys will be created in PKCS#1 PEM format - AM only supports keys that begin with "----- BEGIN RSA PRIVATE KEY -----"
# - the keys will be stored in the $HOME/.ssh/id_rsa (create the .ssh directory if it does not exist)
# - the contents of the public key stored in $HOME/.ssh/id_rsa.pub will be added to the authorized_keys file in the openam/security/keys/amster directory

# Step 2: Connect to the OpenAM server using Amster and the generated private key pair

# Step 3: Export the configuration of the OpenAM server to a path within the container using export-config command
# - the configuration should contain two directories: global and realms

# Step 4: Once the configuration is exported, we should change the session cookie name in the configuration files
# - the session cookie name is defined in the global/DefaultSecurityProperties.json file, under the "com.iplanet.am.cookie.name" property

# Step 5: Import the configuration back to the OpenAM server using import-config command

# Step 6: Restart the OpenAM server

# Step 7 (optional): If the OpenAM server has started running, we can delete the configuration files that were exported in step 3.

# Note: Given that both Step 2 and 3 are being executed within the Amster shell, we can run all the steps in a single script.


# Step 1: Create and configure a private key pair
echo "################################################################## Creating and configuring a private key pair..."
# Check if .ssh directory exists; if it exists, then keys exist.
if [ -d "$HOME/.ssh" ]; then
    echo "Directory $HOME/.ssh exists."
    continue
else
    echo "Directory $HOME/.ssh does not exist. Creating it..."
    
    # Create the .ssh directory if it does not exist
    mkdir -p $HOME/.ssh
    ssh-keygen -t rsa -b 2048 -m PEM -f $HOME/.ssh/id_rsa -N ""
    # Add the public key to the authorized_keys file
    cat $HOME/.ssh/id_rsa.pub >> openam/security/keys/amster/authorized_keys
fi

# Step 2 and Step 3: Connect to the OpenAM server using Amster and the generated private key pair, and export the configuration of the OpenAM server
echo "################################################################## Connecting to the OpenAM server using Amster..."
./amster/amster <<EOF
connect -k .ssh/id_rsa http://openam.example.com:8080/openam
export-config --path /openam/export
EOF

# Step 4: Change the session cookie name in the configuration files
echo "################################################################## Changing the session cookie name in the configuration files..."
# Change the session cookie name in the global/DefaultSecurityProperties.json file using jq
contents="$(jq '.data."amconfig.header.cookie"."com.iplanet.am.cookie.name" = "myNewCookie"' /openam/export/global/DefaultSecurityProperties.json)"
echo -E "${contents}" > /openam/export/global/DefaultSecurityProperties.json

# Step 5: Import the configuration back to the OpenAM server
echo "################################################################## Importing the configuration back to the OpenAM server..."
./amster/amster <<EOF
connect -k .ssh/id_rsa http://openam.example.com:8080/openam
import-config --path /openam/export
EOF

# Step 6: Restart the OpenAM server
echo "################################################################## Restarting the OpenAM server..."
catalina.sh stop
catalina.sh start

# Step 7 (optional): Delete the configuration files that were exported in step 3 if server has started running
echo "################################################################## Deleting the configuration files that were exported..."
rm -rf /openam/export

echo "################################################################## Session cookie name changed successfully"
echo "################################################################## Script change_session_cookie_name run finished"
