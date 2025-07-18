# Terraform Notes - Beginner to Expert Level

---

## 1. Introduction to Terraform

### What is Terraform?

Terraform is an open-source Infrastructure as Code (IaC) tool created by **HashiCorp** that allows you to define and provision infrastructure using a high-level configuration language called **HCL (HashiCorp Configuration Language)**.

### Why Terraform?

* Automates infrastructure provisioning
* Platform agnostic (works with AWS, Azure, GCP, etc.)
* Infrastructure as Code (versionable, repeatable)
* Declarative language: You define **what** you want, not **how** to do it

### Diagram: How Terraform Works

```
   .tf Files ───► Terraform CLI/Engine ───► Cloud Infra (AWS, GCP)
```

---

## 2. Terraform Installation

1. Go to [https://terraform.io](https://terraform.io)
2. Download binary for your OS
3. Add Terraform to PATH
4. Run `terraform -version` to confirm

---

## 3. Basic Terraform Commands

| Command              | Purpose                           |
| -------------------- | --------------------------------- |
| `terraform init`     | Initializes the working directory |
| `terraform plan`     | Shows what Terraform will do      |
| `terraform apply`    | Applies the changes               |
| `terraform destroy`  | Destroys the infrastructure       |
| `terraform validate` | Validates the syntax of the files |

---

## 4. Terraform File Structure

```
main.tf        → Main configuration
variables.tf   → All input variables
outputs.tf     → Output values
terraform.tfstate → Stores actual state
```

---

## 5. Provider

### What is a Provider?

A provider is a plugin that lets Terraform interact with APIs of cloud platforms like AWS, Azure, GCP.

### Syntax

```hcl
provider "aws" {
  region = "us-east-1"
}
```

### Example

```hcl
provider "aws" {
  region     = "ap-south-1"
  access_key = "your-access-key"
  secret_key = "your-secret-key"
}
```

---

## 6. Resource

### What is a Resource?

A **resource** block defines **a piece of infrastructure** to be created, such as an EC2 instance or S3 bucket.

### Syntax

```hcl
resource "<PROVIDER>_<TYPE>" "<NAME>" {
  # Configuration
}
```

### Example

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}
```

### Diagram

```
resource "aws_instance" "web"
        ↓
