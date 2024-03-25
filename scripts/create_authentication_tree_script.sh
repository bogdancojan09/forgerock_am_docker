#!/usr/bin/env bash

# Create the authentication tree
# This script should follow the steps detailed in the "Configure the authentication tree" section of this link: 
# https://backstage.forgerock.com/docs/am/7.3/eval-guide/step-3-configure-am.html#configure-authentication-trees

# Step 1: Authenticate as the amAdmin user (we will need the session cookie for the next steps)
# Step 2: Define the components nodes: Username Collector, Password Collector
# Step 3: Define the PageNode using the components defined in the previous step
# Step 4: Define the Data Store Decision Node
# Step 5: Define the authentication tree containing the entry node as the Page Node. The tree should have the connections set to static nodes Success and Failure. Its name should be "myAuthenticationTree"

# All steps will be done using cURL commands to the REST API of the OpenAM server
# Steps 2-4 should have:
# - the "If-None-Match: *" header to avoid conflicts with other changes in the server
# - at least "_id" and "_type" in the body of the request

# Auxiliary function to check if response code is greater than 250.
# If it is, it means that the request was not successful and the script should exit.
# If response code is 412, it means that the resource already exists and the script should continue.
# Response has the following format: <JSON Response>#ResponseCode.
# we need to cut the response variable so that we only get the response code.
check_response_code() {
    response_code=$(echo $1 | cut -d '#' -f 2)
    if [ $response_code -gt 250 ]; then
        echo "Request not successful. Exiting script run."
        exit 1
    elif [ $response_code -eq 412 ]; then
        echo "Resource already exists. Continuing script run."
    fi
}

# All nodes must have a unique UUID identifier.
USERNAME_COLLECTOR_ID=$(cat /proc/sys/kernel/random/uuid)
PASSWORD_COLLECTOR_ID=$(cat /proc/sys/kernel/random/uuid)
PAGE_NODE_ID=$(cat /proc/sys/kernel/random/uuid)
DATASTORE_DECISION_ID=$(cat /proc/sys/kernel/random/uuid)

echo "################################################################## Setting up nodes..."
echo "USERNAME_COLLECTOR_ID: $USERNAME_COLLECTOR_ID"
echo "PASSWORD_COLLECTOR_ID: $PASSWORD_COLLECTOR_ID"
echo "PAGE_NODE_ID: $PAGE_NODE_ID"
echo "DATASTORE_DECISION_ID: $DATASTORE_DECISION_ID"

# Success and failure nodes have static UUIDs
SUCCESS_ID="70e691a5-1e33-4ac3-a356-e7b6d60d92e0"
FAILURE_ID="e301438c-0bd0-429c-ab0c-66126501069a"

echo "################################################################## Authenticating as admin into the OpenAM server..."
# Step 1: Authenticate as the amAdmin user
admintoken=$(curl -X POST \
    -H "Content-Type: application/json" \
    -H "X-OpenAM-Username: amAdmin" \
    -H "X-OpenAM-Password: $AM_ADMIN_PASSWORD" \
    -H "Accept-API-Version: resource=2.0, protocol=1.0" \
    -L "http://$AM_HOSTNAME:$AM_REMOTE_PORT/${AM_REMOTE_FILENAME}/json/realms/root/authenticate" | jq -r '.tokenId')

# Verify if admin token has been generated, otherwise exit script run
if [ -z "$admintoken" ]; then
    echo "Admin token not generated. Exiting script run."
    exit 1
fi

echo "################################################################## Setting up the Username and Password Nodes..."
# Step 2: Define the components nodes: Username Collector, Password Collector
putusernamecollectornoderesponse=$(curl -X PUT \
    -L "http://$AM_HOSTNAME:$AM_REMOTE_PORT/${AM_REMOTE_FILENAME}/json/realms/root/realm-config/authentication/authenticationtrees/nodes/UsernameCollectorNode/$USERNAME_COLLECTOR_ID" \
    -H "$AM_SESSION_COOKIE_NAME: $admintoken" \
    -H "Content-Type: application/json" \
    -H "Accept-API-Version: resource=1.0" \
    -H "If-None-Match: *" \
    -d '{
        "_id":"'"$USERNAME_COLLECTOR_ID"'",
        "_type":{
            "_id":"UsernameCollectorNode",
            "name":"Username Collector"
            }
        }')

check_response_code $putusernamecollectornoderesponse

