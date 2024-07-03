oc create ns openshift-gitops-operator
oc apply -f ./config/operatorGroup.yaml
oc apply -f ./config/subscription.yaml