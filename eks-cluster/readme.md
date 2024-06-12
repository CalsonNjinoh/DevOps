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


# NGINX Ingress Controller Deployment

1. **Add the NGINX Helm repository**:
    ```bash
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    ```

2. **Update the Helm repositories**:
    ```bash
    helm repo update
    ```

3. **Install the NGINX Ingress Controller**:
    ```bash
    helm install nginx-ingress ingress-nginx/ingress-nginx
    ```

4. **Verify the installation**:
    ```bash
    kubectl get pods -n default -l app.kubernetes.io/name=ingress-nginx
    ```

5. **Get the Ingress Controller's external IP**:
    ```bash
    kubectl get services -o wide -w -n default -l app.kubernetes.io/name=ingress-nginx
    ```

### Application Deployment Using Manifest Files

1. **Create a namespace (if needed)**:
    ```bash
    kubectl create namespace <namespace>
    ```

2. **Apply the manifest files**:
    ```bash
    kubectl apply -f <manifest-file-1.yaml> -n <namespace>
    kubectl apply -f <manifest-file-2.yaml> -n <namespace>
    # Repeat for other manifest files as needed
    ```

3. **Check the status of the deployment**:
    ```bash
    kubectl get deployments -n <namespace>
    ```

4. **Check the pods to ensure they are running**:
    ```bash
    kubectl get pods -n <namespace>
    ```

5. **Describe the deployed resources (optional for debugging)**:
    ```bash
    kubectl describe deployment <deployment_name> -n <namespace>
    kubectl describe pod <pod_name> -n <namespace>
    ```

Replace `<namespace>`, `<manifest-file-1.yaml>`, `<manifest-file-2.yaml>`, `<deployment_name>`, and `<pod_name>` with your actual namespace, manifest file names, deployment name, and pod name respectively. This setup covers the process of deploying NGINX Ingress Controllers using Helm and deploying an application using Kubernetes manifest files.


##########################################



# Setting Up Secrets Management in Kubernetes with AWS Secrets Manager and CSI Driver

## Step 1: Create a Secret Manager to Store Your Secrets

In AWS, use the Secrets Manager service to create and manage your secrets. These secrets can be database credentials, on-premises resource credentials, SaaS application credentials, third-party API keys, and even Secure Shell (SSH) keys.

## Step 2: Install CSI Drivers

To install the Secrets Store CSI Driver, use Helm, the package manager for Kubernetes. Run the following commands:

```bash
helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
helm install csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver --namespace kube-system
```

For more information, visit the [official installation guide](https://secrets-store-csi-driver.sigs.k8s.io/getting-started/installation).

To verify the installation, run:

```bash
kubectl get crd -n kube-system
```

## Step 3: Set Up Integration with AWS Secrets and CSI Driver

Follow the instructions on the [official GitHub repository](https://github.com/aws/secrets-store-csi-driver-provider-aws) to set up the integration. Run the following command:

```bash
kubectl apply -f https://raw.githubusercontent.com/aws/secrets-store-csi-driver-provider-aws/main/deployment/aws-provider-installer.yaml
```

## Step 4: Create an IAM Policy

Create an IAM policy in AWS with Secrets Manager actions (describe and get secret value).

## Step 5: Associate IAM OIDC Provider

Run the following command, replacing the region and cluster name with your own:

```bash
eksctl utils associate-iam-oidc-provider --region=ca-central-1 --cluster=development-cluster --approve
```

## Step 6: Create IAM Service Account

Run the following command, replacing the region, cluster name, and policy ARN with your own:

```bash
eksctl create iamserviceaccount --name api-sa --region=ca-central-1 --cluster development-cluster --attach-policy-arn arn:aws:iam::973334513903:policy/Dev-Secrets-Read  --approve --override-existing-serviceaccounts
```

## Step 7: Deploy Your Application

Now that your secrets management setup is complete, you can deploy your application to your Kubernetes cluster.

---

Remember to replace placeholders with your actual values where necessary.


