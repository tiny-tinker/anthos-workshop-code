# 0_Setup

First, we need to set some variables and enable the APIs. 
**Note** You will **NEED** to run `gcloud config set project MY_PROJECT_NAME` before running this command. 

```bash
cat <<EOF > setvars.env
PROJECT_ID=`gcloud config get-value project`
ME=`whoami`@houseoftnt.club

# Cluster configuration
ZONE=us-central1-b
ZONE_2=asia-east2-a
CLUSTER_NAME=gke-us-central
CLUSTER_NAME_2=gke-asia-east

K8S_NAMESPACE=my-ns

# Hub membership
MEMBERSHIP_NAME=${CLUSTER_NAME}
MEMBERSHIP_NAME_2=${CLUSTER_NAME_2}

NODE_POOL=my-pool
KSA_NAME=my-account
GSA_NAME=my-account

# Policy and config management repo
ACM_REPO=https://github.com/tiny-tinker/anthos-workshop-acm
EOF

source setvars.env
```


Now enable the APIs.

```bash
gcloud services enable \
    container.googleapis.com \
    compute.googleapis.com \
    monitoring.googleapis.com \
    cloudtrace.googleapis.com \
    clouddebugger.googleapis.com \
    cloudprofiler.googleapis.com \
    gkehub.googleapis.com \
    anthos.googleapis.com \
    meshca.googleapis.com \
    stackdriver.googleapis.com \
    cloudresourcemanager.googleapis.com \
    meshconfig.googleapis.com \
    meshtelemetry.googleapis.com \
    --project ${PROJECT_ID}

gcloud config set compute/zone $ZONE

```





