# 1_Cluster

Now create the cluster, node pool and membership, we'll deploy an app into this later. Note the `--workload-pool` and `--workload-metadata` parameters here. These enable workload identity which is necessary for ACM to properly identify the workloads. 

```bash

gcloud container clusters create $CLUSTER_NAME \
    --project=${PROJECT_ID} --zone=${ZONE} \
    --machine-type=e2-standard-4 --num-nodes=4 \
    --workload-pool=${PROJECT_ID}.svc.id.goog

# Create the node pool with workload identity

gcloud container node-pools create $NODE_POOL \
  --cluster=$CLUSTER_NAME \
  --workload-metadata=GKE_METADATA \
  --zone=$ZONE
```

Then enable the service account and grant access to impersonate the Google service account. This allows the kubernetes service account the ability to make API calls to GCP.  

```bash

gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE

kubectl create namespace $K8S_NAMESPACE
kubectl create serviceaccount --namespace $K8S_NAMESPACE $KSA_NAME

gcloud iam service-accounts create $GSA_NAME

# Allow the Kubernetes service account to impersonate 
# the Google service account by creating an IAM policy binding
gcloud iam service-accounts add-iam-policy-binding \
  --role roles/iam.workloadIdentityUser \
  --member "serviceAccount:${PROJECT_ID}.svc.id.goog[${K8S_NAMESPACE}/${KSA_NAME}]" \
  ${GSA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com


# Add the annotation to the Kubernetes service account,
kubectl annotate serviceaccount \
  --namespace $K8S_NAMESPACE \
  $KSA_NAME \
  iam.gke.io/gcp-service-account=${GSA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com

```


Optional: Fire up a container, login and see what gloud accounts are available.

```bash

kubectl run -it \
 --image google/cloud-sdk:slim \
 --serviceaccount $KSA_NAME \
 --namespace $K8S_NAMESPACE \
 workload-identity-test
```

Once in the running container, who am I? Use ctrl-D to get out
```bash
# You are now connected to an interactive shell within the created Pod. Run the following command inside the Pod:
gcloud auth list

```

These roles allow workload identity-enabled pods to send traces and metrics to GCP. Check out the helpful notes [here](https://github.com/GoogleCloudPlatform/microservices-demo/blob/master/docs/workload-identity.md#setup-for-workload-identity-clusters).

```bash
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member "serviceAccount:${GSA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role roles/cloudtrace.agent

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member "serviceAccount:${GSA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role roles/monitoring.metricWriter
  
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member "serviceAccount:${GSA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role roles/cloudprofiler.agent
  
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member "serviceAccount:${GSA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role roles/clouddebugger.agent
```





