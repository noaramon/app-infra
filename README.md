# Simple Time Application
Simple time application
1) Create an application on Go/Python that serve HTTP requests at the next routes:
   - 8080:/
   - 8080:/health 
   - / - returns local time in New-York, Berlin, Tokyo in HTML format
   - /health - return status code 200, in JSON format
2) Dockerize your app.
3) Provision your infra using Terraform:
   - VPC
   - Subnets
   - SGs
   - Routing tables
   - EKS cluster
   - ECR
4) Create and deploy Helm3 chart for your application.
5) Ensure that you have an access to the application endpoint externally
6) Provide an external http link
7) Upload your code to the Github public repository and provide link to us (put your code to the app, terraform, helm folders accordingly)

### NTH
##### AWS:
- [ ] Create AWS role for Terragrunt

##### Terraform/Terragrunt:
- [ ] AWS provider access - allow multiple accounts
- [ ] Expend EKS module with add-ons, helm provider
- [ ] Fixed Versions
- [ ] Docs

##### Helm:
- [ ] Insert [manual step to bootstrap](https://github.com/aws/eks-charts/tree/master/stable/aws-vpc-cni#adopting-the-existing-aws-node-resources-in-an-eks-cluster)
- [ ] Expend default chart (templates)


### Todo
- [ ] Configure route53 to route the ALB
- [ ] Modular TF modules
- [ ] Push Self-owned chart to registry and add it to the terragrunt automation

### In Progress


### Done ✓
- [X] Create an application on Go/Python that serve HTTP requests at the next routes:
   - 8080:/
   - 8080:/health 
   - / - returns local time in New-York, Berlin, Tokyo in HTML format
   - /health - return status code 200, in JSON format
- [X] Dockerize your app.
- [X] Provision your infra using Terraform:
   - VPC
   - Subnets
   - SGs
   - Routing tables
   - EKS cluster
   - ECR
- [X] Wrapped with Terragrunt(Extra)
- [X] Create and deploy Helm3 chart for your application.
- [X] Ensure that you have an access to the application endpoint externally
- [ ] Provide an external http link
- [X] Upload your code to the Github public repository and provide link to us (put your code to the app, terraform, helm folders accordingly)

### Runbook from scratch (new environment)
1. Authenticate with AWS
2. Run: ```terragrunt run-all apply```
4. helm upgrade --install <<example-release>> <<chart-path>> --namespace <<example-namespace>>