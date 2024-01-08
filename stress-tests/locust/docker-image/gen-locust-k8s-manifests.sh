#!/bin/bash
export LOCUST_IMAGE_NAME=locust-tasks
export LOCUST_IMAGE_TAG=latest
export GKE_CLUSTER=gke-lt-cluster
export PROJECT=shawnho-demo-2023
export AR_REPO=my-repo
export REGION=asia-east1
export SAMPLE_APP_TARGET="http://python-guestbook-frontend.default.svc"


mkdir -p k8s-manifests/
envsubst < ../kubernetes-config/locust-master-controller.yaml.tpl > k8s-manifests/master-controller.yaml
envsubst < ../kubernetes-config/locust-worker-controller.yaml.tpl > k8s-manifests/worker-controller.yaml
envsubst < ../kubernetes-config/locust-master-service.yaml.tpl > k8s-manifests/master-service.yaml
