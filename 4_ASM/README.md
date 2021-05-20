# 4_ASM
Now let's install the Service Mesh code.

Details [here](https://cloud.google.com/service-mesh/docs/scripted-install/gke-install).

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

Download and make executable the installer. Also install netcat because internet cats are cool. And because it makes a noisy warning go away. 

```bash

## #############
# FIND OUT WHERE THIS GOES AND IF IT'S NEEDED?!
############
# curl --request POST \
# --header "Authorization: Bearer $(gcloud auth print-access-token)" \
# --data '' \
# https://meshconfig.googleapis.com/v1alpha1/projects/${PROJECT_ID}:initialize

cd ~

curl https://storage.googleapis.com/csm-artifacts/asm/install_asm_1.9 > install_asm

chmod +x install_asm

# Install nc to allow k8s connection verification
sudo apt-get install netcat
```

Before we actually do the installation, we can validate everything is set up. 
```bash
./install_asm \
  --project_id $PROJECT_ID \
  --cluster_name $CLUSTER_NAME \
  --cluster_location $ZONE \
  --mode install \
  --output_dir ./asm \
  --only_validate
```

If everything looks good then fire away!

```bash
./install_asm \
  --project_id $PROJECT_ID \
  --cluster_name $CLUSTER_NAME \
  --cluster_location $ZONE \
  --mode install \
  --output_dir ./asm \
  --enable_cluster_labels \
  --enable_cluster_roles
```

Then, apply the revision label. It's buried in the get pods command, so I dug it out for you. Note that the **istio-injection not found** message can be ignored.

```bash
# Locate revision label
kubectl -n istio-system get pods -l app=istiod --show-labels

## Look for the part that says "istio.io/rev=asm-195-2"
REVISION=asm-195-2

# Apply the revision label and *remove* the _istio-injection_ label if it exists
kubectl label namespace $K8S_NAMESPACE istio-injection- istio.io/rev=$REVISION --overwrite
#You can ignore the message "istio-injection not found" in the output.

```

For anyone working with kubernetes from the command line, [k9s](https://github.com/derailed/k9s) is an awesome utility to watch your clusters. After the restart we'll fire it up. 

```bash
curl -LO https://github.com/derailed/k9s/releases/download/v0.24.7/k9s_Linux_x86_64.tar.gz
tar -xzvf k9s_Linux_x86_64.tar.gz 
sudo cp k9s /usr/bin
```


Finally, restart the deployments in the namespace to trigger re-injection of the service mesh, then fire up k9s and watch it roll in. 

```bash
# restart the Pods to trigger re-injection.
kubectl rollout restart deployment -n $K8S_NAMESPACE
```

Give it a moment and go check out the [Service Mesh](https://console.cloud.google.com/anthos/services) page. 

Also, the [Cloud Monitoring](https://console.cloud.google.com/monitoring) page should look interesting. If you're into that kind of thing. 


