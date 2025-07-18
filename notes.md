Here is a **detailed and beginner-friendly explanation** of Terraform concepts with simple language and code examples to help you prepare notes.

---

# **1. Stacks**

## Overview

A **stack** is a collection of resources managed together. Think of it like a project folder that holds infrastructure setup for an app.

> Example: A stack can contain a virtual machine, a database, and a storage bucket for your web app.

## Use Case

Use stacks to organize your infrastructure based on environments:

* dev stack
* staging stack
* production stack

## Design a Stack

Decide what your app needs. For a blog app:

* 1 VM for web server
* 1 database (e.g., MySQL)
* 1 S3 bucket for images

## Create a Stack

### Define Configuration (main.tf)

```hcl
provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}
```

### Declare Providers

You tell Terraform which cloud platform you're working with.

### Define Deployments

* **Conditions**: Use `count` or `if` logic to deploy resources only when needed.
* **Authenticate**: Set credentials (e.g., via AWS CLI or `.env` file).
* **Pass Data Between Stacks**: Use outputs and remote state.

### Authenticate Example

```bash
export AWS_ACCESS_KEY_ID=your-key
export AWS_SECRET_ACCESS_KEY=your-secret
```

### Pass Data Example

```hcl
# In Stack A
output "db_url" {
  value = aws_db_instance.db.endpoint
}

# In Stack B
data "terraform_remote_state" "db" {
  backend = "s3"
  config = {
    bucket = "my-terraform-state"
    key    = "stack-a/terraform.tfstate"
    region = "us-west-2"
  }
}
```

---

# **2. Files and Directories**

## Overview

Terraform reads files ending in `.tf` and directories with configurations.

### Common Files:

* `main.tf`: Main configuration
* `variables.tf`: Input variables
* `outputs.tf`: Output values
* `terraform.tfvars`: Actual values for the variables

## Override Files

You can override the main configuration.

```hcl
# terraform.override.tf
resource "aws_instance" "web" {
  instance_type = "t3.micro"
}
```

## Dependency Lock File

`.terraform.lock.hcl` ensures the same provider version is used.

## Test Files

Use testing frameworks like `terratest` or `kitchen-terraform`.

Example using Terratest (Go):

```go
func TestTerraform(t *testing.T) {
  terraformOptions := &terraform.Options{
    TerraformDir: "../terraform/",
  }

  defer terraform.Destroy(t, terraformOptions)
  terraform.InitAndApply(t, terraformOptions)
}
```

---

# **3. Meta-Arguments**

Meta-arguments are special arguments that apply to multiple resources or modules to control behavior.

## `depends_on`

Ensures one resource is created before another.

```hcl
resource "aws_security_group" "web_sg" {
  # ...
}

resource "aws_instance" "web" {
  depends_on = [aws_security_group.web_sg]
  # ...
}
```

## `count`

Create multiple copies.

```hcl
resource "aws_instance" "web" {
  count         = 2
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}
```

## `for_each`

Loop over a map or list.

```hcl
resource "aws_s3_bucket" "bucket" {
  for_each = toset(["dev", "prod"])

  bucket = "my-${each.key}-bucket"
  acl    = "private"
}
```

## `provider`

Use a specific provider configuration.

```hcl
provider "aws" {
  alias  = "east"
  region = "us-east-1"
}

resource "aws_instance" "east_instance" {
  provider = aws.east
  # ...
}
```

## `lifecycle`

Control resource creation and destruction.

```hcl
resource "aws_instance" "web" {
  lifecycle {
    prevent_destroy = true
  }
}
```

---

# **4. Provisioners**

Provisioners run scripts or commands after a resource is created.

## `local-exec` Example

Run a local command.

```hcl
resource "null_resource" "example" {
  provisioner "local-exec" {
    command = "echo Deployment complete!"
  }
}
```

## `remote-exec` Example

Run commands on a remote server.

```hcl
resource "aws_instance" "web" {
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx"
    ]
  }

  connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host     = self.public_ip
  }
}
```

## `file` Provisioner

