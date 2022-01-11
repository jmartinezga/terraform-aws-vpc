# Terraform VPC module

### Install dependencies

<!-- markdownlint-disable no-inline-html -->

* [`pre-commit`](https://pre-commit.com/#install)
* [`terraform-docs`](https://github.com/terraform-docs/terraform-docs)
* [`terragrunt`](https://terragrunt.gruntwork.io/docs/getting-started/install/)
* [`terrascan`](https://github.com/accurics/terrascan)
* [`TFLint`](https://github.com/terraform-linters/tflint)
* [`TFSec`](https://github.com/liamg/tfsec)
* [`infracost`](https://github.com/infracost/infracost)
* [`jq`](https://github.com/stedolan/jq)

### Install the pre-commit hook globally

```bash
DIR=~/.git-template
git config --global init.templateDir ${DIR}
pre-commit init-templatedir -t pre-commit ${DIR}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
