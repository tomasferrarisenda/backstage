#!/bin/bash

# Prompt the user for their GitHub token
echo "Enter your GitHub token:"
read GITHUB_TOKEN

# Start cluster
minikube start

# Install ArgoCD
helm install argocd -n argocd helm/infra/argo-cd --values helm/infra/argo-cd/values-custom.yaml --dependency-update --create-namespace

# We first create an ArgoCD AppProject called "argocd" where all ArgoCD self-managment resources will exist.
kubectl create -n argocd -f argo-cd/self-manage/appprojects/argocd-appproject.yaml  

# Then we create an application that will automatically deploy any ArgoCD AppProjects we specify in the argo-cd/self-manage/appprojects/ directory.
kubectl create -n argocd -f argo-cd/self-manage/argocd-app-of-projects-application.yaml

# Then we create an application that will monitor the helm/infra/argocd directory, the same we used to deploy ArgoCD, making ArgoCD self-managed. Any changes we apply in the helm/infra/argocd directory will be automatically applied.
kubectl create -n argocd -f argo-cd/self-manage/argocd-application.yaml  

# Finally, we create an application that will automatically deploy any ArgoCD Applications we specify in the argo-cd/applications directory (App of Apps pattern).
kubectl create -n argocd -f argo-cd/self-manage/argocd-app-of-apps-application.yaml  

# We create the secret for the Github token with this command. This way the token won't get pushed to Github.
kubectl create ns backstage
kubectl create secret generic github-token --namespace=backstage --from-literal=GITHUB_TOKEN="$GITHUB_TOKEN"

# Get ArgoCD admin password
until kubectl -n argocd get secret argocd-initial-admin-secret &> /dev/null; do
  echo "Waiting for secret 'argocd-initial-admin-secret' to be available..."
  sleep 3
done
echo "#############################################################################"
echo "#############################################################################"
echo "#############################################################################"
echo " "
echo "THE ARGOCD 'admin' PASSWORD IS:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo " "
echo " "
echo "#############################################################################"
echo "#############################################################################"
echo "#############################################################################"

# Wait for the Backstage pod to be ready
echo "Waiting for backstage pod to be ready..."
until [[ $(kubectl -n backstage get pods -l "app.kubernetes.io/name=backstage" -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') == "True" ]]; do
  echo "Waiting for backstage pod to be ready..."
  sleep 3
done

# Port forward the Backstage service
kubectl port-forward -n backstage service/backstage 8080:7007