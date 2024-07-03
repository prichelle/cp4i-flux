oc create ns openshift-gitops-operator
oc apply -f ./config/operatorGroup.yaml
oc apply -f ./config/subscription.yaml
oc adm policy add-cluster-role-to-user cluster-admin -z openshift-gitops-argocd-application-controller -n openshift-gitops