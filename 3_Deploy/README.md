# 3_Deploy

Now that we have a cluster and Anthos Config manager, let's get an application deployed. 

```bash
# Clone the repo
git clone https://github.com/GoogleCloudPlatform/microservices-demo.git
cd microservices-demo

# Generate OnlineBoutique manifests using your KSA as the Pod service account.
#sed -i "s/serviceAccountName: default/serviceAccountName: ${KSA_NAME}/g" release/kubernetes-manifests.yaml

# Deploy OnlineBoutique to your GKE cluster using the install instructions 
kubectl apply -n ${K8S_NAMESPACE} -f release/kubernetes-manifests.yaml
```

Cool, let's go check out the shop

```bash
kubectl get service frontend-external -n $K8S_NAMESPACE | awk '{print $4}'
```
