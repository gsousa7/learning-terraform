# Terraform basics and Docker

1. [Docker provider](#dockerprovider)
2. [Terraform init](#tfinit)
3. [Terraform Dependency Lock](#tfdep)
4. [Terraform Apply](#tfapply)
    1. [Docker pull image via Terraform](#dockerpullimgtf)
5. [Terraform Plan and Apply - Deep dive](#tfplanapply)]

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

## Terraform Plan and Apply - Deep dive <a name="tfplanapply"></a>
`terraform plan` describes what will be deployed and brief summary of configurations
  We can also create a plan with `terraform plan -out=plan1` and apply it with `terraform apply plan1`. The content of the file `plan1` is encoded
`terraform destroy` will delete the existing infrastructure deployed
`terraform fmt` will correct indentation and spacing

## Resource referencing 
```
 terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.15.0"
    }
  }
}

  resource "docker_image" "nodered_image" {
    name = "nodered/node-red:latest"
}

  resource "docker_container" "nodered_container {
    name = "nodered"
    image = docker_image.nodered_image.latest
    ports {
        internal = 1880 
        external = 1880
    }
  }
```
In the  `docker_container` `section:
- `name` is the name of the container
- `image` is the name of the image that we will use. `docker_image.nodered_image` is referencing the resource `docker_image` that has the name `nodered_image` and the `latest` is the ID of the image
- `port` is what ports we will use and mapping
  - `internal` port of the container
  - `external` port of the host
