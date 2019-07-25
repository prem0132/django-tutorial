# Django Tutorial
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fprem0132%2Fdjango-tutorial.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2Fprem0132%2Fdjango-tutorial?ref=badge_shield)


This repository contains django boilerplate code with files and instruction to deploy it on a production environment as well as enabling best DevOps practices.

## Assumptions:

Postgres DB server used for production  
GitHub used for source control  
Jenkins as the CI/CD server  
Containerized approach  
docker-compose for local sandbox  
Kubernetes cluster as underlying production infrastructure or EC2 AutoScalingGroup as the underlying infrastructure  
Nginx ingress used for k8s cluster and AWS Application Load Balancer for EC2 AutoScalingGroup

## How to Setup

#### Pipeline

- To setup the pipeline, add a webhook for for your Jenkins Server in the github repository, then add the repo to Your Jenkins server and chose `Jenkinsfile` as the source for pipeline code

#### Locally

- You can use the `local-setup.sh` script to run a postgres db server in a docker container and then run the app with `python manage.py runserver` to start the server for local debugging and live reload
- You can use the `docker-deploy.sh` file. This file will build the docker image for the application and the database setup job and then run it using docker-compose
  - You can use `teardown.sh` script to clean up the system after stopping compose

#### Kubernetes

- In order to deploy the application on a k8s cluster with manifest files, run,  
   `kubectl apply -f infra/k8s/manifests/`

#### AWS EC2 AutoScalingGroup

- Use the cloudformation templates in `infra/cloudformation` directory to deploy on AWS
  - `vpc-2azs.yaml` for creating a VPC with 2 public and 2 private subnets
  - `rds-postgres.json` for deploying a postgres RDS database server
  - `AWS Deployment.png` displays the complete AWS native architecture

## Directory Structure

```bash
├── Dockerfile                                  Dockerfile to build the application
├── Dockerfile-database-setup                   Dockerfile to migrate the db changes
├── Jenkinsfile                                 Jenkins pipeline as code
├── README.md                                   Readme file
├── cloudformation                              Cloud formation templates needed to deploy the application on AWS
│   ├── asg-vpc-alb.template
│   ├── rds-postgres.json                       Template for deploying an RDS postgres DB server in a private subnet
│   └── vpc-2azs.yaml                           Template for creating a VPC with 2 public and 2 private subnets
├── docker-compose.yaml                         Docker compose file for local snadbox
├── docker-deploy.sh                            Build app and dbsetup image and start docker-compose
├── k8s                                         Kubernetes manifests and helm charts
│   └── manifests                               k8s manifest files
│       ├── django-demo-deployment.yaml         Deployment file for app with initContainer to setup database
│       ├── django-demo-hpa.yaml                Horizontal Pod Scaler for auto scaling of app
│       ├── django-demo-service.yaml            Service to expose the app
│       └── postgres.yaml                       postgres statefuSet on k8s yaml
├── local-setup.sh                              runs a postgres docker container locally and run live reload server
├── manage.py
├── mysite/
├── polls/
├── requirements.txt
└── teardown.sh                                  Script to teardown local compose setup
```

## Conceptual Approach

Used container based approach as docker and k8s are the market standard for application deployment
There is on another approach that is entertained, which is to deploy the code on EC2 instances and RDS for database

### The kubernetes approach

The application runs as a deployment with a horizotal pod scaler attached for autoscaling. We can add the service to expose that as LoadBalancer service type directly, or first expose it as a cluster ip and then use nginx-ingress on top of it.  
For database, we add a statefulSet for postgres DB server with volume persistense.  
There is also an initContainer in the django-demo pod which sets up the model changes on the database.
For loadbalancing, as k8s service automatically acts as LB, we can use that, or use it behind the ingress Network Load Balancer

### The EC2 AutoScaling approach

In this approach, we setup a RDS database server with postgre with MultiAZ availability and Read Replicas if required in a private subnet.

Then we can create a Launch Configuration for Ubuntu based instances and add the code to pull, install dependency and deploy application as user data script. These launch config will be a part of an ASG.  
Then we can add a Application Load Balancer, Target groups and the routing rules.

## Trade offs

K8s approach is cheaper and easier to maitain. Also the scale up latency is slow.
It also make the application and infra as code cloud agnostic.
Also, In AWS, there is a lot of management overhead like networking and Security, where as k8s reduces that significantly.

## Operational limits

RDS with multiAZ and Read Replicas will have way better performance than Postgres on K8s natively. However, they can both be tuned to improve performance

## What else would I have done?

1. Serve static content using CDN 
2. Create helm chart for k8s manifests
3. Extend the pipeline to deploy on K8s and AWS based on branch and tags
4. Worked more on the cloudformation templates
5. SSL/TLS with proper certs from AWS or Let's Encrypt
6. Some load testig


## License
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fprem0132%2Fdjango-tutorial.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2Fprem0132%2Fdjango-tutorial?ref=badge_large)