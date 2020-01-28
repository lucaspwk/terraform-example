# REST API Example using Python and Flask with a AWS Cluster infrastructure

## Overview
This example contains a Terraform configuration that creates an AWS Cluster infrastructure to run a scalable and high-available REST API application using Python and Flask. It was based on the following projects with my own changes:

[Terraform + AWS + Docker Swarm setup](https://github.com/Praqma/terraform-aws-docker)

[RestAPI using Python and Flask](https://github.com/gmcalixto/restapi)

Basically, Terraform provisions a small Docker Swarm Cluster in AWS with three EC2 instances, defined as one manager and two workers. All Swarm workers will connect to the manager by a token, generated during the swarm initialisation. After that, a docker image is created with a docker-compose file and Dockerfile and then a scalable and high-available RestAPI application is deployed with by default (and configurable) 3 containers.



## Requirements

### AWS account

If you don't have account, you may get a free AWS account. In the setup will be used free t2.micro instances.

### Create Amazon EC2 key

Before to start, you need to create the pem file on AWS EC2 to connect to instances for provisioning.
Download the pem file. Copy the pem file to proj/ssh.
Set read permission:
```
chmod 400 my-key-pair.pem
```

### Running Terraform with Docker

This Terraform example works on Terraform 0.11 and is not supported for version 0.12 and later. An easy way to run the expected Terraform version is using a Docker container.
To run Terraform on a Docker container, please execute the following from the root directory:
```
docker run -it -v $PWD:/data --entrypoint "" amontaigu/terraform sh
```
It will mount the current volume on /data with all files needed.


### Instructions

- Fill *variables.tf* with your AWS credentials (access_key, secret_key) and the AWS key name created. The default AWS region is ca-central-1. Please don't change or the EC2 ami-id will not work.


### How to use

After all configuration are ready, you can do check if there are no mistakes.

```
terrform plan
```
This command will show either syntax errors or list of resources will be created. After you can run:

```
terraform apply
```

This command will build and run all resources in the *.tf files. Now you have fully provisioned Docker Swarm Cluster in AWS with a running REST API application using Python and Flask. 

Use the following commands to check the Docker Swarm Cluster and the service with the running application:
```
docker stack ps restapp
docker node ls
```
```
curl http://MASTER.IP:5000/employees
curl http://MASTER.IP:5000/tracks
```