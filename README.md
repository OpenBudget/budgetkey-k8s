# The BudgetKey Kubernetes Environment

The Budgetkey Kubernetes environment manages most Budgetkey infrastructure as code.

The root of this repository is a Helm chart with helm charts under [charts-external](/charts-external) defined as dependencies of this chart.
The dependencies are defined in [Chart.yaml](/Chart.yaml). 

Values are defined in the following Helm value files:

* [values-global.yaml](/values-global.yaml) - global values - should be relevant for any environment
* [values-hasadna.yaml](/values-hasadna.yaml) - values which are specific for Hasadna's production Kubernetes cluster
* [values.auto-updated.yaml](/values.auto-updated.yaml) - values which are auto-updated by CI/CD from other repositories.

This chart is continuously synced to Hasadna cluster via ArgoCD as defined [here](https://github.com/hasadna/hasadna-k8s/blob/master/apps/hasadna-argocd/templates/).

Local development can be done by installing either this root helm chart or any of the dependant charts to your local Kubernetes cluster using Helm.

## Common Tasks

All code assumes you are inside a bash shell with required dependencies and connected ot the relevant environment

### Adding an external app

* Duplicate and modify an existing chart under `charts-external` directory
* Setup the external app's continuous deployment
  * Copy the relevant steps from an existing app's [.travis.yml](https://github.com/OriHoch/socialmap-app-main-page/blob/master/.travis.yml)
  * Also, suggested to keep deployment notes in the app's [README.md](https://github.com/OriHoch/socialmap-app-main-page/blob/master/README.md#deployment)
  * Follow the app's README to setup Docker and GitHub credentials on Travis

### Modifying secrets

Secrets are stored and managed directly in kubernetes and are not managed via Helm.

To update an existing secret, delete it first `kubectl delete secret SECRET_NAME`

After updating a secret you should update the affected deployments, you can use `./force_update.sh` to do that

All secrets should be optional so you can run the environment without any secretes and will use default values similar to dev environments.

Each environment may include a script to create the environment secrets under `environments/ENVIRONMENT_NAME/secrets.sh` - this file is not committed to Git.

You can use the following snippet in the secrets.sh script to check if secret exists before creating it:

```
! kubectl describe secret <SECRET_NAME> &&\
  kubectl create secret generic <SECRET_NAME> <CREATE_SECRET_PARAMS>
```
