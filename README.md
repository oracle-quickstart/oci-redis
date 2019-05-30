# oci-quickstart-redis
This is a Terraform module that deploys [Redis](https://redis.io) on [Oracle Cloud Infrastructure (OCI)](https://cloud.oracle.com/en_US/cloud-infrastructure). It is developed jointly by Oracle and Redis Labs.

## About
Redis (REmote DIctionary Server) is a popular open-source, in-memory data store that supports a wide array of data structures in addition to simple key-value pairs. It is a key-value database where values can contain more complex data types, such as strings, hashes, lists, sets, sorted sets, bitmaps, and hyperloglogs, with atomic operations defined on those data types. Redis combines in-memory caching with built-in replication, persistence, sharding, and the master-slave architecture of a traditional database. Given the rich features offered by Redis out of the box, a wide variety of deployment options are available.

We will scale the Redis instances across multiple availability domains to demonstrate Redis replication and clustering, which provides high availability to Redis instances.

According to Redis official documentation, Redis Cluster provides a way to run a Redis installation where data is automatically sharded across multiple Redis nodes. Redis Cluster also provides some degree of availability during partitions, which is in practical terms the ability to continue the operations when some nodes fail or are not able to communicate. So in practical terms, what you get with Redis Cluster?

The ability to automatically split your dataset among multiple nodes.
The ability to continue operations when a subset of the nodes are experiencing failures or are unable to communicate with the rest of the cluster.

## Deployment Architecture
![](./images/arch.PNG)

## Prerequisites
First off you'll need to do some pre deploy setup.  That's all detailed [here](https://github.com/oracle/oci-quickstart-prerequisites).

## Clone the Terraform template
Now, you'll want a local copy of this repo.  You can make that with the commands:

    git clone https://github.com/oracle/oci-quickstart-redis.git
    cd oci-quickstart-redis
    ls

## Update Template Configuration
Update environment variables in config file: [env-vars](https://github.com/cloud-partners/oci-redis/blob/master/env-vars)  to specify your OCI account details like tenancy_ocid, user_ocid, compartment_ocid. To source this file prior to installation, either reference it in your .rc file for your shell's or run the following:

        source env-vars

## Deployment and Post Deployment

Deploy using standard Terraform commands

        terraform init
	terraform plan
	terraform apply

## SSH to Bastion Node
When terraform apply is complete, the terminal console will display the public ip address for bastion node.  The default login is opc.  You can SSH into the machine with a command like this:

        ssh -i ~/.ssh/id_rsa opc@$<Public IP address of the Bastion Instance

To access Redis nodes, you need to use the Bastion instance as a jump box. Connect to the Bastion first, then connect to the Redis instances. 

1. SSH into the Bastion instance
   `ssh -i <location of the SSH private key you used for deployment> opc@<Public IP address of the Bastion instance>`

2. SSH into the Redis nodes
   `ssh -i /home/opc/.ssh/id_rsa opc@redis-node-1`
