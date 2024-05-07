# Cluster configuration

- Install flux

- Generate token to access the git repo and set the env variable that will be used by flux
export GITHUB_TOKEN=<your-token>
export GITHUB_USER=<your-username>

- log into the cluster

- bootstrap the cluster with flux  
The path with the command needs to be unique for each cluster  
The bootstrap will generate everything on the cluster and on the git

- Run the command setup ocp (for the security)

- git pull to get the cluster configuration

- update the patches of the kustomization (in cluster path)




