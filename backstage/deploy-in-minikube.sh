#!/bin/bash

# Prompt the user for their GitHub token
echo "Enter your GitHub token:"
read GITHUB_TOKEN

# Start cluster
minikube start

# We create the secret for the Github token with this command. This way the token won't get pushed to Github.
kubectl create ns backstage
kubectl create secret generic github-token --namespace=backstage --from-literal=GITHUB_TOKEN="$GITHUB_TOKEN"

# Install Backstage
helm install backstage -n argocd helm/infra/backstage --values helm/infra/backstage/values-custom.yaml --dependency-update --create-namespace

# Wait for the Backstage pod to be ready
echo "Waiting for backstage pod to be ready..."
until [[ $(kubectl -n backstage get pods -l "app.kubernetes.io/name=backstage" -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') == "True" ]]; do
  echo "Waiting for backstage pod to be ready..."
  sleep 3
done

# Port forward the Backstage service
kubectl port-forward -n backstage service/backstage 8080:7007