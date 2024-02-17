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

# Access ArgoCD
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
kubectl port-forward service/argocd-server -n argocd 8080:443