
log() {
echo "$(date +'%Y-%m-%d %H:%M:%S') $1"
}

log_error() {
echo "$(date +'%Y-%m-%d %H:%M:%S') ERROR: $1" >&2
}

function init_env_variables() {
  # Retrieve the various routes for APIC components
  # API Manager URL
  APIC_INST_NAME=$(kubectl get apiconnectcluster -o=jsonpath='{.items[0].metadata.name}')
  
  log "APIC NAME: ${APIC_INST_NAME}"


  if APIC_GTW_PWD_B64=$(kubectl get secret ${APIC_INST_NAME}-gw-admin -o=jsonpath='{.data.password}' 2> /dev/null ); then
    APIC_GTW_PWD=$(echo $APIC_GTW_PWD_B64 | base64 --decode)
  fi
  
  EP_MGMT_API=$(kubectl get route "${APIC_INST_NAME}-mgmt-api-manager" -o jsonpath="{.spec.host}")
  
  
 
  #EP_PLF_API=$(kubectl get route "${APIC_INST_NAME}-mgmt-platform-api" -o jsonpath="{.spec.host}")
  EP_PLF_API=$(kubectl get apiconnectcluster "${APIC_INST_NAME}" -o=jsonpath='{.status.endpoints[?(@.name=="platformApi")].uri}')
  
}         

#######################################################
# Generate access token for cloud manager

function gen_cloud_at(){

  
  # APIC Cloud Manager admin password
  if APIC_CM_ADMIN_PWD_B64=$(kubectl get secret ${APIC_INST_NAME}-mgmt-admin-pass -o=jsonpath='{.data.password}' 2> /dev/null ); then
    APIC_CM_ADMIN_PWD=$(echo $APIC_CM_ADMIN_PWD_B64 | base64 --decode)
  fi

  APIC_CRED=$(kubectl get secret ${APIC_INST_NAME}-mgmt-cli-cred -o jsonpath='{.data.credential\.json}' | base64 --decode)

  # The goal is to get the apikey defined in the realm provider/common-services, get the credentials for the toolkit, then use the token endpoint to get an oauth token for Cloud Manager from API Key
  TOOLKIT_CLIENT_ID=$(echo ${APIC_CRED} | jq -r .id)
  TOOLKIT_CLIENT_SECRET=$(echo ${APIC_CRED} | jq -r .secret)
  
  echo "{\"username\": \"admin\", \"password\": \"$APIC_CM_ADMIN_PWD\", \"realm\": \"admin/default-idp-1\", \"client_id\": \"$TOOLKIT_CLIENT_ID\", \"client_secret\": \"$TOOLKIT_CLIENT_SECRET\", \"grant_type\": \"password\"}" > "${SCRIPT_DIR}/admin_cm_creds.json"
  
  cm_auth_token=$(curl -ks -X POST "${EP_PLF_API}api/token" \
   -H 'Content-Type: application/json' \
   -H 'Accept: application/json' \
   --data-binary "@${SCRIPT_DIR}/admin_cm_creds.json")
  
  echo "cmToken: $cm_token"

  if [ $(echo $cm_token | jq .status ) = "401" ] ; then
    log_error "Error with login -> $cm_token"
  elif [ $(echo $cm_token | jq .access_token) != "null" ]
    then
      cm_at=$(echo $cm_token | jq .access_token | sed -e s/\"//g);
  fi
  
  echo "access_token: ${cm_at}"
}
              
 ################################################################################################
# Start of the script main entry
# main

starting=$(date);

echo "Installing jq"
apk --no-cache add jq
echo "Running kubectl command"

mkdir /tmp/script

SCRIPT_DIR="/tmp/script"

log "start script"

# Init APIC variables
init_env_variables

# get access token with user admin
gen_cloud_at


duration=$SECONDS
ending=$(date);
# echo "------------------------------------"
log "Start: $starting - end: $ending" 1>&2
log "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."  1>&2