Copy files to remote.

```hcl
provisioner "file" {
  source      = "script.sh"
  destination = "/tmp/script.sh"
}
```

---

# **5. Modules Best Practices**

* **Use input/output variables** for flexibility
* **Keep modules focused** on a single task (e.g., one for VPC, one for EC2)
* **Add README and examples**
* **Avoid hardcoded values**
* **Use versioned modules** from registry or Git

Example:

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.0.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"
}
```

---

# **6. Expressions**

Expressions allow logic and data references.

## Conditional Logic

```hcl
output "env" {
  value = var.env == "prod" ? "Production" : "Non-production"
}
```

## Loop with `for`

```hcl
output "instance_tags" {
  value = [for inst in aws_instance.web : inst.tags.Name]
}
```

## Use Splat (\*)

```hcl
output "public_ips" {
  value = aws_instance.web[*].public_ip
}
```

## String Template

```hcl
output "msg" {
  value = "Hello ${var.username}, welcome!"
}
```

---

# **7. Functions**

Functions help process data.

## Common Examples

```hcl
output "count" {
  value = length(var.names)  # number of names
}

output "upper" {
  value = upper("hello")  # => HELLO
}

output "joined" {
  value = join(",", ["a", "b", "c"])  # => a,b,c
}
```

## File and Encoding

```hcl
output "template" {
  value = templatefile("template.tpl", { name = "web" })
}

output "encoded" {
  value = base64encode("password123")
}
```

## Date, Crypto, and Conversion

```hcl
output "time" {
  value = timestamp()
}

output "hash" {
  value = sha256("mydata")
}

output "number" {
  value = tonumber("42")
}
```

---

# **8. State**

## What is State?

Terraform uses state to remember what it has created.

## Local vs Remote State

* **Local**: Stored in a file on your machine (`terraform.tfstate`)
* **Remote**: Stored in cloud (e.g., S3)

## Example Remote State Setup

```hcl
terraform {
  backend "s3" {
    bucket = "my-tf-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}
```

## Importing Resources

```bash
terraform import aws_instance.web i-1234567890abcdef0
```

## Refactoring State

```bash
terraform state mv aws_instance.old aws_instance.new
```

## Workspaces

Used for multiple environments.

```bash
terraform workspace new dev
terraform workspace select dev
```

## Sensitive Output

```hcl
output "db_password" {
  value     = var.db_password
  sensitive = true
}
```

---

# **9. Tests**

## Overview

Testing in Terraform helps validate infrastructure code before deploying. It ensures your configurations work as expected and catch errors early.

## Why Testing Matters

* Prevent misconfigurations
* Validate outputs and behavior
* Reduce risks during infrastructure changes

## Types of Testing

### 1. **Linting**

Use `tflint` to check for syntax errors and best practices.

```bash
tflint
```

### 2. **Static Analysis**

Use `checkov` or `terraform validate` to catch security and syntax issues.

```bash
terraform validate
checkov -d .
```

### 3. **Unit Testing**

Use **Terratest** (Go-based) to run tests against real infrastructure.

#### Example: Terratest (Go)

```go
func TestTerraformExample(t *testing.T) {
  terraformOptions := &terraform.Options{
    TerraformDir: "../example",
  }

  defer terraform.Destroy(t, terraformOptions)
  terraform.InitAndApply(t, terraformOptions)

  output := terraform.Output(t, terraformOptions, "instance_ip")
  assert.NotEmpty(t, output)
}
```

### 4. **Kitchen-Terraform**

Use this Ruby-based framework for integration tests.

### 5. **Pre-commit Hooks**

Automate checks before every commit.

```bash
pre-commit install
```

#### Example `.pre-commit-config.yaml`

```yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.77.0
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: tflint
```

## Best Practices

* Automate testing in CI/CD pipelines
* Validate and plan before apply
* Use mocking in tests (when possible)

---

Would you like me to finish with **Backends**, **Import**, and **Terraform Block** next?

Yes continue with **Backends**, **Import**, and **Terraform Block**