putpasswordcollectornoderesponse=$(curl -X PUT \
    -L "http://$AM_HOSTNAME:$AM_REMOTE_PORT/${AM_REMOTE_FILENAME}/json/realms/root/realm-config/authentication/authenticationtrees/nodes/PasswordCollectorNode/$PASSWORD_COLLECTOR_ID" \
    -H "$AM_SESSION_COOKIE_NAME: $admintoken" \
    -H "Content-Type: application/json" \
    -H "Accept-API-Version: resource=1.0" \
    -H "If-None-Match: *" \
    -d '{
        "_id":"'"$PASSWORD_COLLECTOR_ID"'",
        "_type":{
            "_id":"PasswordCollectorNode",
            "name":"Password Collector"
            }
        }')

check_response_code $putpasswordcollectornoderesponse

echo "################################################################## Setting up the PageNode..."
# Step 3: Define the PageNode using the components defined in the previous step
putpagenoderesponse=$(curl -X PUT \
    -L "http://$AM_HOSTNAME:$AM_REMOTE_PORT/${AM_REMOTE_FILENAME}/json/realms/root/realm-config/authentication/authenticationtrees/nodes/PageNode/$PAGE_NODE_ID" \
    -H "$AM_SESSION_COOKIE_NAME: $admintoken" \
    -H "Content-Type: application/json" \
    -H "Accept-API-Version: resource=1.0" \
    -H "If-None-Match: *" \
    -d '{
        "_id": "'"$PAGE_NODE_ID"'",
        "_type": {
            "_id": "PageNode",
            "name": "Page Node"
        },
        "pageHeader": {},
        "pageDescription": {},
        "stage": "null",
        "nodes": [
            {
                "_id": "'"$USERNAME_COLLECTOR_ID"'",
                "nodeType": "UsernameCollectorNode",
                "name": "Username Collector",
                "displayName": "Username Collector"
            },
            {
                "_id": "'"$PASSWORD_COLLECTOR_ID"'",
                "nodeType": "PasswordCollectorNode",
                "name": "Password Collector", 
                "displayName": "Password Collector"
            }
        ]
    }')

check_response_code $putpagenoderesponse

echo "################################################################## Setting up the DataStoreDecisionNode..."
# Step 4: Define the Data Store Decision Node
putdatastoredecisionnode=$(curl -X PUT \
    -L "http://$AM_HOSTNAME:$AM_REMOTE_PORT/${AM_REMOTE_FILENAME}/json/realms/root/realm-config/authentication/authenticationtrees/nodes/DataStoreDecisionNode/$DATASTORE_DECISION_ID" \
    -H "$AM_SESSION_COOKIE_NAME: $admintoken" \
    -H "Content-Type: application/json" \
    -H "Accept-API-Version: resource=1.0" \
    -H "If-None-Match: *" \
    -d '{
        "_id":"'"$DATASTORE_DECISION_ID"'",
        "_type":{
            "_id":"DataStoreDecisionNode",
            "name":"Data Store Decision"
            }
        }')

check_response_code $putdatastoredecisionnode

echo "################################################################## Setting up the Authentication Tree..."
# Step 5: Define the authentication tree containing the entry node as the Page Node. The tree should have the connections set to static nodes Success and Failure. Its name should be "myAuthenticationTree"
curl -X PUT \
    -L "http://$AM_HOSTNAME:$AM_REMOTE_PORT/${AM_REMOTE_FILENAME}/json/realms/root/realm-config/authentication/authenticationtrees/trees/myAuthenticationTree" \
    -H "$AM_SESSION_COOKIE_NAME: $admintoken" \
    -H "Content-Type: application/json" \
    -H "Accept-API-Version: resource=1.0" \
    -H "If-None-Match: *" \
    -d '{
        "entryNodeId":"'"$PAGE_NODE_ID"'",
        "nodes": {
            "'"$PAGE_NODE_ID"'": {
                "displayName": "Page Node",
                "nodeType": "PageNode",
                "connections": {
                    "outcome": "'"$DATASTORE_DECISION_ID"'"
                }
            },
            "'"$DATASTORE_DECISION_ID"'": {
                "displayName": "Data Store Decision",
                "nodeType": "DataStoreDecisionNode",
                "connections": {
                    "true": "'"$SUCCESS_ID"'",
                    "false": "'"$FAILURE_ID"'"
                }
            }
        }
    }'