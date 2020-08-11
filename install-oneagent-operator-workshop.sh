#!/bin/bash

read -p 'Dynatrace Environment ID (ex. https://mou612.dynatrace-sprint.dynalabs.io/e/<ENVIRONMENT_ID>): ' envID
read -p 'Dynatrace API Token: ' apitoken
read -p 'Dynatrace PaaS Token: ' paastoken

echo ""
echo -e "Please confirm all are correct: "
echo "Your Dynatrace URL is: https://mou612.managed-sprint.dynalabs.io/e/$envID"

echo "Dynatrace API Token: $apitoken"
echo "Dynatrace PaaS Token: $paastoken"
read -p "Is this all correct? (y/n) : " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
cat <<EOF > var.sh
environmentID=$envID
apitoken=$apitoken
paastoken=$paastoken
EOF

kubectl create namespace dynatrace
kubectl apply -f https://github.com/Dynatrace/dynatrace-oneagent-operator/releases/latest/download/kubernetes.yaml

kubectl -n dynatrace create secret generic oneagent --from-literal="apiToken=$apitoken" --from-literal="paasToken=$paastoken"

if [[ -f "cr.yaml" ]]; then
    rm -f cr.yaml
    echo "Removed cr.yaml"
fi

curl -o cr.yaml https://raw.githubusercontent.com/Dynatrace/dynatrace-oneagent-operator/master/deploy/cr.yaml

echo "Managed Environment"
sed -i 's/apiUrl: https:\/\/ENVIRONMENTID.live.dynatrace.com\/api/apiUrl: https:\/\/mou612.managed-sprint.dynalabs.io\/e\/'$envID'\/api/' cr.yaml

kubectl create -f cr.yaml

fi
