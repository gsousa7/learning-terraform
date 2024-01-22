# Terraform basics and Docker

1. [Docker provider](#dockerprovider)
2. [Terraform init](#tfinit)
3. [Terraform Dependency Lock](#tfdep)
4. [Terraform Apply](#tfapply)
    1. [Docker pull image via Terraform](#dockerpullimgtf)
5. [Terraform Plan and Apply - Deep dive](#tfplanapply)
6. [Resource referencing](#resourceref)
7. [Terraform State deep dive](#tfstatedeepdive)
8. [Terraform console and outputs](#tfconsoleoutput)
9. [Join Function](#joinfunction)
10. [Random resource](#randomresource)
11. [Multiple resources and Count](#multipleresourcescount)
12. [Splat expression](#splatexpression)
13. [For loop](#forloop)
14. [Tainting and updating resources](#taintandupdate)

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
Terraform locked file (`.terraform.lock.hcl`) allows to ensure that everyone who downloads the code from a source control (github, gitlab, etc.) always has the same provider version
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
`~> 2.15.0` means that the version `2.15` (major and minor version) wont upgrade, only the `0` (patch version). In this case we have the `0` if there wasn't when upgrading the `15` would be upgraded.

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
`terraform plan` describes what will be deployed and brief summary of configurations\
We can also create a plan with `terraform plan -out=plan1` and apply it with `terraform apply plan1`. The content of the file `plan1` is encoded
`terraform destroy` will delete the existing infrastructure deployed
`terraform fmt` will correct indentation and spacing

## Resource referencing <a name="resourceref"></a>
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

  resource "docker_image" "nodered_image" {
    name = "nodered/node-red:latest"
}

  resource "docker_container" "nodered_container" {
    name = "nodered"
    image = docker_image.nodered_image.latest
    ports {
        internal = 1880 
        external = 1880
    }
  }
```
In the  `docker_container` section:
- `name` is the name of the container
- `image` is the name of the image that we will use. `docker_image.nodered_image` is referencing the resource `docker_image` that has the name `nodered_image` and the `latest` is the ID of the image
- `port` is what ports we will use and mapping
  - `internal` port of the container
  - `external` port of the host

## Terraform State deep dive <a name="tfstatedeepdive"></a>
In the Terraform state file there are some parameters
- `serial` is a monotonically increasing integer associated with each Terraform state file. It represents the version or revision of the state file.
    - Helps Terraform manage and track changes to the state file over time. When changes are applied to the infrastructure, the serial number is incremented, allowing Terraform to detect conflicts and changes made by different users or runs
- `lineage` is a unique identifier associated with a Terraform state file. It is used to distinguish different state files, especially in scenarios where multiple teams or individuals are working on the same infrastructure.
    -  Helps prevent conflicts and coordination issues when multiple users are managing the same infrastructure. Each Terraform run generates a new state file with a unique lineage, and Terraform uses this identifier to avoid overwriting or conflicting with other state files.

    The Terraform state file is not encrypted.\
    We can use the command `terraform show -json` to see the contents of the Terraform state file (resources deployed and it's metadata). We can also have a friendlier view with `terraform show -json | jq`

    To list the the deployed resources within the Terraform state file, we can see it with `terraform state list`


## Terraform console and outputs <a name="tfconsoleoutput"></a>
To access the terraform console use `terraform console` in there we can access all the attributes of state.


Examples:
- Get the name of the container
`docker_container.nodered_container.name`

- Get the IP of the container
`docker_container.nodered_container.ip_address`

Usage on the terraform file:
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

  resource "docker_image" "nodered_image" {
    name = "nodered/node-red:latest"
}

  resource "docker_container" "nodered_container" {
    name = "nodered"
    image = docker_image.nodered_image.latest
    ports {
        internal = 1880 
        external = 1880
    }
  }

  output "IP-Address" {
    value = docker_container.nodered_container.ip_address
    description = "IP address of the nodered container"
  }

  output "Container-Name" {
    value = docker_container.nodered_container.name
    description = "Name of the nodered container"
  }
```
The name of the `output` in this case `IP-Address` and `Container-Name` can't contain spaces.

We don't have to apply every time to access this information, we can simply use `terraform output` to print this information. Although it must be applied and have the `output` module declared.

## Join function <a name="joinfunction"></a>

`join` produces a string by concatenating together all elements of a given list of strings with the given delimiter: `join("separator", ["list-element1", "list-element2"])`. 
Example:
```
> join("-", ["foo", "bar", "baz"])
"foo-bar-baz"
> join("|", ["ola", "sim", "nao", 1, 2])
"ola|sim|nao|1|2"
> join("|", ["ola", "sim", "nao", 1 + 2])
"ola|sim|nao|3"
```

Accessing terraform information, in this case getting the external port via `terraform console` with `docker_container.nodered_container.ports[0].external`.

To get the IP:PORT of the container we use the join function in `terraform console` with `join(":", [docker_container.nodered_container.ip_address,docker_container.nodered_container.ports[0].external])`.

In a terraform file:
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

  resource "docker_image" "nodered_image" {
    name = "nodered/node-red:latest"
}

  resource "docker_container" "nodered_container" {
    name = "nodered"
    image = docker_image.nodered_image.latest
    ports {
        internal = 1880 
        external = 1880
    }
  }

  output "IP-Address" {
    value = join(":", [docker_container.nodered_container.ip_address,docker_container.nodered_container.ports[0].external])
    description = "IP address and external port of the nodered container"
  }

  output "Container-Name" {
    value = docker_container.nodered_container.name
    description = "Name of the nodered container"
  }
```

## Random resource <a name="randomresource"></a>
`random_string` generates a random permutation of alphanumeric characters. This is good tool to avoid duplicate names following a random nomenclature.

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

  resource "docker_image" "nodered_image" {
    name = "nodered/node-red:latest"
}

  resource "random_string" "random"{
    length = 4
    special = false
    upper = false
  }

  resource "random_string" "random2"{
    length = 4
    special = false
    upper = false
  }

  resource "docker_container" "nodered_container" {
    name = join("-", ["nodered", "random_string.random.result"])
    image = docker_image.nodered_image.latest
    ports {
        internal = 1880 
        external = 1880
    }
  }

  resource "docker_container" "nodered_container2" {
    name = "nodered2"
    image = join("-", ["nodered", "random_string.random2.result"])
    ports {
        internal = 1880 
        external = 1880
    }
  }

  output "IP-Address" {
    value = join(":", [docker_container.nodered_container.ip_address,docker_container.nodered_container.ports[0].external])
    description = "IP address and external port of the nodered container"
  }

  output "Container-Name" {
    value = docker_container.nodered_container.name
    description = "Name of the nodered container"
  }

  output "IP-Address2" {
    value = join(":", [docker_container.nodered_container2.ip_address,docker_container.nodered_container2.ports[0].external])
    description = "IP address and external port of the nodered container"
  }

  output "Container-Name2" {
    value = docker_container.nodered_container2.name
    description = "Name of the nodered container"
  }
```
The random string is only accessible and usable through the attribute `result`


After adding a new resource (`random_string`) we must do a `terraform init`.

## Multiple resources and Count<a name="multipleresourcescount"></a>
The `count` argument allows to specify how many times we want for example to deploy.\
When using count, to access the resource we must use it's index `[0]`, `[1]`,`[2]`, etc.
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

  resource "docker_image" "nodered_image" {
    name = "nodered/node-red:latest"
}

  resource "random_string" "random"{
    count = 2
    length = 4
    special = false
    upper = false
  }

  resource "docker_container" "nodered_container" {
    count = 2
    name = join("-", ["nodered", "random_string.random[count.index].result"])
    image = docker_image.nodered_image.latest
    ports {
        internal = 1880 
        external = 1880
    }
  }


  output "IP-Address" {
    value = join(":", [docker_container.nodered_container[0].ip_address,docker_container.nodered_container[0].ports[0].external])
    description = "IP address and external port of the nodered container"
  }

  output "Container-Name" {
    value = docker_container.nodered_container[0].name
    description = "Name of the nodered container"
  }

  output "IP-Address2" {
    value = join(":", [docker_container.nodered_container[1].ip_address,docker_container.nodered_container[1].ports[0].external])
    description = "IP address and external port of the nodered container"
  }

  output "Container-Name2" {
    value = docker_container.nodered_container[1].name
    description = "Name of the nodered container"
  }
```
In this case, 2 containers are created with the name `nodered-RANDOMSTRING`

## Splat expression <a name="splatexpression"></a>
Splat expression is used like a for loop. It allows to reference all of the resources created by count.

In `terraform console` we can get all the names of the containers with `docker_container.nodered_container[*].name`

In Terraform file:
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

  resource "docker_image" "nodered_image" {
    name = "nodered/node-red:latest"
}

  resource "random_string" "random"{
    count = 2
    length = 4
    special = false
    upper = false
  }

  resource "docker_container" "nodered_container" {
    count = 2
    name = join("-", ["nodered", "random_string.random[count.index].result"])
    image = docker_image.nodered_image.latest
    ports {
        internal = 1880 
        external = 1880
    }
  }


  output "IP-Address" {
    value = join(":", [docker_container.nodered_container[0].ip_address,docker_container.nodered_container[0].ports[0].external])
    description = "IP address and external port of the nodered container"
  }

  output "Container-Name" {
    value = docker_container.nodered_container[*].name
    description = "Name of the nodered container"
  }

  output "IP-Address2" {
    value = join(":", [docker_container.nodered_container[1].ip_address,docker_container.nodered_container[1].ports[0].external])
    description = "IP address and external port of the nodered container"
  }
```

We can't use the splat operator in the `output` of the IP Address because it's trying to access multiple elements when we are trying to get a list when it's a tuple with 2 elements.

## For loops <a name="forloop"></a>
In `terraform console` we can use for loops. Example: `[for i in [1, 2, 3] : i + 1]` in this case we are incrementing the 1 value to the list.

Using with a resource: 
Print resources:
`[for i in docker_container.nodered_container[*] : i.name]`

Print ports:
`[for i in docker_container.nodered_container[*] : i.ports[0]["external"]]`

Usage in terraform file.
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

  resource "docker_image" "nodered_image" {
    name = "nodered/node-red:latest"
}

  resource "random_string" "random"{
    count = 2
    length = 4
    special = false
    upper = false
  }

  resource "docker_container" "nodered_container" {
    count = 2
    name = join("-", ["nodered", "random_string.random[count.index].result"])
    image = docker_image.nodered_image.latest
    ports {
        internal = 1880 
        external = 1880
    }
  }

  output "Container-Name" {
    value = docker_container.nodered_container[*].name
    description = "Name of the nodered container"
  }

  output "IP-Address2" {
    value = [for i in docker_container.nodered_container[*] : join(":", [i.ip_address], i.ports[*]["external"])]
    description = "IP address and external port of the nodered container"
  }
```

## Tainting and updating resources <a name="taintandupdate"></a>
Tainting a resource is a way to force that resource to be destroyed and reapplied. Essentially reloads the resource.
The most common reason to taint a resource is to reapply some sort of configuration.

To taint a resource use `terraform taint random_string.random[0]` if we do a `terraform plan` it will inform that 2 resources will be destroyed and created: the `random_string` and `nodered_container` because the container is using the random string as a suffix in it's name, therefore the need to destroy and create the container.

To remove the taint (untaint) use `terraform untaint random_string.random[0]`
