# Terraform Terminology
## How terraform works
- Written in Golang
- Interfaces with the API of the "provider" -> Provider = GCP, AWS, Azure, etc.
- Create
- Read
- Update
- Delete

```
resource "docker_image" "nodered_image" {
    name = "nodered/node-red:latest"
}
```

in docker is equal to

```docker pull nodered/node-red:latest```

## Core Terraform Workflow
1. Code
2. Plan
    - Validate the code that syntax is correct and a brief summary of what will be deployed
3. Apply
    - Deploys the desired code

## Terraform State
- Stores information about the current environment
- Is created based on the configuration files and any changes are committed to the infrastructure via API
    - Only knows about resources created by it. If those resources are missing, it can replace, but cannot see other resources

## IaC Workflow
1. Terraform code
2. Git repository
3. CI/CD tools
    - Deploys Infrastructure

## Declarative vs Imperial
| Declarative | Imperial |
| ----------- | ----------- |
| What do you want the final deployment to look like | How do you want to deploy resources |
| "I want a VPC and 2 instances that are connected to an IGW for internet access" | "Create the VPC first, then create the IGW, then create the EC2 instances" |
| Requires "state" | Not dependent on state |
| Process is more abstracted | More control over the process |
| Idempotent | Running an operation twice will still perform the operation, regardless of its previous execution or the damage it can cause|
| Primary Terraform operation | Terraform can perform imperative tasks, but it is best practice to keep the code as declarative as possible |

## Terraform vs CloudFormation
| Terraform | CloudFormation |
| ----------- | ----------- |
| Open source | Closed source |
| HCL syntax | JSON/YAML syntax |
| Vendor neutral | AWS only |
| Requires state management and storage | State is managed by AWS |
| Requires resources to run | Is run within AWS for free |
| Requires logging infrastructure | Integrates with CloudWatch |
| Breaking changes are generally more likely | Typically more reliable from version-to-version for AWS infrastructure |