#!/bin/bash

source var.sh

gcloud compute instances create dynatrace-activegate \
--image-family ubuntu-1604-lts \
--image-project ubuntu-os-cloud \
--zone australia-southeast1-a \

echo "Compute VM created"

sleep 20s

gcloud compute scp ~/HOT-k8s/install-activegate.sh \
      dynatrace-activegate:~/ --zone australia-southeast1-a
echo "Copied file to Activegate"

gcloud compute ssh --zone australia-southeast1-a dynatrace-activegate --command "./install-activegate.sh $tenantID $paastoken"
