# Simple app
This is a simple web app that returns counter on how many times page has been seen.
The application is using redis to store the count.

It also has an endpoint protected by basic http auth that will provide you with a secret string.

## How to start locally
`docker-compose up`

## Endpoints
* `GET /` - path shows hello message with a counter on how many time the page has been visited.
* `GET /supersecret` - this path requires basic http authentication and it will tell you a super secret.

-----------------------------------

# Deployment

## Prerequisites

### State storage

Kubernetes & Terraform both use AWS S3 for remote state storage and Terraform also uses a DynamoDB table to enable state locking. Whilst a fully managed cluster configuration is outside of the scope of this assignment, we can bootstrap state management in Kubernetes & Terraform with the Terraform configuration in `terraform/state-init`

```
cd terraform/state-init
terraform init
terraform apply
```

#### Assignment caveat:

Bucket versioning is not enabled to ensure cleaner tear-down for project resources in the context of this assignment. 

### Kubernetes

The two deployment solutions in this package assume the existence of a deployed HA Kubernetes cluster
launched with the below configuration and with [aws-iam-authenticator](https://github.com/kubernetes-sigs/aws-iam-authenticator) installed and configured
following the AWS documentation [here](https://aws.amazon.com/blogs/opensource/deploying-aws-iam-authenticator-kubernetes-kops/).

```
kops create cluster \
  --cloud=aws \
  --node-count 3 \
  --zones eu-west-1a,eu-west-1b,eu-west-1c \
  --master-zones eu-west-1a,eu-west-1b,eu-west-1c \
  --node-size t3.medium \
  --master-size t3.medium \
  --topology private \
  --networking kopeio-vxlan \
  --bastion \
  --encrypt-etcd-storage \
  kube.example.com
```

Cluster authentication is provided by AWS IAM with RBAC authorization. See `INSTALL.md` for more details. 

## Build

Application Docker image is created by running the build script: 

`./build.sh`

This will simply build the image and push it to DockerHub making it available to be pulled later during the release phase. Shebang is currently set for `zsh` so `bash` users will need to be mindful to change that. 

#### Assignment caveat:

For production deployments I would usually opt for an integrated build/release/run pipeline embeded within a full PaaS solution such as [this provided by Workflow](https://docs.teamhephy.com/understanding-workflow/concepts/#build-release-run), however deploying Workflow in the context of this assignment wouldn't allow me to demonstrate my knowledge of lower level resources and concepts so I've chosen not to use it in this case. 

## Release

### Overview

This package contains two solutions to deploy the web application to the cluster: 

1. `terraform/deployments/terraform`

    Pure Terraform solution that will provision two modules:
   
    * `terraform/modules/services/redis`
    
      An ElasticCache Redis cluster deployed into a `services` subnet and configured to allow access from the Kubernetes `node` subnets.
  
    * `terraform/modules/app`
    
      A collection of Kubernetes resources: 
      * A Namespace to contain resources
      * A Secret containing the application's environment variables
      * A Deployment to handle pod orchestration
      * A Service to handle network orchestration

2. `terraform/deployments/terraform_helm`

    Hybrid solution that deploys `terraform/modules/services/redis`, generates a Namespace and then uses the Terraform Helm Provider to configure and deploy the web application using the specification in the Helm chart located in the `chart/` directory. 

Usage for both solutions is identical:

`cd terraform/deployments/${SOLUTION}`

`terraform init`

`terraform apply`

Terraform specific & Provider configuration is in the `config.tf` files with deployment specific configuration available in the `variables.tf` files. 

See `INSTALL.md` for more detailled instructions.
