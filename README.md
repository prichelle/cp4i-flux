# CP4I install 

# Setup

1. Create the OpenShift cluster in techZone
2. clone the repo or fork. If clone, you will need to push it back to your own repository. This is because flux needs to access the repo for read/write.
3. Install flux as described at [flux installation](https://fluxcd.io/flux/installation/)
4. Get access token for your git repo. This can be done following the steps at [github](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-fine-grained-personal-access-token)
5. Define an environment variable having the credentials that flow will use to access your github repo
export GITHUB_TOKEN=<your-token>
export GITHUB_USER=<your-username>
6. log into the cluster uisng `oc login`
7. create the entitlement key in the default repo

The key will be copied from default in the required ns.
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
8. You can pull the update made by flux

x.2 options
x.1 entitlement keys


# Additional informations
## create entitlement keys


```shell
export ENT_KEY=<your_key>
oc create secret docker-registry ibm-entitlement-key \
        --docker-username=cp \
        --docker-password=$ENT_KEY \
        --docker-server=cp.icr.io \
        --namespace=$NS
```


x.1 Create secret for key entitlement

- Create the cp4i ns and the entitlement key in the cp4i

- Add in the cluster folder the required installation. Example available in ./kustomize/cluster-config


# 5. Create entitlement registry key

# 6. Install Software
## 6.1 Install platform navigator (pn)
Verify operators are well started (especially RHOCP Keycloak)
06-1-pn-inst.yaml
-> install operator: rhbk-operator-xxxx
-> install catalog source: integration-ibm-cloud-native-postgresql-xxxx
-> install operator postgres: postgresql-operator-controller-manager-xxxx
-> install keycloak


```shell
#user
oc -n cp4i get secret integration-admin-initial-temporary-credentials -o jsonpath={.data.username} | base64 -d
#pwd
oc -n cp4i get secret integration-admin-initial-temporary-credentials -o jsonpath={.data.password} | base64 -d
#host
oc -n cp4i get platformnavigator cp4i-navigator -o jsonpath='{range .status.endpoints[?(@.name=="navigator")]}{.uri}{end}'
```

## 6.2 Install ACE
- Install Dashboard 
  Dashboard is using a RWX storage class. Update the value accordingly to your configuration.  
  Yaml file to apply: 06-2-ace-dash-inst.yaml
- Install Designer
  Designer is using a RWO (block) storage. Update the value of the couchDb storage accordingly.  
  The AI incremental model can be optionally stored on a RWX storage (EFS or S3). Not needed for this deployment.  
  Yaml file to apply: 06-2-ace-design-inst.yaml
## 6.3 Install APIC cluster

APIC is using block storage, adapt the configuration file accordingly.  
Yaml file to apply: 06-3-apic-inst.yaml

```shell
#host gtw
oc -n cp4i get GatewayCluster -o=jsonpath='{.items[?(@.kind=="GatewayCluster")].status.endpoints[?(@.name=="gateway")].uri}'
#host cloud admin
oc -n cp4i get APIConnectCluster -o=jsonpath='{.items[?(@.kind=="APIConnectCluster")].status.endpoints[?(@.name=="admin")].uri}'
#host manager
oc -n cp4i get ManagementCluster -o=jsonpath='{.items[?(@.kind=="ManagementCluster")].spec.adminUser.secretName}'
#host portal
oc -n $MY_APIC_PROJECT get PortalCluster -o=jsonpath='{.items[?(@.kind=="PortalCluster")].status.endpoints[?(@.name=="portalWeb")].uri}'
```
## 6.4 Install AssetRepo

Asset repo is using block storage, adapt the configuration file accordingly.  
Yaml file to apply: 06-6-asset-repo-ai-inst.yaml

## 6.5 Install MQ

MQ is using block storage, adapt the configuration file accordingly.  
Yaml file to apply: 
- MQ Configuration: 88-1-MQ-mainmqm-cm.yaml
- MQ Installation: 88-2-MQ-mainmqm-cr.yaml 


# API Connect configuration

## Dummy mail server

```shell
oc -n cp4i new-app mailhog/mailhog
oc -n cp4i expose svc/mailhog --port=8025 --name=mailhog
```

## Configure 

# Uninstall PN

oc delete pn cp4i-navigator

```
c328aaa28a153afc8d2766acc4c73f81cf5e98aa2dc24fa9d94f28661cvhvpf   0/1     Completed   0               5d12h
cp4i-navigator-ibm-integration-platform-navigator-deploymewkxlp   2/2     Running     0               5d12h
create-postgres-license-config-6j6jz                              0/1     Completed   0               5d12h
cs-cloudpak-realm-2jfpx                                           0/1     Completed   0               5d12h
cs-keycloak-0                                                     1/1     Running     0               5d12h
ibm-common-service-operator-565b97647d-h4nx6                      1/1     Running     0               5d13h
ibm-integration-platform-navigator-operator-7fdcfb78f-twv86       1/1     Running     0               5d12h
integration-ibm-cloud-native-postgresql-cbbsb                     1/1     Running     0               5d12h
keycloak-edb-cluster-1                                            1/1     Running     0               5d12h
operand-deployment-lifecycle-manager-854dfcd546-dzzc5             1/1     Running     0               5d13h
postgresql-operator-controller-manager-1-18-7-764b8b4ddf-n6vkc    1/1     Running     0               5d12h
rhbk-operator-6d86496885-74gb2                                    1/1     Running     0               5d12h
```
