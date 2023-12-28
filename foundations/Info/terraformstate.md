Terraform State

Terraform state is a representation of your infrastructure, including resources and their configurations, in a machine-readable format. It is usually stored in a file named terraform.tfstate by default.

Never change terraform.tfstate
To show the terraform state list use `terraform state list`
```
gsousa@deby:~/lab/learning-terraform/project$ terraform state list
aws_vpc.costum_vpc
```

See information of the resource
```
gsousa@deby:~/lab/learning-terraform/project$ terraform state show aws_vpc.costum_vpc
# aws_vpc.costum_vpc:
resource "aws_vpc" "costum_vpc" {
    arn                                  = "arn:aws:ec2:us-east-1:685246175129:vpc/vpc-069c28bc3cb8df73c"
    assign_generated_ipv6_cidr_block     = false
    cidr_block                           = "10.123.0.0/16"
    default_network_acl_id               = "acl-06c480044d452ad17"
    default_route_table_id               = "rtb-0f9a5c470a5f6cff4"
    default_security_group_id            = "sg-003e83cf61665d495"
    dhcp_options_id                      = "dopt-02c2fba19a93291aa"
    enable_dns_hostnames                 = true
    enable_dns_support                   = true
    enable_network_address_usage_metrics = false
    id                                   = "vpc-069c28bc3cb8df73c"
    instance_tenancy                     = "default"
    ipv6_netmask_length                  = 0
    main_route_table_id                  = "rtb-0f9a5c470a5f6cff4"
    owner_id                             = "685246175129"
    tags                                 = {
        "Name" = "dev"
    }
    tags_all                             = {
        "Name" = "dev"
    }
}
```

We can also see the entire state of all resources with `terraform show`