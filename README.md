# Creating Multiple Environments Using Terraform

There are three common approaches to managing multiple environments such as **Dev, UAT, and Prod**.

## 1. Using `.tfvars` Files

Use the **same Terraform code** with different variable files for each environment.

Example:

```text
dev.tfvars
uat.tfvars
prod.tfvars
```

Each environment can also use a **different backend/state location** for better state isolation.

When switching between environments, use the appropriate backend configuration and variable file.

```bash
terraform init -reconfigure -backend-config=dev-backend.hcl
terraform plan -var-file=dev.tfvars
```

For UAT:

```bash
terraform init -reconfigure -backend-config=uat-backend.hcl
terraform plan -var-file=uat.tfvars
```

For Prod:

```bash
terraform init -reconfigure -backend-config=prod-backend.hcl
terraform plan -var-file=prod.tfvars
```

> `-reconfigure` tells Terraform to reinitialize the backend using the new backend configuration.

### Advantages

* Reuse the same Terraform code
* Environment-specific values are separated
* Each environment can have a separate state/backend

### Disadvantages

* Environment isolation depends on how the backend/state is configured
* Switching backend configurations requires care

---

## 2. Using Terraform Workspaces

Terraform workspaces allow multiple **state files** to use the same Terraform configuration and backend.

Create workspaces:

```bash
terraform workspace new dev
terraform workspace new uat
terraform workspace new prod
```

Switch between them:

```bash
terraform workspace select dev
terraform workspace select uat
terraform workspace select prod
```

Check the current workspace:

```bash
terraform workspace show
```

Use `terraform.workspace` in the configuration:

```hcl
locals {
  instance_type = {
    dev  = "t3.small"
    uat  = "t3.medium"
    prod = "t3.large"
  }
}

resource "aws_instance" "web" {
  instance_type = local.instance_type[terraform.workspace]
}
```

When the current workspace is `dev`:

```text
terraform.workspace = "dev"
instance_type       = "t3.small"
```

### Advantages

* Reuse the same Terraform code
* Same backend can manage multiple workspaces
* Separate Terraform state per workspace
* Easy environment switching

### Disadvantages

* Workspaces provide **state separation**, but not complete organizational/security isolation
* Environment-specific logic can become complicated
* Workspaces are not always ideal when environments require significantly different infrastructure or access controls

---

## 3. Individual Repositories / Separate Environment Configurations

Each environment can have its own repository or independently managed Terraform configuration.

Example:

```text
terraform-dev/
terraform-uat/
terraform-prod/
```

### Advantages

* Strong isolation between environments
* Environment-specific configuration can be completely independent
* Access controls can be applied separately

### Disadvantages

* Can lead to code duplication
* Changes may need to be maintained in multiple repositories

### Avoiding Code Duplication

Reusable Terraform **modules** can be shared between the environments.

```text
terraform-dev/
    main.tf

terraform-uat/
    main.tf

terraform-prod/
    main.tf

terraform-modules/
    vpc/
    eks/
    rds/
```

---

# Comparison

| Approach                               | Code Reuse       | State Isolation                           | Main Consideration                                     |
| -------------------------------------- | ---------------- | ----------------------------------------- | ------------------------------------------------------ |
| `.tfvars` + separate backends          | High             | High, if separate state/backends are used | Backend/environment management                         |
| Workspaces                             | High             | Separate state per workspace              | Less isolation than completely separate configurations |
| Individual repositories/configurations | Lower by default | High                                      | Possible code duplication                              |

---

# Terraform Modules

Terraform modules provide **reusable Terraform code**.

### Benefits

1. **Reusable code**

   Write infrastructure logic once and use it across multiple environments.

2. **Easy to maintain**

   Common infrastructure logic can be maintained in a central module repository or directory.

3. **Standardization**

   Modules can help enforce common infrastructure patterns, standards, and compliance requirements.

4. **Module invocation**

   A local module can be called using:

```hcl
module "local_module_name" {
  source = "../module_folder"

  # Specify required inputs
}
```

A module can also come from a Git repository or Terraform Registry.

Example:

```hcl
module "vpc" {
  source = "git::https://example.com/terraform-modules.git//vpc"

  # module inputs
}
```

---

## Module Variables and Outputs

A module can define **input variables**:

```hcl
variable "instance_type" {
  type = string
}
```

The caller provides the value:

```hcl
module "web" {
  source = "../modules/web"

  instance_type = "t3.medium"
}
```

A module can also define **outputs**:

```hcl
output "instance_id" {
  value = aws_instance.web.id
}
```

The caller can access the output:

```hcl
module.web.instance_id
```

### Important Correction

The variables **do not need to be redefined in the caller**.

The module defines its input variables, and the caller **passes values** to those variables.

```text
Caller
   │
   │ instance_type = "t3.medium"
   ↓
Module variable
   │
   ↓
Resource
   │
   ↓
Module output
   │
   ↓
Caller
```

---

## Provider Configuration in Modules

For reusable modules, it is generally recommended that the **root/calling module configure the provider**, rather than configuring provider credentials inside the child module.

Example:

```hcl
provider "aws" {
  region = "us-east-1"
}

module "web" {
  source = "../modules/web"

  instance_type = "t3.medium"
}
```

The child module can then use the AWS provider without defining credentials itself.

> A child module **can** contain provider configuration in some scenarios, but keeping provider configuration in the root module makes reusable modules more flexible and easier to consume.
