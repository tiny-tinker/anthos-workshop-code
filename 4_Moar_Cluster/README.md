# 4_Moar_Cluster

Add all the clusters!


```bash
gcloud container clusters create $CLUSTER_NAME_2 \
    --project=${PROJECT_ID} --zone=${ZONE_2} \
    --machine-type=e2-standard-4 --num-nodes=4 \
    --workload-pool=${PROJECT_ID}.svc.id.goog

gcloud container node-pools create $NODE_POOL \
  --cluster=$CLUSTER_NAME_2 \
  --workload-metadata=GKE_METADATA \
  --zone=$ZONE_2


gcloud container clusters get-credentials $CLUSTER_NAME_2 --zone $ZONE_2

kubectl create namespace $K8S_NAMESPACE
kubectl create serviceaccount --namespace $K8S_NAMESPACE $KSA_NAME

# Add the annotation to the Kubernetes service account,
kubectl annotate serviceaccount \
  --namespace $K8S_NAMESPACE \
  $KSA_NAME \
  iam.gke.io/gcp-service-account=${GSA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com



gcloud beta container hub memberships register $MEMBERSHIP_NAME_2 \
 --gke-cluster=$ZONE_2/$CLUSTER_NAME_2 \
 --enable-workload-identity

# Verify the membership registration
gcloud container hub memberships describe $MEMBERSHIP_NAME_2

# gsutil cp gs://config-management-release/released/latest/config-management-operator.yaml config-management-operator.yaml

kubectl apply -f config-management-operator.yaml


cat <<EOF > config-management.yaml
apiVersion: configmanagement.gke.io/v1
kind: ConfigManagement
metadata:
  name: config-management
spec:
  # clusterName is required and must be unique among all managed clusters
  clusterName: '$CLUSTER_NAME_2'
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

##
./install_asm \
  --project_id $PROJECT_ID \
  --cluster_name $CLUSTER_NAME_2 \
  --cluster_location $ZONE_2 \
  --mode install \
  --output_dir ./asm2 \
  --enable_cluster_labels \
  --enable_cluster_roles


###
# Apply the revision label and redeploy
#
kubectl -n istio-system get pods -l app=istiod --show-labels

## Look for the part that says "istio.io/rev=asm-195-2"
REVISION=asm-195-2

# Apply the revision label and *remove* the _istio-injection_ label if it exists
kubectl label namespace $K8S_NAMESPACE istio-injection- istio.io/rev=$REVISION --overwrite
#You can ignore the message "istio-injection not found" in the output.


# restart the Pods to trigger re-injection.
kubectl rollout restart deployment -n $K8S_NAMESPACE

```



