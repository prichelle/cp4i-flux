

configMap:
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: execute-curl-script
  namespace: default
spec:
  template:
    spec:
      containers:
      - name: script-executor
        image: bitnami/kubectl:latest
        command: ["/bin/sh", "/scripts/script.sh"]
        volumeMounts:
        - name: script-volume
          mountPath: /scripts
          readOnly: true
      restartPolicy: Never
      volumes:
      - name: script-volume
        configMap:
          name: curl-script-configmap
```

Job:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: curl-script-configmap
  namespace: default
data:
  script.sh: |
    #!/bin/sh
    set -e
    while [[ $(kubectl get deploy my-application -n default -o 'jsonpath={..status.conditions[?(@.type=="Available")].status}') != "True" ]]; do
      echo "Waiting for deployment to be ready..."
      sleep 5
    done
    echo "Deployment is ready. Running curl command..."
    curl -X POST http://my-application.default.svc.cluster.local/configure
```

Job 
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: prepare-entitlement
spec:
  template:
    spec:
      containers:
      - name: copy-key
        image: bitnami/kubectl:latest
        command: ["/bin/sh", "-c"]
        args:
          - |
            kubectl get secret ibm-entitlement-key -n default -o yaml | sed 's/default/ace/g' | kubectl create -n ace -f - 
            echo "key created!"
      restartPolicy: Never
```

```yaml
# Create a script file
cat << 'EOF' > my-script.sh
#!/bin/bash
echo "Hello, this is a script stored in a ConfigMap."
# Add more script content as needed
EOF

# Create the ConfigMap with the script
kubectl create configmap my-script-config --from-file=my-script.sh
```

``` yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: secret-job
spec:
  template:
    spec:
      containers:
        - name: curl-container
          image: curlimages/curl:latest
          volumeMounts:
            - name: secret-volume
              mountPath: /etc/secret
              readOnly: true
          command: ["sh", "-c"]
          args:
            - |
              USERNAME=$(cat /etc/secret/username)
              PASSWORD=$(cat /etc/secret/password)
              echo "Running curl with secret credentials"
              curl -u $USERNAME:$PASSWORD https://example.com
      volumes:
        - name: secret-volume
          secret:
            secretName: my-secret
      restartPolicy: Never
  backoffLimit: 1
  ```

  ```yaml
  apiVersion: v1
kind: ServiceAccount
metadata:
  name: job-service-account
  namespace: default
```

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: job-cluster-role
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["pods/log"]
    verbs: ["get"]
  - apiGroups: ["batch"]
    resources: ["jobs"]
    verbs: ["create", "delete", "get", "list", "watch"]
  - apiGroups: [""]
    resources: ["secrets"]
    verbs: ["get"]
```
``` yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: job-cluster-role-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: job-cluster-role
subjects:
  - kind: ServiceAccount
    name: job-service-account
    namespace: default
```
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: kubectl-job
spec:
  template:
    spec:
      serviceAccountName: job-service-account
      containers:
        - name: kubectl-container
          image: bitnami/kubectl:latest
          command: ["sh", "-c"]
          args:
            - |
              echo "Running kubectl command"
              kubectl get pods -o json | jq '.items[] | {name: .metadata.name, namespace: .metadata.namespace}'
              echo "Running additional script"
              # Add your additional script here
              echo "Script complete"
          securityContext:
            runAsUser: 0  # Run as root
      restartPolicy: Never
  backoffLimit: 1
```

```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1beta1
kind: Kustomization
metadata:
  name: check-custom-resource-status
  namespace: flux-system
spec:
  interval: 10m0s
  path: "./path/to/job"
  prune: true
  wait: true
  healthChecks:
  - apiVersion: batch/v1
    kind: Job
    name: check-custom-resource-status
    namespace: default
  timeout: 10m
```

```
apiVersion: kustomize.toolkit.fluxcd.io/v1beta1
kind: Kustomization
metadata:
  name: custom-resource-kustomization
  namespace: flux-system
spec:
  interval: 10m0s
  path: "./path/to/custom-resource"
  prune: true
  wait: true
  healthChecks:
  - apiVersion: mycustomresources/v1
    kind: MyCustomResource
    name: my-custom-resource
    namespace: default
    jsonPath: ".status.conditions[?(@.type=='Ready')].status"
    value: "True"
  timeout: 10m
  ```