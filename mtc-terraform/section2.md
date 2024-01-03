# Terraform basics and Docker

1. [Docker provider](#dockerprovider)
2. [Terraform init](#tfinit)
3. [Terraform Depency Lock](#tfdep)
4. [Terraform Apply](#tfapply)
    4.1. [Docker pull image via Terraform](#dockerpullimgtf)

## Docker provider <a name="dockerprovider"></a>
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

## Terraform init <a name="tfinit"></a>
`terraform init` initializes a working directory containing Terraform configuration files. It will automatically find, download and install the necessary providers plugins declared in the `*.tf` file

## Terraform Depency Lock <a name="tfdep"></a>
Terraform locked file (`.terraform.lock.hcl`) allows to ensure that everyone who downloads the code from a source control (github) always has the same provider version
```
 terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.15.0"
    }
  }
}

provider "docker" {}
```
`~> 2.15.0` means that the version `2.15` (major and minor version) wont upgrade only the `0` (patch version). In this case we have the `0` if there wasn't when upgrading the `15` would be upgraded.

To upgrade the patch version use
`terraform init -upgrade`

## Terraform Apply <a name="tfapply"></a>
`terraform apply` deploys the resource

### Docker pull image via Terraform <a name="dockerpullimgtf"></a>
```
  resource "docker_image" "nodered_image" {
  name = "nodered/node-red:latest"
}
```