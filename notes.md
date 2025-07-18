
# 🌍 Terraform Full Guide for Beginners — With Examples

A complete beginner-friendly Terraform guide covering configuration, best practices, modules, CI/CD, and more. Each section uses layman's terms and simple code examples.

---

## 📦 1. Stacks

### What is a Stack?

A **stack** is like a folder containing all the infrastructure setup for one environment (e.g., dev, prod). It manages a group of resources together.

### Use Case Example

You can have:
- A **dev stack** for testing
- A **staging stack** for QA
- A **prod stack** for users

### Designing a Stack

Suppose your app needs:
- A virtual machine
- A database
- A storage bucket

You can define these in one stack.

### Creating a Stack (Simple AWS Example)

**main.tf**
```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}
```

**Authenticate Example**
```bash
export AWS_ACCESS_KEY_ID=your-key
export AWS_SECRET_ACCESS_KEY=your-secret
```

**Pass Data Between Stacks**
```hcl
# In stack A (output)
output "db_url" {
  value = aws_db_instance.db.endpoint
}

# In stack B (input)
data "terraform_remote_state" "db" {
  backend = "s3"
  config = {
    bucket = "tf-states"
    key    = "stack-a.tfstate"
    region = "us-east-1"
  }
}
```

---

## 📂 2. Files and Directories

### Common Terraform Files

- `main.tf`: main config
- `variables.tf`: input variables
- `outputs.tf`: output values
- `terraform.tfvars`: default values

### Override Files

Use `.tf` overrides for changes.
```hcl
# terraform.override.tf
resource "aws_instance" "web" {
  instance_type = "t3.micro"
}
```

### Lock File

`.terraform.lock.hcl`: Locks provider versions.

### Test Files

Use `terratest` for Go-based tests.

```go
func TestTerraform(t *testing.T) {
  terraformOptions := &terraform.Options{ TerraformDir: "../" }
  defer terraform.Destroy(t, terraformOptions)
  terraform.InitAndApply(t, terraformOptions)
}
```

---

## 🧩 3. Meta-Arguments

### `depends_on`
```hcl
resource "aws_instance" "web" {
  depends_on = [aws_security_group.web_sg]
}
```

### `count`
```hcl
resource "aws_instance" "web" {
  count = 2
}
```

### `for_each`
```hcl
resource "aws_s3_bucket" "buckets" {
  for_each = toset(["dev", "prod"])
  bucket   = "my-${each.key}-bucket"
}
```

### `provider` and `lifecycle`
```hcl
resource "aws_instance" "web" {
  provider = aws.east
  lifecycle {
    prevent_destroy = true
  }
}
```

---

## 🧰 4. Provisioners

### `local-exec`
```hcl
provisioner "local-exec" {
  command = "echo Hello"
}
```

### `remote-exec`
```hcl
provisioner "remote-exec" {
  inline = ["sudo apt install nginx"]
}
```

### `file`
```hcl
provisioner "file" {
  source      = "setup.sh"
  destination = "/tmp/setup.sh"
}
```

---

## 🧱 5. Modules & Best Practices

### Best Practices
- Use inputs/outputs
- Avoid hardcoded values
- Keep small modules

### Module Example
```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.0.0"
  name    = "my-vpc"
  cidr    = "10.0.0.0/16"
}
```

---

## 🧮 6. Expressions

### Conditional
```hcl
value = var.env == "prod" ? "Yes" : "No"
```

### `for` loop and splat
```hcl
value = [for inst in aws_instance.web : inst.public_ip]
```

---

## 🔣 7. Functions

```hcl
upper("hello")             # => HELLO
join(",", ["a","b"])       # => a,b
timestamp()                # => current time
sha256("abc")              # => hashed value
tonumber("42")             # => 42
```

---

## 💾 8. State

### Remote State with S3
```hcl
terraform {
  backend "s3" {
    bucket = "my-tf-state"
    key    = "state.tfstate"
    region = "us-east-1"
  }
}
```

### Import Resource
```bash
terraform import aws_instance.example i-12345678
```

### Workspaces
```bash
terraform workspace new dev
terraform workspace select dev
```

---

## ✅ 9. Tests

### `terraform validate`
```bash
terraform validate
```

### Linting with `tflint`
```bash
tflint
```

### Static Check with `checkov`
```bash
checkov -d .
```

### Pre-Commit Hooks
```yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.77.0
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
```

---

## 🔧 10. Terraform Block

```hcl
terraform {
  required_version = ">= 1.2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
```

---

## 🔐 11. Backends

Used for shared state.

**Example: S3 backend with DynamoDB locking**
```hcl
terraform {
  backend "s3" {
    bucket         = "my-tf-state"
    key            = "state.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

---

## 🚀 12. CI/CD Setup (GitHub Actions)

**.github/workflows/terraform.yml**
```yaml
name: Terraform

on:
  push:
    branches: [main]

jobs:
  terraform:
    name: Terraform
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v2

      - name: Terraform Init
        run: terraform init

      - name: Terraform Validate
        run: terraform validate

      - name: Terraform Plan
        run: terraform plan

      - name: Terraform Apply
        run: terraform apply -auto-approve
        if: github.ref == 'refs/heads/main'
```

---

## 🧪 13. Terratest Example

```go
func TestTerraformExample(t *testing.T) {
  terraformOptions := &terraform.Options{
    TerraformDir: "../terraform",
  }

  defer terraform.Destroy(t, terraformOptions)
  terraform.InitAndApply(t, terraformOptions)
  ip := terraform.Output(t, terraformOptions, "instance_ip")
  assert.NotEmpty(t, ip)
}
```

---

## ♻️ 14. Reusable Module Layout

```
module-name/
├── main.tf
├── variables.tf
├── outputs.tf
├── README.md
└── examples/
    └── basic/
        └── main.tf
```

---

## ✅ Conclusion

You now understand:

- What Terraform stacks are and how to organize them
- How to structure configuration files
- How to use modules and meta-arguments
- How to write tests and run CI/CD
- How to use backend, import, and manage state

> This file can be used as a study guide, starter documentation, or base for automation.

Happy Terraforming! ☁️🚀
