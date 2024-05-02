# cp4i-rosa

# 1. Set default storage

On the ebs class storage
```yaml
metadata:
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
```
[Supported storage matrix](https://www.ibm.com/docs/en/cloud-paks/cp-integration/2023.4?topic=cloud-supported-options-amazon-web-services-aws)
# 2. Check Cert manager setup

Optionally
``` shell
oc apply -f resources/00-cert-manager-namespace.yaml
oc apply -f resources/00-cert-manager-operatorgroup.yaml
oc apply -f resources/00-cert-manager-subscription.yaml
```

# 3. Catalog Source
Install catalog source for all operators
[CatalogSource](https://www.ibm.com/docs/en/cloud-paks/cp-integration/2023.4?topic=images-adding-catalog-sources-cluster#ibm-catalog)

# 4. Install Operators

Foundational Service: 04-1-CPFoundationalService.yaml
-> Install common service operator
-> Install ODLM operator
oc -n cp4i patch commonservice common-service --type merge -p '{"spec": {"license": {"accept": true}}}'

Platform Navigator: 04-2-pn-subs.yaml
--> install the integration platform navigator operator

Asset Repo: 04-3-asset-repo-subs.yaml
API Connect: 04-4-api-connect-subs.yaml
APP Connect: 04-5-app-connect-subs.yaml
MQ: 04-6-mq-subs.yaml

# 5. Create entitlement registry key
```shell
export ENT_KEY=<your_key>

oc create secret docker-registry ibm-entitlement-key \
        --docker-username=cp \
        --docker-password=$ENT_KEY \
        --docker-server=cp.icr.io \
        --namespace=$NS
```

# 6. Install Software
## 6.1 Install PN
Verify operators are well started (especially RHOCP Keycloak)
06-1-pn-inst.yaml
-> install operator: rhbk-operator-xxxx
-> install catalog source: integration-ibm-cloud-native-postgresql-xxxx
-> install operator postgres: postgresql-operator-controller-manager-xxxx
-> install keycloak

user
oc -n cp4i get secret integration-admin-initial-temporary-credentials -o jsonpath={.data.username} | base64 -d
pwd
oc -n cp4i get secret integration-admin-initial-temporary-credentials -o jsonpath={.data.password} | base64 -d
host
oc -n cp4i get platformnavigator cp4i-navigator -o jsonpath='{range .status.endpoints[?(@.name=="navigator")]}{.uri}{end}'


## 6.2 Install ACE
Install Dashboard 
06-2-ace-dash-inst.yaml
Install Designer
06-2-ace-design-inst.yaml
## 6.3 Install APIC cluster
06-3-apic-inst.yaml

host gtw
oc -n cp4i get GatewayCluster -o=jsonpath='{.items[?(@.kind=="GatewayCluster")].status.endpoints[?(@.name=="gateway")].uri}'
host cloud admin
oc -n cp4i get APIConnectCluster -o=jsonpath='{.items[?(@.kind=="APIConnectCluster")].status.endpoints[?(@.name=="admin")].uri}'
host manager
oc -n cp4i get ManagementCluster -o=jsonpath='{.items[?(@.kind=="ManagementCluster")].spec.adminUser.secretName}'
host portal
oc -n $MY_APIC_PROJECT get PortalCluster -o=jsonpath='{.items[?(@.kind=="PortalCluster")].status.endpoints[?(@.name=="portalWeb")].uri}'
## 6.4 Install AssetRepo


