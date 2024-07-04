

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