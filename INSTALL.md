# Installation

Initialise Terraform & Kubernetes State storage:

```
cd terraform/state-init/
terraform init
terraform apply
```

Set cluster variables:

```
export NAME=kube.example.com
export KOPS_STATE_STORE=s3://bloomreach-k8s-state-store
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query 'Account')
```

Create cluster config:

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
  ${NAME}
```

Edit cluster config:

```
kops edit cluster --name ${NAME}
```

Add the `authentication` stanza to cluster config:
```
# ...
spec:
  # ...
  authentication:
    aws: {}
  authorization:
    rbac: {}
```

Update cluster config and deploy resources:

```
kops update cluster --name ${NAME} --yes
```

Verify cluster is being created (this will take a while to show informative output):

```
kops validate cluster --name ${NAME}
```

`aws-iam-authenticator` pods won't pass validation, so move to the next step once you see something like this:

```
VALIDATION ERRORS
KIND    NAME                                    MESSAGE
Pod     kube-system/aws-iam-authenticator-99fvr kube-system pod "aws-iam-authenticator-99fvr" is pending
Pod     kube-system/aws-iam-authenticator-pz4wx kube-system pod "aws-iam-authenticator-pz4wx" is pending
Pod     kube-system/aws-iam-authenticator-vjm7j kube-system pod "aws-iam-authenticator-vjm7j" is pending
```

Create IAM Role & Policy with `aws` cli:

```
export POLICY=$(echo -n '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"AWS":"arn:aws:iam::'; echo -n "$ACCOUNT_ID"; echo -n ':root"},"Action":"sts:AssumeRole","Condition":{}}]}')
aws iam create-role \
  --role-name KubernetesAdmin \
  --description "Kubernetes administrator role (for AWS IAM Authenticator for AWS)." \
  --assume-role-policy-document "$POLICY" \
  --output text \
  --query 'Role.Arn'
```

Generate a ConfigMap:

```
cat > aws-auth.yaml <<EOF
---
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: kube-system
  name: aws-iam-authenticator
  labels:
    k8s-app: aws-iam-authenticator
data:
  config.yaml: |    
    clusterID: ${NAME}
    server:
      mapRoles:
      - roleARN: arn:aws:iam::${ACCOUNT_ID}:role/KubernetesAdmin
        username: kubernetes-admin
        groups:
        - system:masters
EOF
```
Apply ConfigMap to cluster:

```
kubectl apply -f aws-auth.yaml
```

Verify aws-iam-authenticator pods are now healthy:

```
kops validate cluster --name ${NAME}
```


Add `aws-iam-authenticator` user to `kubeconfig`:
```
users:
- name: ${NAME}.exec
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${NAME}"
        - "-r"
        - "arn:aws:iam::${ACCOUNT_ID}:role/KubernetesAdmin"
```

Apply Terraform resources to cluster to deploy applications:

```
cd terraform/deployments/terraform
terraform init
terraform apply
```

```
cd terraform/deployments/terraform_helm
terraform init
terraform apply
```

# Tear down

```
cd terraform/deployments/terraform
terraform destroy
```

You'll need to run `terraform destroy` twice for the Helm version as it fails with an error regarding purging the release (although it actually does it). Rerunning `terraform destroy` a second time will succeed. 

```
cd terraform/deployments/terraform_helm
terraform destroy
terraform destroy
```


```
kops delete cluster --name bloom.fcctrl.com --yes
```

```
cd terraform/state-init/
terraform destroy
```

This will fail with something like the below error as Terraform doesn't clean out it's state. The Terraform state bucket will need to be manually deleted (delete all files in the bucket, then delete the bucket itself) via the AWS console.

```
Error: error deleting S3 Bucket (bloomreach-tf-state-store): BucketNotEmpty: The bucket you tried to delete is not empty
        status code: 409, request id: AD5DB0AE8F6DF7FB, host id: mJV5fR5tx4BHPahvOqGGEOdtvSyNB3qxSsz/oDs0HbBB/miXy9Nk1yf+JdbLjUyZdVxF6+7LU0A=
```

Finally, delete the IAM `KubernetesAdmin` role and that should be everything tided up. 
