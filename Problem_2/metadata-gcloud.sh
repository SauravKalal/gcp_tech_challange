gcloud compute instances describe gcp-instance-demo --zone us-central1-a --format="json[](metadata)"
sleep 8
gcloud compute instances describe gcp-instance-demo --zone us-central1-a --format="value[](name)"
sleep 8
gcloud compute instances describe gcp-instance-demo --zone us-central1-a --format="value[](metadata.items.purpose)"
sleep 8
gcloud compute instances describe gcp-instance-demo --zone us-central1-a --format="value[](metadata.fingerprint)"