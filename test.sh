#!/bin/bash
gcloud components install gke-gcloud-auth-plugin
gcloud config set project my-project-cisc5550
gcloud compute instances delete cisc5550-api
gcloud compute firewall-rules delete rule-allow-tcp-5001

#create the virtual machine instance
gcloud compute instances create cisc5550-api \
    --machine-type=e2-medium \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --tags=http-server \
    --zone=us-central1-c \
    --metadata-from-file startup-script=./startup.sh

#sleep 30  #Waiting for the VM to be done

# SSH into the VM and run commands
#gcloud compute ssh cisc5550-api --zone=us-central1-c --command "\
#    sudo apt update && \
#    sudo apt install -y python3-pip && \
#    sudo pip3 install flask && \
#    git clone https://github.com/rosamsierrap/cisc5550.git && \
#    cd cisc5550/ && \
#    sudo bash startup.sh"

gcloud compute firewall-rules create rule-allow-tcp-5001 --source-ranges 0.0.0.0/0 --target-tags http-server --allow tcp:5001

export TODO_API_IP=`gcloud compute instances list --filter="name=cisc5550-api" --format="value(EXTERNAL_IP)"`

# next, deploy the app that depens on api
docker build -t rosasierra/cisc5550todoapp --build-arg api_ip=${TODO_API_IP} .

# docker login
docker push rosasierra/cisc5550todoapp

gcloud container clusters create cisc5550-cluster
kubectl create deployment cc5550 --image=rosasierra/cisc5550todoapp --port=5000
kubectl expose deployment cc5550 --type="LoadBalancer"

kubectl get service cc5550
