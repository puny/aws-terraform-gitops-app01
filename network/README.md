# AWS VPC network

This Terraform configuration creates a VPC, an Internet Gateway, and public and
private subnets across two Availability Zones by default. Public subnets have
an Internet Gateway route and automatically assign public IPv4 addresses.
Private subnets have no Internet route. No NAT Gateway or EC2 instance is
created.

## File layout

- `main.tf`: VPC and Internet Gateway
- `subnet.tf`: public and private subnets
- `routing.tf`: route tables, routes, and subnet associations
- `data.tf`: optional lookups for an existing VPC and its subnets

## Configure

Edit `terraform.auto.tfvars` to set the AWS region, VPC name, and network CIDRs. Terraform
automatically loads this file. Update the `region` in the S3 backend block in
`versions.tf` as well if you change the region. Set `cost_tag` to the desired
value for the `Cost` tag (for example, a project or cost-center name).

Set `vpc_cidr` for the VPC range. Set `public_subnet_cidrs` and
`private_subnet_cidrs` to one CIDR per Availability Zone, in matching order.
The defaults are two AZs: public `10.0.1.0/24`, `10.0.2.0/24`; private
`10.0.11.0/24`, `10.0.12.0/24`. If `availability_zone_count` is changed, provide
the same number of CIDRs in each subnet list. Choose subnet ranges contained
within the VPC CIDR and ensure they do not overlap.

Taggable resources receive `Name`, `Cost`, `Environment`, and `ManagedBy`
tags. Names include the VPC name and resource type; subnet names also include
the Availability Zone suffix, such as `dev-vpc-public-subnet-2a`. AWS routes
and route-table associations do not support resource tags.

To look up an existing VPC, set `existing_vpc_id` in `terraform.auto.tfvars`.
The data sources also return subnets in that VPC tagged `Tier=public` or
`Tier=private`. This is lookup-only: the default VPC and subnet resources are
still created. Leave `existing_vpc_id` empty when no lookup is needed.

This backend uses S3 state locking with `use_lockfile`; a DynamoDB table is not
required. Use Terraform 1.10 or later. Before initializing Terraform, create
the S3 bucket because Terraform cannot create its own remote backend. Set the
bucket name in `versions.tf`. For example, in `ap-northeast-2`:

```sh
aws s3api create-bucket \
  --bucket YOUR_UNIQUE_STATE_BUCKET_NAME \
  --region ap-northeast-2 \
  --create-bucket-configuration LocationConstraint=ap-northeast-2

aws s3api put-bucket-versioning \
  --bucket YOUR_UNIQUE_STATE_BUCKET_NAME \
  --versioning-configuration Status=Enabled

aws s3api put-public-access-block \
  --bucket YOUR_UNIQUE_STATE_BUCKET_NAME \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

aws s3api put-bucket-encryption \
  --bucket YOUR_UNIQUE_STATE_BUCKET_NAME \
  --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

```

For another region, use its required S3 bucket creation syntax and use that
region consistently for the AWS CLI commands and `versions.tf`.

## Deploy

Use AWS credentials that can manage the resources in the configuration and
access the S3 state object and its `.tflock` object. The credentials need
`s3:ListBucket` on the bucket, `s3:GetObject` and `s3:PutObject` on the state
object, and `s3:GetObject`, `s3:PutObject`, and `s3:DeleteObject` on the
`.tflock` object.
Run these commands from the `network` directory:

```sh
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
```

## GitHub Actions

The workflow at `.github/workflows/terraform.yml` runs formatting and
configuration validation for pull requests without AWS credentials. On pushes
to `main`, it assumes an AWS IAM role through GitHub OIDC, then runs `plan` and
automatically applies the resulting plan. Protect `main` with required pull
request reviews and status checks so infrastructure changes are reviewed
before they are applied.

In the repository's **Settings → Secrets and variables → Actions → Variables**,
create the repository variable `AWS_ROLE_ARN` with the ARN of the IAM role for
the workflow. The role must trust the GitHub OIDC provider
`token.actions.githubusercontent.com` with audience `sts.amazonaws.com` and
restrict the subject to this repository's `main` branch:
`repo:puny/aws-terraform-gitops-app01:ref:refs/heads/main`. The PR workflow does
not receive AWS credentials; this prevents unreviewed Terraform code from
accessing the state or AWS role.

Grant the role only the EC2 permissions needed to manage the VPC, Internet
Gateway, subnets, route tables, routes, and their associations in
`ap-northeast-2`, plus S3 access to the configured state bucket and key. For
S3 state locking, it needs `s3:GetObject` and `s3:PutObject` on the state object,
and `s3:GetObject`, `s3:PutObject`, and `s3:DeleteObject` on the `.tflock`
object. Restrict bucket access to the configured state path and enable S3
versioning and public access blocking as described above. Grant `s3:ListBucket`
on the bucket, restricted to the configured state key prefix.

The public and private subnet IDs are available as Terraform outputs. Use a
public subnet ID when creating a development EC2 instance that needs direct
Internet connectivity. Configure a restrictive security group separately;
this network configuration does not open inbound ports.
