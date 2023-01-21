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
gcloud compute networks subnets create backend-subnet \
    --region --region=us-central1 \
    --network pies-infolab-vpc \
    --range 10.178.12.0/23 \
    --secondary-range my-pods=10.178.128.0/17,my-services=10.178.16.0/22 \
    --enable-private-ip-google-access


gcloud compute networks subnets create frontend-subnet \
    --region --region=southamerica-east1 \
    --network pies-infolab-vpc \
    --range 10.62.212.0/22 \
    --secondary-range my-pods=10.64.0.0/14,my-services=10.62.224.0/20 \
    --enable-private-ip-google-access


