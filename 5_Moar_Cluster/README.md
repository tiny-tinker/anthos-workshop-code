# 5_Moar_Cluster

Let's add another cluster so we can make things more interesting.

First, download all these terraform files:

```bash
cd ~
git clone https://github.com/tiny-tinker/anthos-workshop-code
cd anthos-workshop-code/5_Moar_Cluster
```

Then, run the terraform commands to pull down the necessary resources and then apply the configuration. 

```
terraform init
terraform apply \
  -var project_id=${PROJECT_ID} \
  -var node_pool=${NODE_POOL} \
  -var cluster_name=${CLUSTER_NAME_2} \
  -var membership_name=${MEMBERSHIP_NAME_2} \
  -var hub_sa_name=${KSA_NAME}

```


Then, let's deploy the app into the cluster... hopefully....
```bash
cd ~
cd microservices-demo/

kubectl create namespace $K8S_NAMESPACE
kubectl apply -n ${K8S_NAMESPACE} -f release/kubernetes-manifests.yaml
```
