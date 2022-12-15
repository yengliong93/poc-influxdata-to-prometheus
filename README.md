# poc-influxdata-to-prometheus
## Step:
1. K8s was installed on the system.
2. Prometheus was installed on the system and it is exposed to default namespace. You can refer to https://github.com/intel/platform-aware-scheduling/blob/master/telemetry-aware-scheduling/docs/custom-metrics.md for Prometheus deployment. Please change the namespace to default namespace.
Add pushgateway to _prometheus_helm_chart/templates/prometheus-config-map.yaml_ before helm install. 
```
       - job_name: 'pushgateway'
        honor_labels: false
        static_configs:
        - targets: ['pushgateway:9091']
        kubernetes_sd_configs:
        - role: node
        relabel_configs:
        - source_labels: [__address__]
          regex: ^(.*):\d+$
          target_label: __address__
          replacement: $1:9091
```


3. Deploy Pushgateway. 
`sudo kubectl apply -f pushgateway.yaml`
4. Deploy data-exporter.
`sudo kubectl apply -f data-exporter.yaml`

5. Login to Prometheus server and check the data.
<img src="images/cpu_usage_on_prometheus.JPG"/>

## Build data-exporter image
sudo docker build \
     --build-arg HTTP_PROXY=${HTTP_PROXY:-} \
     --build-arg http_proxy=${http_proxy:-} \
     --build-arg HTTPS_PROXY=${HTTPS_PROXY:-} \
     --build-arg https_proxy=${https_proxy:-} \
     --build-arg NO_PROXY=${NO_PROXY:-} \
     --build-arg no_proxy=${no_proxy:-} \
     -t data-exporter -f Dockerfile .