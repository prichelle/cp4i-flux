# CP4I install 

This repo can be used to install the CP4I on a openShift cluster.
The current version install
- the different operators capabilities of the cp4i using a cluster role
  - platform navigator, ace, mq, apic, eventstreams and eventendpointmanagement
  - namespace cp4i for pn, ace for MQ and APP Connect, apic for API Connect
- capabilities installed: 
  - CP4I Platform navigator
  - IBM API Connect with an api connect instance apic-demo
  - IBM App Connect with an instance of a Dashboard and a DesignerAuthoring
  - IBM MQ with an instance of a queue manager


## config

The possible properties such as the version to use can be adapted in the file ./kustomize/config/default-config.yaml

## prereqs

The installation uses
- flux: Install flux as described at [flux installation](https://fluxcd.io/flux/installation/)
- openshift OC cli

You will also need an entitlement key

## Setup

1. Create the OpenShift cluster in techZone
2. clone the repo or fork. If clone, you will need to push it back to your own repository. This is because flux needs to access the repo for read/write.
3. Get access token for your git repo. This can be done following the steps at [github](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-fine-grained-personal-access-token)
4. Define an environment variable having the credentials that flow will use to access your github repo
export GITHUB_TOKEN=<your-token>
export GITHUB_USER=<your-username>
5. log into the cluster uisng `oc login`
6. create the entitlement key in the `default` namespace

The key will be copied automatically by the installation from the default namespace in the required namespaces.

[Entitlement keys](https://myibm.ibm.com/products-services/containerlibrary)

```shell
export ENT_KEY=<your_key>

oc create secret docker-registry ibm-entitlement-key \
        --docker-username=cp \
        --docker-password=$ENT_KEY \
        --docker-server=cp.icr.io \
        --namespace=default

```

7. You can now bootstrap the cluster. This command will create in your cluster a ns "flux-system" which will connect to your repo and install the CP4I using Kustomization

```shell
flux bootstrap github --owner=$GITHUB_USER --repository=$YOUR_REPO --branch=main --path=./clusters/techzone
```
8. You can pull the update made by flux from your git repo 

A UI (Waeve GitOps) is also installed to visualize the installation.
The host can be found by looking at the route in the project "flux-system".
```shell
kubectl get route "gitops" -o jsonpath="{.spec.host}" -n flux-system
```

# Flux commands

Check the installation:
```shell
flux get kustomizations
```
You should have something similar:

```
AME                    	REVISION          	SUSPENDED	READY  	MESSAGE
app-api-connect         	main@sha1:36309066	False    	True   	Applied revision: main@sha1:bdf9597b
app-app-connect         	main@sha1:bdf9597b	False    	True   	Applied revision: main@sha1:bdf9597b
catalog-sources         	main@sha1:bdf9597b	False    	True   	Applied revision: main@sha1:bdf9597b
flux-system             	main@sha1:bdf9597b	False    	True   	Applied revision: main@sha1:bdf9597b
gitops-ui               	main@sha1:bdf9597b	False    	True   	Applied revision: main@sha1:bdf9597b
ibm-platform-navigator  	main@sha1:bdf9597b	False    	True   	Applied revision: main@sha1:bdf9597b
inst-mq                 	main@sha1:bdf9597b	False    	True   	Applied revision: main@sha1:bdf9597b
inst-platform-nav       	main@sha1:bdf9597b	False    	True   	Applied revision: main@sha1:bdf9597b
int-instances           	main@sha1:bdf9597b	False    	True   	Applied revision: main@sha1:bdf9597b
operator-cert-manager   	main@sha1:bdf9597b	False    	True   	Applied revision: main@sha1:bdf9597b
operator-common-service 	main@sha1:bdf9597b	False    	True   	Applied revision: main@sha1:bdf9597b
operator-ibm-integration	main@sha1:bdf9597b	False    	True   	Applied revision: main@sha1:bdf9597b
platform                	main@sha1:bdf9597b	False    	True   	Applied revision: main@sha1:bdf9597b
```

You can force an update of a kustomization using
```shell
flux reconcile kustomization inst-platform-nav
```

To uninstall flux:
```shell
flux uninstall --namespace=flux-system
```

To check the git repo and helm source (used for the ui):
```shell
flux get sources all -A
```

you can resume and restart a kustomization (useful if you made direct change on the resource in the cluster)
```shell
flux resume kustomizations --all
flux suspend kustomizations --all
```

You can get logs from flux related to the kustomization:
```shell
flux logs --kind=Kustomization --since=2h
```
