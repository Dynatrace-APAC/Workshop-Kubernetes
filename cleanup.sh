#!/bin/bash

kubectl delete -n dynatrace oneagent --all
kubectl delete -f https://github.com/Dynatrace/dynatrace-oneagent-operator/releases/latest/download/kubernetes.yaml
kubectl delete secret oneagent