Creates an EC2 instance on AWS
```

---

## 7. Variables

### What are Variables?

Variables make code reusable by allowing users to pass values dynamically.

### Types

* `string`
* `number`
* `bool`
* `list`
* `map`

### Syntax

```hcl
variable "instance_type" {
  type    = string
  default = "t2.micro"
}
```

### Example

```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
}
```

---

## 8. Outputs

### What is Output?

Outputs allow Terraform to display information about resources after creation.

### Syntax

```hcl
output "instance_id" {
  value = aws_instance.web.id
}
```

---

## 9. Data Source

### What is Data Source?

Used to **fetch data from existing infrastructure** (read-only).

### Syntax

```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/*"]
  }
}
```

---

## 10. State Files

### What is State?

Terraform keeps a record of the infrastructure in a **terraform.tfstate** file.

* `terraform.tfstate`: Current state
* `terraform.tfstate.backup`: Backup

> ⚠️ Do not edit manually

---

## 11. Remote Backend

### Why Remote State?

To share state across team members and store it securely (e.g., in S3).

### Example

```hcl
terraform {
  backend "s3" {
    bucket = "my-tf-state-bucket"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
  }
}
```

---

## 12. Modules

### What is a Module?

A module is a **reusable group of resources**. Helps organize and reuse code.

### Structure

```
/modules/ec2/main.tf
/modules/ec2/variables.tf
/modules/ec2/outputs.tf
```

### Use

```hcl
module "web_server" {
  source        = "./modules/ec2"
  instance_type = "t2.micro"
}
```

---

## 13. Terraform Lifecycle Rules

```hcl
resource "aws_instance" "example" {
  lifecycle {
    prevent_destroy = true
  }
}
```

* `create_before_destroy`: Useful for replacements
* `prevent_destroy`: Prevents accidental deletion

---

## 14. Terraform Provisioners

### Purpose

Run scripts (bash, etc.) on instances post-creation.

```hcl
provisioner "remote-exec" {
  inline = [
    "sudo apt update",
    "sudo apt install nginx -y"
  ]
}
```

---

## 15. Conditional Expressions & Loops

### Condition

```hcl
count = var.enable ? 1 : 0
```

### Loop

```hcl
resource "aws_instance" "web" {
  count         = length(var.instances)
  ami           = var.ami
  instance_type = var.instances[count.index]
}
```

---

## Exam Tips

* Understand **plan → apply → destroy** flow
* Practice using **variables and modules**
* Know what **terraform.tfstate** is and why it's critical
* Use **data source** when you need existing infra
* Understand **lifecycle rules** to protect resources

---

## Mini-Project Example

### Goal: Deploy an EC2 instance with user-defined AMI and instance type

```hcl
provider "aws" {
  region = "ap-south-1"
}

variable "ami_id" {
  default = "ami-0c55b159cbfafe1f0"
}

variable "instance_type" {
  default = "t2.micro"
}

resource "aws_instance" "my_ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  tags = {
    Name = "MyInstance"
  }
}

output "instance_id" {
  value = aws_instance.my_ec2.id
}
```

---

## Next Topics to Learn

* Workspaces
* Tainting & Targeting Resources
* Debugging Terraform
* Dynamic Blocks
* Integration with CI/CD
* Secrets Management (Vault, etc.)


# Terraform Advanced Concepts - Notes for Beginners

## 1. Workspaces

### What:

Workspaces in Terraform are used to manage different versions or environments (like `dev`, `staging`, and `prod`) of your infrastructure using the same code.

### Why:

To avoid maintaining multiple copies of the same code for different environments.

### How:

* `terraform workspace list` – Lists all workspaces.
* `terraform workspace new dev` – Creates a new workspace.
* `terraform workspace select dev` – Switches to the dev workspace.

### Example:

Imagine you want a separate environment for development and production. Instead of copying your Terraform code into separate folders, you use workspaces:

```bash
terraform workspace new dev
terraform apply

terraform workspace new prod
terraform apply
```

Each workspace has its own state file, so the resources are managed separately.

---

## 2. Tainting & Targeting Resources

### What:

* **Tainting** marks a resource for recreation.
* **Targeting** means applying changes to only specific resources.

### Why:

* Taint if a resource is acting strangely and you want Terraform to recreate it.
* Target when you want to apply changes to just one part of your infrastructure.

### How:

* Taint: `terraform taint aws_instance.example`
* Untaint: `terraform untaint aws_instance.example`
* Target: `terraform apply -target=aws_instance.example`

### Example:

Your server instance is behaving weirdly, so you run:

```bash
terraform taint aws_instance.example
terraform apply
```

This tells Terraform to destroy and recreate that one instance.

---

## 3. Debugging Terraform

### What:

Debugging helps you find out why Terraform is not behaving as expected.

### Why:

To troubleshoot errors in configuration or unexpected behavior in infrastructure.

### How:

* Use the `TF_LOG` environment variable:

  ```bash
  export TF_LOG=DEBUG
  terraform apply
  ```
* Review logs to see where Terraform is failing.
* Check state files if resources are out of sync.

### Example:

Terraform is skipping a resource. Set the log level:

```bash
export TF_LOG=DEBUG
terraform plan
```

Then read the logs to see what's happening.

---

## 4. Dynamic Blocks

### What:

Dynamic blocks allow you to create repeatable nested blocks in Terraform.

### Why:

To avoid writing repetitive code and improve maintainability.

### How:

```hcl
resource "aws_security_group" "example" {
  name = "example"

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}
```

### Example:

If you have multiple ingress rules, instead of writing each one manually, you use a dynamic block that loops through a list.

---

## 5. Integration with CI/CD

### What:

Automating Terraform execution as part of your CI/CD pipeline.

### Why:

To automatically plan and apply infrastructure changes during code deployments.

### How:

* Use tools like GitHub Actions, GitLab CI, or Jenkins.
* Example GitHub Actions step:

```yaml
- name: Terraform Apply
  run: |
    terraform init
    terraform plan
    terraform apply -auto-approve
```

### Example:

Every time you push changes to GitHub, your pipeline runs Terraform to apply infrastructure updates.

---

## 6. Secrets Management (Vault, etc.)

### What:

Storing sensitive data like passwords and keys securely.

### Why:

To avoid putting secrets directly in Terraform files or version control.

### How:

* Use tools like HashiCorp Vault, AWS Secrets Manager, or environment variables.
* Example with environment variable:

```bash
export TF_VAR_db_password="supersecret"
```

* Use in Terraform:

```hcl
variable "db_password" {}
resource "aws_db_instance" "example" {
  password = var.db_password
}
```

### Example:

Instead of writing:

```hcl
password = "hardcoded123"
```

you use:

```hcl
password = var.db_password
```

and keep the actual password in a secret store.

---

Each of these concepts helps you write safer, cleaner, and more scalable Terraform code. Practice them in small projects to get comfortable.
