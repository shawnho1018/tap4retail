# Running distributed stress tests with K6, GKE and Workflows

This is a simple framework for running distributed stress tests with multiple instances of runners with K6, GKE and Workflows.

## Tech Stack

* [K6](https://k6.io/) - for running tests
* [k6-operator](https://github.com/grafana/k6-operator) - for orchestrating test jobs on Kubernetes
* [GKE](https://cloud.google.com/kubernetes-engine) - for spawning runners
* [Workflows](https://cloud.google.com/workflows) - for executing tests
* [Cloud Storage](https://cloud.google.com/storage) - for storing test scripts
* [Cloud Monitoring with Managed Service for Prometheus](https://cloud.google.com/managed-prometheus) - for storing test metrics

## Getting Started

Before you continue, you should already have a GKE cluster ready for running stress tests.
This framework can run on either Standard or Autopilot clusters.
You can read more about creating GKE cluster here: [standard](https://cloud.google.com/kubernetes-engine/docs/how-to/creating-a-regional-cluster) | [autopilot](https://cloud.google.com/kubernetes-engine/docs/how-to/creating-an-autopilot-cluster).

### Deploy k6-operator

k6-operator is used to orchestrate and run distributed load tests on Kubernetes.
Deploy k6-operator using `manifests/k6-operator/bundle.yaml`

```bash
kubectl apply -f manifests/k6-operator/bundle.yaml
```

### Setup the namespace for tests

Next we'll create a dedicated namespace for running tests.
In this namespace we'll also deploy a Prometheus receiver to act as a remote write target for K6.

```bash
kubectl apply -f manifests/k6-test
```

### Setup required permissions using Workload Identity

We'll bind the `default` service account in `k6-test` namespace to a service account in your GCP project with required permissions.

Create a new service account and grant the following roles using IAM:

* Monitoring Metric Writer
* Monitoring Viewer
* Kubernetes Engine Admin

Run the following command to bind the service account to the `default` service account in namespace `k6-test`:

```bash
gcloud iam service-accounts add-iam-policy-binding $SERVICE_ACCOUNT_EMAIL \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:$PROJECT_NAME.svc.id.goog[k6-test/default]"
```

Annotate the `default` service account to complete the binding:

```bash
kubectl annotate serviceaccount default \
    --namespace k6-test \
    iam.gke.io/gcp-service-account=$SERVICE_ACCOUNT_EMAIL
```

### Create a GCS bucket for storing test scripts

Create a GCS bucket for storing K6 test scripts.
Grant the service account from above permission to read the objects from the bucket.

### Create a Workflow to execute tests

Create a new Workflow to execute tests. The code is in `workflows/k6-stress-test.yaml`.
Please change the variables to match your environment at the first step of the workflow:

```yaml
main:
  params: [input]
  steps:
  - setup:
      assign:
      - clusterName: <gke cluster name>
      - clusterLocation: <gke cluster location>
      - execNamespace: k6-test
      - testScriptBucket: <gcs bucket for test scripts>
  # ...
```

## Run Test

Execute the workflow you created above from Google Cloud Console to start a new test.
You can customize your test when executing the Workflow with the following input:

```jsonc
{
  "script": "test-script-to-run.js", // required, test script to run stored in the gcs bucket
  "vus": 100, // optional, number of virutal users, default 100
  "perInstance": 100, // optional, max VU per instance, default 100
  "duration": "5m", // optional, test run duration, default 5m
  "testid": "a-custom-testid" // optional, a custom testid, default k6-test-$timestamp
}
```

## Visualize test results with Grafana

Since the test metrics are sent to Cloud Monitoring via Managed Prometheus, we can visualize the results with Grafana.
A sample dashboard is included at `grafana/dashboard.json`.
You can view result for a specific test by filtering with `testid`.
