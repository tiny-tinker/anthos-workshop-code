# 0_Setup

First, we need to set some variables and enable the APIs. 

```bash
########
# CHANGE THESE!!!
#
ME=me@acme.com
PROJECT_ID=acme-house-of-cards


########
# RUN THESE
gcloud config set project $PROJECT_ID

ZONE=us-central1-b
CLUSTER_NAME=gke-us-central

ZONE_2=asia-east2-a
CLUSTER_NAME_2=gke-asia-east

MEMBERSHIP_NAME=gke-asia-membership
MEMBERSHIP_NAME_2=asia-east-membership

NODE_POOL=my-pool
K8S_NAMESPACE=my-ns
KSA_NAME=my-account
GSA_NAME=$KSA_NAME

```

