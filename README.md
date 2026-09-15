## terraform-aws-eks-platform
Production-style AWS EKS platform built with Terraform, featuring multi-AZ VPC networking, Spot worker nodes, IRSA, RDS MySQL, Secrets Manager, KMS-encrypted S3, and remote Terraform state management.

## Project Structure

```text
terraform-aws-eks-platform/
├── .gitignore
├── README.md
├── bootstrap/
│   ├── main.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── terraform.tfvars.example
│   └── variables.tf
│
├── infrastructure/
│   ├── backend.tf
│   ├── backend.hcl.example
│   ├── data.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── terraform.tfvars.example
│   ├── variables.tf
│   ├── versions.tf
│   │
│   └── modules/
│       ├── network/
│       │   ├── main.tf
│       │   ├── outputs.tf
│       │   └── variables.tf
│       │
│       ├── eks/
│       │   ├── main.tf
│       │   ├── outputs.tf
│       │   └── variables.tf
│       │
│       ├── irsa/
│       │   ├── main.tf
│       │   ├── outputs.tf
│       │   └── variables.tf
│       │
│       ├── database/
│       │   ├── main.tf
│       │   ├── outputs.tf
│       │   └── variables.tf
│       │
│       └── storage/
│           ├── main.tf
│           ├── outputs.tf
│           └── variables.tf
│
└── scripts/
    └── demo.sh
```

| Directory           | Purpose                                                                                                 |
| ------------------- | ------------------------------------------------------------------------------------------------------- |
| `bootstrap/`        | Creates the S3 remote-state bucket and DynamoDB locking table. Run once before the main infrastructure. |
| `infrastructure/`   | Main Terraform root module used to deploy the AWS environment.                                          |
| `modules/network/`  | VPC, public/private subnets, NAT Gateway and routing.                                                   |
| `modules/eks/`      | EKS cluster and Spot managed node group.                                                                |
| `modules/irsa/`     | Pod-specific IAM role and IRSA configuration.                                                           |
| `modules/database/` | RDS MySQL and database networking.                                                                      |
| `modules/storage/`  | KMS-encrypted S3 raw-data bucket.                                                                       |
| `scripts/`          | Commands/scripts used during the live demonstration.                                                    |

## Prerequisites

Terraform >= 1.10
AWS CLI v2
kubectl
Git
An AWS account with sufficient permissions

Verify:
```bash
terraform version
aws --version
kubectl version --client
git --version
aws sts get-caller-identity
```
## Deployment

