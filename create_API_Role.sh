#!/bin/bash

###########################################################################################
################################# I N F O R M A T I O N ###################################
###########################################################################################
#
# Script provided by DARE Technology Ltd | Daniel Ellis
#
# Create the API role necessary for UEM Integration between Jamf Pro and Jamf Security Cloud.
#
# API Privileges required;
# Create API Roles
#
###########################################################################################
###########################################################################################


###########################################################################################
################################## V A R I A B L E S ######################################
###########################################################################################

jamfURL="https://feeltectjamf.jamfcloud.com/"
clientID="8af18fc4-2152-4e53-b95c-ddd43a51b8f8"
clientSecret="EbqcVXo4ys4YarciLQMdWrvsfJFJeth2RpIgEVg2DNnSIQw0cVcz_Ne38LxEaf2a"


apiRoleDisplayName="JSC | UEM Integration"
apiRolePrivileges=$(cat <<EOF
"Create iOS Configuration Profiles",
"Read iOS Configuration Profiles",
"Update iOS Configuration Profiles",
"Create Mobile Device Extension Attributes",
"Read Mobile Device Extension Attributes",
"Delete Mobile Device Extension Attributes",
"Read Static Mobile Device Groups",
"Update Static Mobile Device Groups",
"Read Smart Mobile Device Groups",
"Update Smart Mobile Device Groups",
"Read Mobile Devices",
"Update Mobile Devices",
"Read Mobile Device Applications",
"Create Static Computer Groups",
"Read Static Computer Groups",
"Update Static Computer Groups",
"Read Smart Computer Groups",
"Update Smart Computer Groups",
"Read Computers",
"Update Computers",
"Read Computer Extension Attributes",
"Create Computer Extension Attributes",
"Update Computer Extension Attributes",
"Delete Computer Extension Attributes",
"Read Mac Applications",
"Create macOS Configuration Profiles",
"Read macOS Configuration Profiles",
"Update macOS Configuration Profiles",
"Update User"
EOF
)

###########################################################################################
################################## F U N C T I O N S ######################################
###########################################################################################

# Generate an auth token
generate_access_token() {
    accessToken=$( /usr/bin/curl --silent --location --request POST "${jamfURL}/api/oauth/token" \
    --header "Content-Type: application/x-www-form-urlencoded" \
    --data-urlencode "client_id=${clientID}" \
    --data-urlencode "grant_type=client_credentials" \
    --data-urlencode "client_secret=${clientSecret}" )
}

# Remove additional data from the initial response
generate_bearer_token() {
    bearerToken=$(/usr/bin/plutil -extract access_token raw -o - - <<< "$accessToken")
}

# Create the API Role
create_api_role() {
    curl --silent --location --request POST "${jamfURL}/api/v1/api-roles" \
    --header "Content-Type: application/json" \
    --header "Accept: application/json" \
    --header "Authorization: Bearer ${bearerToken}" \
    --data @- <<EOF
{
    "displayName": "${apiRoleDisplayName}",
    "privileges": [
        ${apiRolePrivileges}
    ]
}
EOF
}

# Clear Bearer Tokens
clearTokens() {
    authToken=$(/usr/bin/curl "${jamfUrl}/api/v1/auth/invalidate-token" \
    --silent \
    --request POST \
    --header "Authorization: Bearer ${bearerToken}")
    bearerToken=""
}


###########################################################################################
##################################### L O G I C ###########################################
###########################################################################################
    
    generate_access_token
    generate_bearer_token
    create_api_role
    clearTokens

exit 0