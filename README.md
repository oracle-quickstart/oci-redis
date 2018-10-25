# oci-redis
Terraform module to deploy Redis on Oracle Cloud Infrastructure (OCI)

# Redis.io
Redis (REmote DIctionary Server) is a popular open-source, in-memory data store that supports a wide array of data structures in addition to simple key-value pairs. It is a key-value database where values can contain more complex data types, such as strings, hashes, lists, sets, sorted sets, bitmaps, and hyperloglogs, with atomic operations defined on those data types. Redis combines in-memory caching with built-in replication, persistence, sharding, and the master-slave architecture of a traditional database. Given the rich features offered by Redis out of the box, a wide variety of deployment options are available.

We will scale the Redis instances across multiple availability domains to demonstrate Redis replication and clustering, which provides high availability to Redis instances.

According to Redis official documentation, Redis Cluster provides a way to run a Redis installation where data is automatically sharded across multiple Redis nodes. Redis Cluster also provides some degree of availability during partitions, which is in practical terms the ability to continue the operations when some nodes fail or are not able to communicate. So in practical terms, what you get with Redis Cluster?

The ability to automatically split your dataset among multiple nodes.
The ability to continue operations when a subset of the nodes are experiencing failures or are unable to communicate with the rest of the cluster.

# Deployment Architecture

![](./images/arch.PNG)
				

## Prerequisites
In addition to an active tenancy on OCI, you will need a functional installation of Terraform, and an API key for a privileged user in the tenancy.  See these documentation links for more information:

[Getting Started with Terraform on OCI](https://docs.cloud.oracle.com/iaas/Content/API/SDKDocs/terraformgetstarted.htm)

[How to Generate an API Signing Key](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm#How)

Once the pre-requisites are in place, you will need to copy the templates from this repository to where you have Terraform installed.


## Clone the Terraform template
Now, you'll want a local copy of this repo.  You can make that with the commands:

    git clone https://github.com/cloud-partners/oci-redis.git
    cd oci-redis
    ls


## Update Template Configuration
Update environment variables in config file: [env-vars](https://github.com/cloud-partners/oci-redis/blob/master/env-vars)  to specify your OCI account details like tenancy_ocid, user_ocid, compartment_ocid. To source this file prior to installation, either reference it in your .rc file for your shell's or run the following:

        source env-vars



## Deployment & Post Deployment

Deploy using standard Terraform commands

        terraform init && terraform plan && terraform apply


## SSH to Bastion Node
When terraform apply is complete, the terminal console will display the public ip address for bastion node.  The default login is opc.  You can SSH into the machine with a command like this:

        ssh -i ~/.ssh/id_rsa opc@${data.oci_core_vnic.bastion_vnic.public_ip_address}


