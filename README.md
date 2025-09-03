# Terraform Generic Pipeline

## Overview

The Terraform Generic Job is a flexible Jenkins pipeline designed to deploy and manage Terraform infrastructure in AWS environments. It provides a reusable deployment process that allows teams to dynamically select source repositories, branches, terraform directories, and deployment actions.

## Jenkins Pipeline Details

- **Job Name**: `terraform-generic`
- **URL**: [http://3.21.53.100:8080/job/terraform-generic/](http://3.21.53.100:8080/job/terraform-generic/)
- **Type**: Parameterized Jenkins Pipeline

## Pipeline Parameters

| Parameter | Description | Type | Example |
|-----------|-------------|------|---------|
| **GitHub URL** | The URL of the GitHub repository containing the Terraform code | String | `https://github.com/srimuvva24/project1.git` |
| **Branch** | The branch of the repository to deploy | String | `main` |
| **TF_DIR** | The folder name inside the repository where the Terraform code resides | String | `terraform-vpc` |
| **Action** | The Terraform action to execute | Choice | `apply` (deploy resources) or `destroy` (delete resources) |

## Supported Terraform Modules

### 1. terraform-vpc

The `terraform-vpc` module automates the creation of core AWS networking infrastructure.

#### Resources Provisioned
- **VPC** – A custom Virtual Private Cloud
- **Subnets** – Public and/or private subnets across multiple Availability Zones
- **Internet Gateway (IGW)** – For internet connectivity
- **Route Tables (RT)** – To manage traffic routing for the VPC
- **NAT Gateways** (if private subnets are configured)

#### Required Variables

| Name | Description | Type | Required | Example |
|------|-------------|------|----------|---------|
| `vpc_name` | Name of the VPC | string | Yes | `"dev-vpc"` |
| `vpc_cidr` | CIDR block for the VPC | string | Yes | `"10.0.0.0/16"` |
| `public_subnet_cidrs` | List of CIDR blocks for public subnets | list(string) | Yes | `["10.0.1.0/24", "10.0.2.0/24"]` |
| `igw_name` | Name of the Internet Gateway | string | Yes | `"my-igw"` |

#### Example terraform.tfvars
```hcl
vpc_name = "production-vpc"
vpc_cidr = "10.0.0.0/16"
public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24",
  "10.0.3.0/24"
]
```

### 2. terraform-db

The `terraform-db` module automates the creation of AWS DynamoDB tables with consistent configuration across environments.

#### Resources Provisioned
- **DynamoDB Table** – NoSQL database table with configurable attributes
-

### 3. terraform-ec2-alb-tg

The `terraform-ec2-alb-tg` module automates the deployment of a complete web application infrastructure in AWS.

#### Resources Provisioned
- **EC2 Instances** – Application hosts created from custom AMI
- **Application Load Balancer (ALB)** – Layer 7 load balancer for traffic distribution
- **Target Groups (TG)** – Health-checked groups of EC2 instances
- **Security Groups** – Network access rules for EC2 instances and ALB
- **Auto Scaling Group** (optional)
- **Launch Template** – Standardized EC2 launch configuration

#### Required Variables

| Name | Description | Type | Required | Example |
|------|-------------|------|----------|---------|
| `vpc_id` | ID of the VPC where resources will be created | string | Yes | `"vpc-01a41952ad8fdc4f9"` |
| `alb_name` | Name for the Application Load Balancer | string | Yes | `"flask-alb-2"` |
| `tg_name` | Name for the Target Group | string | Yes | `"flask-tg-2"` |
| `ami_id` | Custom AMI ID for EC2 instances | string | Yes | `"ami-0863fb82a7836e852"` |

#### Example terraform.tfvars
```hcl
vpc_id = "vpc-01a41952ad8fdc4f9"
subnet_ids = ["10.0.1.0/24", "10.0.2.0/24"]
alb_name = "flask-alb-2"
tg_name = "flask-tg-2"
ami_id = "ami-0863fb82a7836e852"
```

## Usage Instructions

### 1. Deploying Infrastructure

1. **Access Jenkins**: Navigate to [http://3.21.53.100:8080/job/terraform-generic/](http://3.21.53.100:8080/job/terraform-generic/)
2. **Click "Build with Parameters"**
3. **Fill in Parameters**:
   - **GitHub URL**: Your repository URL
   - **Branch**: Target branch (usually `main` or `develop`)
   - **TF_DIR**: Module directory name (`vpc`, `database`, `ec2-alb`)
   - **Action**: Select `apply` to create resources
4. **Click "Build"**

### 2. Destroying Infrastructure

Follow the same steps but select `destroy` for the Action parameter.

⚠️ **Warning**: Destroy operations are irreversible. Always verify the target environment before proceeding.

## Prerequisites

### AWS Requirements
- **AWS Account** with appropriate permissions
- **IAM Role/User** for Jenkins with permissions:
  - EC2 full access (for VPC and EC2 modules)
  - DynamoDB full access (for database module)
  - ELB full access (for ALB module)
  - IAM permissions for resource tagging

### Jenkins Requirements
- Jenkins server with Terraform installed
- AWS CLI configured with appropriate credentials
- Git access to the source repository
- Required Jenkins plugins:
  - Pipeline plugin
  - Git plugin
  - AWS Steps plugin (optional)

### Repository Structure
```
repository-root/
├── vpc/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
├── database/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
└── ec2-alb/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── terraform.tfvars
```

## Pipeline Workflow

1. **Checkout**: Clone the specified repository and branch
2. **Initialize**: Run `terraform init` in the specified directory
3. **Plan**: Generate and display the execution plan
4. **Approval**: Wait for manual approval (if configured)
5. **Execute**: Run `terraform apply` or `terraform destroy`
6. **Output**: Display results and any output values

## Best Practices

### Security
- Store sensitive variables in Jenkins credentials or AWS Parameter Store
- Use least privilege IAM policies
- Enable CloudTrail logging for audit trails
- Implement proper branch protection rules

### State Management
- Use remote state backend (S3 + DynamoDB for locking)
- Enable state file encryption
- Implement state file versioning
- Regular state file backups

### Code Organization
- Use consistent naming conventions
- Implement proper tagging strategy
- Document all variables and outputs
- Use modules for reusable components

## Troubleshooting

### Common Issues

#### 1. Terraform Init Fails
- **Cause**: Backend configuration issues or network connectivity
- **Solution**: Verify AWS credentials and S3 bucket access

#### 2. Plan/Apply Fails
- **Cause**: Insufficient permissions or resource conflicts
- **Solution**: Check IAM permissions and existing resource names

#### 3. State Lock Issues
- **Cause**: Previous operation didn't complete properly
- **Solution**: Manually release lock in DynamoDB or wait for timeout

#### 4. Resource Already Exists
- **Cause**: Resource naming conflicts
- **Solution**: Import existing resources or use different names

### Support Contacts
- **DevOps Team**: devops@company.com
- **AWS Support**: (if applicable)
- **Jenkins Admin**: jenkins-admin@company.com

## Version History

- **v1.0**: Initial pipeline with basic apply/destroy functionality
- **v1.1**: Added support for multiple modules
- **v1.2**: Enhanced error handling and logging
- **v1.3**: Added automated approval workflows
