#!/bin/bash

read -p 'Dynatrace SaaS(S) or Dynatrace Managed(M) (S/M)?' env

if [[ $REPLY =~ ^[Ss]$ ]]
then
read -p 'Dynatrace Tenant ID (ex. https://<TENANT_ID>.live.dynatrace.com): ' tenantID
elif [[ $REPLY =~ ^[Mm]$ ]]
read -p 'Dynatrace Tenant ID (ex. https://<TENANT_ID>.dynatrace-managed.com): ' tenantID
read -p "Dynatrace Environment ID (ex. https://<TENANT_ID>.dynatrace-managed.com/e/<ENVIRONMENT_ID>): " envID
fi

read -p 'Dynatrace API Token: ' apitoken
read -p 'Dynatrace PaaS Token: ' paastoken

cat <<EOF > var.sh
attendeeID=$attendeeID
apitoken=$apitoken
paastoken=$paastoken
EOF

kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole cluster-admin \
  --user $(gcloud config get-value account) \
  
kubectl create namespace dynatrace

kubectl create -f https://raw.githubusercontent.com/Dynatrace/dynatrace-oneagent-operator/v0.3.1/deploy/kubernetes.yaml

kubectl -n dynatrace create secret generic oneagent --from-literal="apiToken=$apitoken" --from-literal="paasToken=$paastoken"

# read the yml template from a file and substitute the string 
# {{MYVARNAME}} with the value of the MYVARVALUE variable
template=`cat "cr.yaml" | sed "s/{{attendeeID}}/$attendeeID/g"`

# apply the yml with the substituted value
echo "$template" | kubectl create -f -
