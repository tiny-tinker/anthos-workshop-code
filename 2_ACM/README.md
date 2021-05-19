# 2_ACM

Now comes the fun parts and our first introduction to "Anthos". [This](https://cloud.google.com/anthos-config-management/docs/how-to/installing#gcloud) doc has a handy walk through and is the source of the code below. 

First we need to register the cluster. Useful doc [here](https://cloud.google.com/anthos/multicluster-management/connect/registering-a-cluster#before_you_begin).

```bash
gcloud beta container hub memberships register $MEMBERSHIP_NAME \
 --gke-cluster=$ZONE/$CLUSTER_NAME \
 --enable-workload-identity

# Verify the membership registration
gcloud container hub memberships describe $MEMBERSHIP_NAME
```

Now, install [Config Sync](https://cloud.google.com/anthos-config-management/docs/how-to/installing-config-sync). There is a [note](https://cloud.google.com/anthos-config-management/docs/how-to/installing-config-sync#configuring-config-sync) that you should run these lines with `kubectl`, not `gcloud`. 

```bash
# If your creds are stale or non-existant
gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE

kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole cluster-admin --user $ME
```

Next, install the Configuration Management Operator into the cluster. This is really the heart of ACM and allows for the policy enforcement. Note the [policyController](https://cloud.google.com/anthos-config-management/docs/how-to/installing-policy-controller) in the yaml. 

```bash

gsutil cp gs://config-management-release/released/latest/config-management-operator.yaml config-management-operator.yaml

kubectl apply -f config-management-operator.yaml


# Also handy doc for the policyController item
# https://cloud.google.com/anthos-config-management/docs/how-to/installing-policy-controller
cat <<EOF > config-management.yaml
apiVersion: configmanagement.gke.io/v1
kind: ConfigManagement
metadata:
  name: config-management
spec:
  # clusterName is required and must be unique among all managed clusters
  clusterName: '$CLUSTER_NAME'
  # Enable multi-repo mode to use additional features
  enableMultiRepo: true
  policyController:
    enabled: true
    # Uncomment to prevent the template library from being installed
    # templateLibraryInstalled: false
EOF


kubectl apply -f config-management.yaml


cat <<EOF > root-sync.yaml
# If you are using a Config Sync version earlier than 1.7,
# use: apiVersion: configsync.gke.io/v1alpha1
apiVersion: configsync.gke.io/v1beta1
kind: RootSync
metadata:
  name: root-sync
  namespace: config-management-system
spec:
  sourceFormat: hierarchy
  git:
    repo: '$ACM_REPO'
    branch: main
    dir: "config-root/"
    auth: none
    #secretRef:
    #  name: '$SECRET_NAME'
EOF

kubectl apply -f root-sync.yaml

```


Verify the pods for Config Management are running. 

```bash
kubectl -n kube-system get pods | grep config-management
```

This is a handy command to check the logs for any sync issues

```bash
kubectl logs -n config-management-system -l configsync.gke.io/reconciler=root-reconciler -c git-sync
```

If everything looks good, go check it out in the [Config Management Console](https://console.cloud.google.com/anthos/config_management)



