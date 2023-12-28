Variables makes the script more organized and dynamic

Variables precedence:
1. Any `-var` and `-var-file` options on the command line, in the order they are provided. (This includes variables set by a Terraform Cloud workspace.)
2. Any `*.auto.tfvars` or `*.auto.tfvars.json` files, processed in lexical order of their filenames.
3. The `terraform.tfvars.json` file, if present.
4. The `terraform.tfvars` file, if present.
5. Environment variables

Show value of variable inside `terraform console`
`var.host_os` `var.VARIAVEL_DEFENIDA`

Override variables:
`terraform console -var="host_os=MacOS`
`terraform console console -var-file="extra_vars.tfvars"`