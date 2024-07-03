To get password:

```
oc get secret openshift-gitops-cluster -o jsonpath="{.data.admin\.password}" -n openshift-gitops | base64 --decode
oc get route -n openshift-gitops openshift-gitops-server -ojsonpath='https://{.spec.host}'
```
