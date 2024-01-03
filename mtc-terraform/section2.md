# Terraform basics and Docker

## Docker provider
```
 terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
    }
  }
}

provider "docker" {}
```

Terraform handles all `*.tf` files as the same file

## Terraform init 
`terraform init` initializes a working directory containing Terraform configuration files. It will automatically find, download and install the necessary providers plugins declared in the `*.tf` file