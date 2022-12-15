# poc-influxdata-to-prometheus
## Step:
1. K8s was installed on the system.
2. Deploy Pushgateway. 
3. Deploy data-exporter.

## Build data-exporter image
sudo docker build \
     --build-arg HTTP_PROXY=${HTTP_PROXY:-} \
     --build-arg http_proxy=${http_proxy:-} \
     --build-arg HTTPS_PROXY=${HTTPS_PROXY:-} \
     --build-arg https_proxy=${https_proxy:-} \
     --build-arg NO_PROXY=${NO_PROXY:-} \
     --build-arg no_proxy=${no_proxy:-} \
     -t data-exporter -f Dockerfile .