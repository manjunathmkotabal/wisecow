# Cow wisdom web server deployment of K8S

## About

- The application is deployed on AWS EKS as a K8s app with fargate
- You can access the app here : http://k8s-wisecown-ingressw-fd1f27eb7a-1584757244.us-east-1.elb.amazonaws.com/
- The cluster has a configured ingress controller with an application load balancer


## Prerequisites

```
- aws-cli
- kubectl v1.23.*
- eksctl
- docker
- helm v3.8.2
```

## Changes needed

- Change the Dockerhub repository name in the `.github/workflows/main.yml`
- Add  `DOCKER_USERNAME` `DOCKER_PASSWORD` `AWS_ACCESS_KEY` `AWS_SECRET_ACCESS_KEY` to github action secrets

## How to setup?

### Clone this repository

```
git clone https://github.com/manjunathmkotabal/wisecow.git
```
```
cd wisecow
```

### Create an EKS cluster with fargate worker nodes

```
eksctl create cluster --name demo-cluster-1 --region us-east-1 --fargate
```

### Update kubeconfig

```
aws eks update-kubeconfig --name demo-cluster-1 --region us-east-1
```

## Create Fargate profile to have a seperate namespace for fargate

```
eksctl create fargateprofile \
    --cluster demo-cluster-1 \
    --region us-east-1 \
    --name alb-sample-app \
    --namespace wisecow-namespace
```

### Update kubeconfig

```
aws eks update-kubeconfig --name demo-cluster-1 --region us-east-1
```

### Deploy the k8s manifests to EKS

```
kubectl apply -f kubernetes/main.yaml
```

### Setup OIDC connector for alb controller to connect with ALB

```
eksctl utils associate-iam-oidc-provider --cluster demo-cluster-1 --approve
```

# How to setup alb add on

Download IAM policy

```
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json
```

Create IAM Policy

```
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json
```

Create IAM Role

```
eksctl create iamserviceaccount \
  --cluster=demo-cluster-1 \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::<your-aws-account-id>:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve \
  --override-existing-serviceaccounts
```

## Deploy ALB controller

Add helm repo

```
helm repo add eks https://aws.github.io/eks-charts
```

Update the repo

```
helm repo update eks
```

Install

```
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system \
  --set clusterName=demo-cluster-1 \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-1 \
  --set vpcId=<your-vpc-id>
```

Verify that the deployments are running.

```
kubectl get deployment -n kube-system aws-load-balancer-controller
```

Get Adress to access your app 

```
kubectl get ingress -n wisecow-namespace
```


## What to expect?
![wisecow](https://github.com/nyrahul/wisecow/assets/9133227/8d6bfde3-4a5a-480e-8d55-3fef60300d98)