### 1. Remote State
This stack creates: S3 state bucket, S3 versioning, State encryption & DynamoDB lock table
```bash
cd bootstrap
terraform init
terraform validate
terraform plan
terraform apply
```
### 2. Configure Backend
```bash
cd ../infrastructure
terraform init -backend-config=..\environments\dev\backend.hcl
terraform init -reconfigure -backend-config="..\environments\dev\backend.hcl"
```
### 3. Deploy Infrastructure
```bash
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan | terraform plan -var-file "../environments/dev/terraform.tfvars"
terraform apply -var-file "../environments/dev/terraform.tfvars"
```
### 4. Verify eks
```bash
kubectl get nodes -o wide 
kubectl get pods -A
kubectl get nodes -L eks.amazonaws.com/capacityType
```
## 5. Verify IRSA
```bash
kubectl describe serviceaccount app-service-account -n app
```
### 6. Destroy Infrastructure
```bash
cd infrastructure
terraform destroy
```
### 7. Flask App
```bash
docker build -t flask-app:v2 . 
docker tag eks-sre-flask:v2 <YOUR-ECR-URL>:v2
docker push <YOUR-ECR-URL>:v2
```
### 8. Helm
```bash
helm lint .\helm\flask-app
helm install flask-app .\helm\flask-app `  --namespace app
helm list -n app
kubectl get pods -n app   
kubectl get svc -n app
curl <LB_ARN>  <a34761f66f66944c591c1ec2ddec25d0-1523501769.us-west-2.elb.amazonaws.com/>
helm uninstall flask-app -n app
```

### 9. Logs
```bash
aws eks update-kubeconfig --region us-west-2  --name eks-platform-dev
kubectl logs -n app deployment/flask-app
kubectl get pods -n app
kubectl logs deployment/flask-app -n app -c flask-app --tail=50
kubectl get deployment flask-app -n app -o jsonpath="{.spec.template.spec.containers[*].name}"
kubectl logs deployment/flask-app -n app -c fluent-bit --tail=50
kubectl get deployment flask-app -n app -o jsonpath="{.spec.template.spec.serviceAccountName}"
kubectl get sa flask-app -n app -o yaml
kubectl exec deployment/flask-app -n app -c fluent-bit -- env | Select-String "AWS_ROLE_ARN|AWS_WEB_IDENTITY"
aws logs describe-log-streams --log-group-name /eks/flask-app --region us-west-2
aws logs get-log-events --log-group-name /eks/flask-app --log-stream-name flask-flask.app --region us-west-2
kubectl logs deployment/flask-app -n app -c fluent-bit --since=5m
aws logs tail /eks/flask-app --follow --region us-west-2
aws logs tail /eks/flask-app --since 5m --region us-west-2
```

### 10. Metric Server
```bash
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update
helm upgrade --install metrics-server metrics-server/metrics-server `  --namespace kube-system
kubectl get pods -n kube-system | Select-String metrics-server
```

### 10. HPA
```bash
kubectl get hpa -n app
kubectl describe hpa flask-app -n app  
kubectl get hpa -n app -w 
hey -z 5m -c 100 "http://<LB-DNS>/work?n=200000"
```

### 11. RBAC
```bash
aws eks create-access-entry  --cluster-name eks-platform-dev --principal-arn arn:aws:iam::590183658640:role/eks-platform-jenkins-role  --region us-west-2
aws eks associate-access-policy  --cluster-name eks-platform-dev --principal-arn arn:aws:iam::590183658640:role/eks-platform-jenkins-role  --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy  --access-scope type=cluster  --region us-west-2

aws eks create-access-entry --cluster-name eks-platform-dev --principal-arn arn:aws:iam::590183658640:role/eks-platform-jenkins-role --type STANDARD --kubernetes-groups jenkins-deployer --region us-west-2
kubectl apply -f jenkins-rbac.yaml
aws eks update-kubeconfig --region us-west-2 --name eks-platform-dev
kubectl get role,rolebinding -n app
kubectl get pods -n app
```

### 12. Post Deplloyment Checks
Verify application + Fluent Bit:
```bash
helm list -n app
kubectl get pods -n app
kubectl get pods -n app -o jsonpath="{range .items[*]}{.metadata.name}{': '}{range .spec.containers[*]}{.name}{' '}{end}{'\n'}{end}"
kubectl get deployment flask-app -n app -o=jsonpath='{.spec.template.spec.containers[0].image}'
kubectl rollout status deployment/flask-app -n app
```
Resource allocation: 
```bash
kubectl top pods -n app --containers
```
Verify probes:
```bash
kubectl describe deployment flask-app -n app
```
Verify CloudWatch logging:
```bash
kubectl logs -n app deployment/flask-app -c fluent-bit --tail=30
kubectl get endpoints -n app
kubectl get svc -n app
curl http://<LB-DNS>/health
```
Verify Metrics Server
```bash
kubectl get deployment metrics-server -n kube-system
```
Verify HPA
```bash
kubectl get hpa -n app
kubectl describe hpa flask-app -n app
```
HPA scalability
```bash
kubectl get hpa,pods -n app -w
hey -z 5m -c 100 "http://<LB-DNS>/work?n=200000"
```

### 12. Obervability
```bash
kubectl create namespace monitoring
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack  -n monitoring  -f .\observability\prometheus-values.yaml
kubectl get pods -n monitoring
```
