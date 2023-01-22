#!/bin/bash
cluster_vpc=$(gcloud compute networks describe gke-tech-vpc | grep 'name:')
if test -z "$cluster_vpc"
then
    echo "creating vpc for gke clusters........"
    gcloud compute networks create gke-tech-vpc \
        --subnet-mode custom
else
    echo "vpc is already present"
fi

front_IP=$(gcloud compute addresses describe front-end-ip --global | grep 'address:')
if test -z "$front_IP"
then
    echo "creating static ip for Front-end........"
    gcloud compute addresses create front-end-ip --global --ip-version IPV6
else
    echo "front-end address is already present"
fi

back_IP=$(gcloud compute addresses describe back-end-ip --region=us-central1 | grep 'address:')
if test -z "$back_IP"
then
    echo "creating static ip for Back-end........"
    gcloud compute addresses create back-end-ip --region=us-central1
else
    echo "back-end address is already present"
fi
gcloud compute networks subnets create frontend-subnet \
    --region=us-central1 \
    --network gke-tech-vpc \
    --range 10.178.12.0/23 \
    --secondary-range my-pods=10.178.128.0/17,my-services=10.178.16.0/22 \
    --enable-private-ip-google-access


gcloud compute networks subnets create backend-subnet \
    --region=southamerica-east1 \
    --network gke-tech-vpc \
    --range 10.62.212.0/22 \
    --secondary-range my-pods=10.64.0.0/14,my-services=10.62.224.0/20 \
    --enable-private-ip-google-access

gcloud compute routers create frontend-nat-router --region=us-central1 --network=gke-tech-vpc

gcloud compute routers create backend-nat-router --region=southamerica-east1 --network=gke-tech-vpc

gcloud compute routers nats create backend-nat \
    --router=backend-nat-router \
    --region=southamerica-east1 \
    --auto-allocate-nat-external-ips \
    --nat-custom-subnet-ip-ranges=backend-subnet,backend-subnet:my-pods,backend-subnet:my-services

gcloud compute routers nats create frontend-nat \
    --router=frontend-nat-router \
    --region=us-central1 \
    --auto-allocate-nat-external-ips \
    --nat-custom-subnet-ip-ranges=frontend-subnet,frontend-subnet:my-pods,frontend-subnet:my-services

gcloud sql instances create gke-tech-sql --database-version=MYSQL_5_7 --cpu=2 --memory=4GB --region=us-central1 --root-password=password123

fronrend_cluster=$(gcloud container clusters list | grep 'front-end-cluster')
if test -z "$fronrend_cluster"
then
    echo "Cluster is being Provision....."
    gcloud container clusters create-auto front-end-cluster \
        --region us-central1 \
        --no-enable-master-authorized-networks \
        --network gke-tech-vpc \
        --subnetwork frontend-subnet \
        --cluster-secondary-range-name my-pods \
        --services-secondary-range-name my-services \
        --enable-private-nodes
    export USE_GKE_GCLOUD_AUTH_PLUGIN=True
    gcloud container clusters get-credentials front-end-cluster --region us-central1
    helm install my-ingress-nginx ingress-nginx/ingress-nginx --version 4.3.0 --set rbac.create=true --set controller.service.loadBalancerIP=$IP,rbac.create=true
    sleep 10
    kubectl get svc
    kubectl apply -f kubernetes/
    sleep 10
    kubectl apply -f kubernetes/lets-encrypt
else
    echo "cluster alredy present...."
    exit
fi
backend_cluster=$(gcloud container clusters list | grep 'back-end-cluster')
if test -z "$backend_cluster"
then
    echo "Cluster is being Provision....."
    gcloud container clusters create-auto back-end-cluster \
        --region southamerica-east1 \
        --no-enable-master-authorized-networks \
        --network gke-tech-vpc \
        --subnetwork backend-subnet \
        --cluster-secondary-range-name my-pods \
        --services-secondary-range-name my-services \
        --enable-private-nodes
    export USE_GKE_GCLOUD_AUTH_PLUGIN=True
    gcloud container clusters get-credentials back-end-cluster --region southamerica-east1
    helm install my-ingress-nginx ingress-nginx/ingress-nginx --version 4.3.0 --set rbac.create=true --set controller.service.loadBalancerIP=$IP,rbac.create=true
    sleep 10
    kubectl get svc
    kubectl apply -f kubernetes/
    sleep 10
    kubectl apply -f kubernetes/lets-encrypt
else
    echo "cluster alredy present...."
    exit
fi