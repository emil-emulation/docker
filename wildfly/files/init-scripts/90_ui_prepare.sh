#!/bin/bash

if [ -n $WEBFQDN ]; then 
   echo -e "{ \"eaasBackendURL\": \"$WEBFQDN/emil/Emil/\",\n\"stopEmulatorRedirectURL\":\"$WEBFQDN/emil-ui\"}" > /home/bwfla/emil-ui/config.json
   echo -e "{ \"eaasBackendURL\": \"$WEBFQDN/emil/Emil/\",\n\"stopEmulatorRedirectURL\":\"$WEBFQDN/emil-ui\"}" > /home/bwfla/emil-admin-ui/config.json

if ! [ -f /home/bwfla/.bwFLA/EmilConf.xml ]; then   
   cat << EOF > /home/bwfla/.bwFLA/EmilConf.xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<emilConf>
<embedGw>$WEBFQDN</embedGw>
</emilConf>
EOF
fi

if ! [ -f /home/bwfla/.bwFLA/WorkflowsConf.xml ]; then
   cat << EOF > /home/bwfla/.bwFLA/WorkflowsConf.xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<workflowsConf>
<embedGw>$WEBFQDN</embedGw>
</workflowsConf>
EOF
fi

else
   echo "{\"eaasBackendURL\": \"http://localhost:8080/emil/Emil/\",\"stopEmulatorRedirectURL\": \"http://localhost:8080/emil-ui/\"}" > /home/bwfla/emil-ui/config.json
   echo "{\"eaasBackendURL\": \"http://localhost:8080/emil/Emil/\",\"stopEmulatorRedirectURL\": \"http://localhost:8080/emil-admin-ui/\"}" > /home/bwfla/emil-ui/config.json
fi 
