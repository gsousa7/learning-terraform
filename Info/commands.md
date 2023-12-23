`terraform init` Starts the workspace
`terraform plan` Tells us what is trying to build
`terraform apply` Deploys what we are trying to build
    We can also do `terraform apply -auto-approve` so we can avoid typing 'yes' everytime we deploy
`terraform destroy` Destroy all the resources that we have created in workspace
    We can check what we will destroy with `terraform plan -destroy`
`terraform fmt` Formats of the file (identation)