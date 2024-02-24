#!/bin/bash

# Prompt the user for their GitHub token
read -p "Enter your GitHub token: " GITHUB_TOKEN

# Start cluster. Extra beefy beause Backstage is a bit heavy.
minikube start --cpus 4 --memory 4096

# We create the secret for the Github token with this command. This way the token won't get pushed to Github.
kubectl create ns backstage
kubectl create secret generic github-token -n backstage --from-literal=GITHUB_TOKEN="$GITHUB_TOKEN"

# Install Backstage
helm install backstage -n backstage backstage/helm-chart --values backstage/helm-chart/values-custom.yaml --dependency-update --create-namespace
# helm install backstage -n backstage helm/infra/backstage --values helm/infra/backstage/values-custom.yaml --dependency-update --create-namespace

# Install Redis
kubectl apply -f k8s-manifests/my-app-redis
# helm install redis -n my-app helm/my-app/redis --values helm/my-app/redis/values-custom.yaml --dependency-update --create-namespace

# Install Backend service
kubectl apply -f k8s-manifests/my-app-backend
# helm install backend -n my-app helm/my-app/backend --dependency-update --create-namespace

# Wait for the Postgres pod to be ready
echo "Waiting for postgres pod to be ready..."
until [[ $(kubectl -n backstage get pods -l "app.kubernetes.io/name=postgresql" -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') == "True" ]]; do
  echo "Waiting for postgress pod to be ready... It's required for backstage to start."
  sleep 3
done

# Wait for the Backstage pod to be ready
echo "Waiting for backstage pod to be ready..."
until [[ $(kubectl -n backstage get pods -l "app.kubernetes.io/name=backstage" -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') == "True" ]]; do
  echo "Waiting for backstage pod to be ready..."
  sleep 3
done

# Port forward the Backstage service
kubectl port-forward -n backstage service/backstage 8080:7007
