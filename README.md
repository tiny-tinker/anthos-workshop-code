# Anthos Workshop
This is the code repo for all the commands we'll use in the workshop. 

Handy code snippets

```bash
 # Get creds for kubectl
 gcloud container clusters get-credentials $CLUSTER_NAME \
    --project=$PROJECT_ID --zone=$ZONE
```

If you lose your shell session, you'll need to refresh the env vars:

```
source setvars.env
```


