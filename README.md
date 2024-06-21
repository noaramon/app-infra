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
- [ ] Expend default chart


### Todo
- [ ] Solve liveness and readiness probes (same issue as unhealthy registered target in the ALB's TG)
- [ ] Configure route53 to route the ALB

### In Progress
- [ ] Solve liveness and readiness probes

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
- [ ] Ensure that you have an access to the application endpoint externally
- [ ] Provide an external http link
- [X] Upload your code to the Github public repository and provide link to us (put your code to the app, terraform, helm folders accordingly)
- [ ] Alternative to AWS ALB controller(Extra)

### Runbook from scratch (new environment)
1. Authenticate with AWS
2. Run: ```terragrunt run-all apply```
3. Create SA for AWS LB controller ```kube-system/aws-load-balancer-controller```:
```
eksctl create iamserviceaccount \                                                                                      
--cluster=example-eks \
--namespace=kube-system \
--name=aws-load-balancer-controller \
--attach-policy-arn=arn:aws:iam::092988563851:policy/AWSLoadBalancerControllerIAMPolicy \
--approve
```
4. Install AWS LB Controller with helm:
``` 
helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=example-eks --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller --set vpcId=vpc-0d700774bc34bbb97 --set region=us-east-1 --set serviceAccount.name=aws-load-balancer-controller
```
4. helm upgrade --install <<example-release>> <<chart-path>> --namespace <<example-namespace>>