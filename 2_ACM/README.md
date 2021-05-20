# 2_ACM

Now comes the fun parts and our first introduction to "Anthos". [This](https://cloud.google.com/anthos-config-management/docs/how-to/installing#gcloud) doc has a handy walk through and is the source of the code below. 

First we need to register the cluster. Useful doc for reference [here](https://cloud.google.com/anthos/multicluster-management/connect/registering-a-cluster#before_you_begin).

```bash
gcloud beta container hub memberships register $MEMBERSHIP_NAME \
 --gke-cluster=$ZONE/$CLUSTER_NAME \
 --enable-workload-identity

# Verify the membership registration
gcloud container hub memberships describe $MEMBERSHIP_NAME
```

Before we get too carried away, let's check out the namespaces
```bash
kubectl get ns
```


Now, install [Config Sync](https://cloud.google.com/anthos-config-management/docs/how-to/installing-config-sync). 

```bash
gcloud alpha container hub config-management enable
```

Next, install the Configuration Management Operator into the cluster. This is really the heart of ACM and allows for the policy enforcement. Note the [policyController](https://cloud.google.com/anthos-config-management/docs/how-to/installing-policy-controller) in the yaml. 

```bash
# Also handy doc for the policyController item
# https://cloud.google.com/anthos-config-management/docs/how-to/installing-policy-controller
cat <<EOF > config-management.yaml
apiVersion: configmanagement.gke.io/v1
kind: ConfigManagement
metadata:
  name: config-management
spec:
  # Use spec.git for generating a RootSync resource in multi-repo mode
  policyController:
    enabled: true
  git:
    syncRepo: '$ACM_REPO'
    syncBranch: 'main'
    secretType: 'none'
    policyDir: 'config-root/'

EOF

 gcloud alpha container hub config-management apply \
     --membership=$MEMBERSHIP_NAME \
     --config=config-management.yaml \
     --project=$PROJECT_ID


```


Verify the pods for Config Management are running. 

```bash
kubectl -n kube-system get pods | grep config-management
```

This is a handy command to check the logs for any sync issues. There might be errors around "matches for kind K8sBannedConfigMapKeysV1", but keep on. It just takes 4-5 minutes to get everything in sync. 

```bash
gcloud alpha container hub config-management status     --project=$PROJECT_ID
```

```bash
kubectl logs -n config-management-system -l configsync.gke.io/reconciler=root-reconciler -c git-sync
```

If everything looks good, go check it out in the [Config Management Console](https://console.cloud.google.com/anthos/config_management)


Let's check out the namespaces again. How is this list different than when we ran this above?
```bash
kubectl get ns
```


Now let's check that policy

```bash
cat <<EOF > bad-map.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: super-secret
  namespace: $K8S_NAMESPACE
data:
  private_key: the lilies are nice this time of year
EOF

kubectl apply -f bad-map.yaml
```





