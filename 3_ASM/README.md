# 4_ASM
Now let's install the Service Mesh code.

Details [here](https://cloud.google.com/service-mesh/docs/scripted-install/gke-install).

Download and make executable the installer. Also install netcat because internet cats are cool. And because it makes a noisy warning go away. 

```bash
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


Finally, restart the deployments in the namespace to trigger re-injection of the service mesh.

```bash
# restart the Pods to trigger re-injection.
kubectl rollout restart deployment -n $K8S_NAMESPACE

kubectl get pods -n $K8S_NAMESPACE -l istio.io/rev=$REVISION
```

Give it a moment and go check out the [Service Mesh](https://console.cloud.google.com/anthos/services) page. 

Also, the [Cloud Monitoring](https://console.cloud.google.com/monitoring) page should look interesting. If you're into that kind of thing. 


