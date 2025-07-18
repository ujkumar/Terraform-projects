# Terraform Complete Guide

A comprehensive, beginner-friendly guide to Terraform concepts with examples, best practices, testing, CI/CD, and reusable modules.

---

## Table of Contents

1. [Stacks](#stacks)
2. [Files and Directories](#files-and-directories)
3. [Meta-Arguments](#meta-arguments)
4. [Provisioners](#provisioners)
5. [Modules and Best Practices](#modules-and-best-practices)
6. [Expressions](#expressions)
7. [Functions](#functions)
8. [State](#state)
9. [Testing Infrastructure](#testing-infrastructure)
10. [Backends](#backends)
11. [Terraform Block](#terraform-block)
12. [Import](#import)
13. [CI/CD with GitHub Actions](#cicd-with-github-actions)

---

## Stacks

A **stack** is like a project folder managing related infrastructure resources.

### Example:

```hcl
# main.tf
provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}
```

Use `terraform_remote_state` to share data between stacks.

---

## Files and Directories

### Common Terraform Files

* `main.tf`: main config
* `variables.tf`: input vars
* `outputs.tf`: output values
* `terraform.tfvars`: actual values

### Override Example

```hcl
# terraform.override.tf
resource "aws_instance" "web" {
  instance_type = "t3.micro"
}
```

---

## Meta-Arguments

* `depends_on`, `count`, `for_each`, `provider`, `lifecycle`

### Example:

```hcl
resource "aws_instance" "web" {
  count         = 2
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}
```

---

## Provisioners

Run local or remote scripts after resource creation.

### Local Example

```hcl
provisioner "local-exec" {
  command = "echo 'Deployed'"
}
```

### Remote Example

```hcl
provisioner "remote-exec" {
  inline = ["sudo apt install nginx"]
}
```

---

## Modules and Best Practices

### Best Practices

* Use input/output variables
* Small, focused modules
* No hardcoded values
* Add README/examples

### Example Module Call

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.0.0"
  cidr    = "10.0.0.0/16"
}
```

---

## Expressions

### Examples:

```hcl
output "env" {
  value = var.env == "prod" ? "Production" : "Dev"
}

output "tags" {
  value = [for inst in aws_instance.web : inst.tags.Name]
}
```

---

## Functions

```hcl
output "upper_name" {
  value = upper("hello")
}

output "joined" {
  value = join(",", ["a", "b"])
}

output "hash" {
  value = sha256("secret")
}
```

---

## State

Track deployed resources.

### Remote State Example:

```hcl
terraform {
  backend "s3" {
    bucket = "my-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}
```

---

## Testing Infrastructure

### Static Testing

```bash
tflint
tfsec
terraform validate
```

### Terratest (Go)

```go
func TestTerraform(t *testing.T) {
  terraformOptions := &terraform.Options{
    TerraformDir: "../infra",
  }
  terraform.InitAndApply(t, terraformOptions)
  output := terraform.Output(t, terraformOptions, "instance_id")
  assert.NotEmpty(t, output)
}
```

### Pre-Commit Hook

```yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.77.0
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
```

---

## Backends

### S3 + DynamoDB Setup

```hcl
terraform {
  backend "s3" {
    bucket         = "tf-states"
    key            = "app/prod.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-locks"
  }
}
```

---

## Terraform Block

Defines provider version, backend, and settings.

```hcl
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

---

## Import

Bring existing resources under Terraform control.

```bash
terraform import aws_instance.web i-12345678
```

---

## CI/CD with GitHub Actions

### Directory Structure

```
/infra
  - main.tf
/tests
  - main_test.go
/.github/workflows
  - terraform.yml
```

### GitHub Actions Workflow (terraform.yml)

```yaml
name: Terraform CI

on:
  push:
    branches: [ main ]

jobs:
  terraform:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2

      - name: Init
        run: terraform init

      - name: Validate
        run: terraform validate

      - name: Plan
        run: terraform plan
```

### Terratest GitHub Actions Example

```yaml
      - name: Run Terratest
        run: |
          cd tests
          go mod tidy
          go test -v
```

---
