curl "http://metadata.google.internal/computeMetadata/v1/instance/" -H "Metadata-Flavor: Google"
sleep 5
curl "http://metadata.google.internal/computeMetadata/v1/instance//network-interfaces/0/" -H "Metadata-Flavor: Google"
sleep 5
curl "http://metadata.google.internal/computeMetadata/v1/instance/tags" -H "Metadata-Flavor: Google"
sleep 5
curl "http://metadata.google.internal/computeMetadata/v1/instance/tags?alt=text" -H "Metadata-Flavor: Google"
sleep 5
echo "enter the value:"
read value
curl "http://metadata.google.internal/computeMetadata/v1/instance/$value?recursive=true" -H "Metadata-Flavor: Google"