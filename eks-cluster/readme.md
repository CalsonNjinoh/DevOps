**Kubernetes Commands Cheat Sheet**

| **Command** | **Usage** |
|-------------|------------|
| `aws eks --region <region> update-kubeconfig --name <cluster_name>` | Configure `kubectl` to use an EKS cluster. |
| `kubectl get nodes` | List all nodes in the cluster. |
| `kubectl get pods` | List all pods in the default namespace. |
| `kubectl get pods --all-namespaces` | List all pods in all namespaces. |
| `kubectl get services` | List all services in the default namespace. |
| `kubectl get deployments` | List all deployments in the default namespace. |
| `kubectl describe node <node_name>` | Show detailed information about a node. |
| `kubectl describe pod <pod_name>` | Show detailed information about a pod. |
| `kubectl logs <pod_name>` | Print the logs for a pod. |
| `kubectl exec -it <pod_name> -- /bin/bash` | Open a bash shell in a running pod. |
| `kubectl apply -f <file.yaml>` | Apply a configuration to a resource by filename or stdin. |
| `kubectl create -f <file.yaml>` | Create a resource from a file or stdin. |
| `kubectl delete -f <file.yaml>` | Delete resources by filenames, stdin, resources, and names. |
| `kubectl scale --replicas=<number> deployment/<deployment_name>` | Scale a deployment to a specified number of replicas. |
| `kubectl rollout restart deployment/<deployment_name>` | Restart a deployment. |
| `kubectl rollout status deployment/<deployment_name>` | Show the status of the rollout for a deployment. |
| `kubectl set image deployment/<deployment_name> <container_name>=<new_image>` | Update the image of a container in a deployment. |
| `kubectl port-forward <pod_name> <local_port>:<remote_port>` | Forward one or more local ports to a pod. |
| `kubectl get configmap` | List all ConfigMaps in the default namespace. |
| `kubectl describe configmap <configmap_name>` | Show detailed information about a ConfigMap. |
| `kubectl get secret` | List all secrets in the default namespace. |
| `kubectl describe secret <secret_name>` | Show detailed information about a secret. |
| `kubectl top nodes` | Display resource (CPU/memory) usage of nodes. |
| `kubectl top pods` | Display resource (CPU/memory) usage of pods. |
| `kubectl get namespaces` | List all namespaces. |
| `kubectl create namespace <namespace>` | Create a new namespace. |
| `kubectl delete namespace <namespace>` | Delete a namespace. |
| `kubectl config get-contexts` | List the contexts available in the kubeconfig file. |
| `kubectl config use-context <context>` | Set the current-context in the kubeconfig file. |
| `kubectl get events` | List all events in the default namespace. |


**Helm Cheat Sheat**

| **Command** | **Usage** |
|-------------|-----------|
| `helm repo add <repo_name> <repo_url>` | Add a Helm repository. |
| `helm repo update` | Update all Helm repositories to get the latest charts. |
| `helm search repo <keyword>` | Search for a keyword in all Helm repositories. |
| `helm install <release_name> <chart_name>` | Install a chart with a specified release name. |
| `helm upgrade <release_name> <chart_name>` | Upgrade a release to a new chart or version. |
| `helm rollback <release_name> <revision>` | Rollback a release to a previous revision. |
| `helm list` | List all releases in the current namespace. |
| `helm list --all-namespaces` | List all releases in all namespaces. |
| `helm uninstall <release_name>` | Uninstall a release. |
| `helm status <release_name>` | Display the status of a release. |
| `helm history <release_name>` | Display the revision history for a release. |
| `helm show chart <chart_name>` | Show the details of a chart. |
| `helm show values <chart_name>` | Show the default values of a chart. |
| `helm get all <release_name>` | Get all information about a release. |
| `helm get values <release_name>` | Get the values for a release. |
| `helm package <chart_directory>` | Package a chart directory into a chart archive. |
| `helm template <chart_name>` | Generate Kubernetes manifest files from a chart. |
| `helm repo remove <repo_name>` | Remove a Helm repository. |
| `helm lint <chart_directory>` | Run a linting check on a chart. |
| `helm dependency update` | Update chart dependencies from `Chart.yaml`. |
| `helm pull <chart_name>` | Download a chart to your local directory. |
| `helm diff upgrade <release_name> <chart_name>` | Show a diff explaining what a helm upgrade would change. Requires `helm diff` plugin. |
| `helm test <release_name>` | Run tests for a release. |
| `helm create <chart_name>` | Create a new chart with the specified name. |
| `helm env` | Display Helm environment information. |
| `helm plugin list` | List installed Helm plugins. |
| `helm plugin install <plugin_url>` | Install a Helm plugin from a URL. |


