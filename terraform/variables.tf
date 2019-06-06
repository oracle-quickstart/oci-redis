variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}

variable "compartment_ocid" {}
variable "ssh_public_key" {}

variable "CIDR" {
  default = "10.0.0.0/16"
}

variable "instance" {
  type = "map"

  default = {
    name           = "redis"
    shape          = "VM.Standard2.1"
    instance_count = 6
  }
}

locals {
  fault_domains_per_ad = 3
}

// https://docs.cloud.oracle.com/iaas/images/image/cf34ce27-e82d-4c1a-93e6-e55103f90164/
// Oracle-Linux-7.6-2019.05.14-0
variable "images" {
  type = "map"

  default = {
    ap-seoul-1     = "ocid1.image.oc1.ap-seoul-1.aaaaaaaalhbuvdg453ddyhvnbk4jsrw546zslcfyl7vl4oxfgplss3ovlm4q"
    ap-tokyo-1     = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaamc2244t7h3gwrrci5z4ni2jsulwcg76gugupkb6epzrypawcz4hq"
    ca-toronto-1   = "ocid1.image.oc1.ca-toronto-1.aaaaaaaakjkxzw33dcocgu2oylpllue34tjtyngwru7pcpqn4qh2nwon7n7a"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaandqh4s7a3oe3on6osdbwysgddwqwyghbx4t4ryvtcwk5xikkpvhq"
    uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaa2xe7cufdwkksdazshtmqaddgd72kdhiyoqurtoukjklktf4nxkbq"
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaa4bfsnhv2cd766tiw5oraw2as7g27upxzvu7ynqwipnqfcfwqskla"
    us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaavtjpvg4njutkeu7rf7c5lay6wdbjhd4cxis774h7isqd6gktqzoa"
  }
}
