#!/bin/bash
set -euo pipefail

function sigterm_handling() {
    echo "Catch SIGTERM. Exiting..."
    exit
    kill 0
}

trap sigterm_handling SIGTERM SIGINT


while true
do

    # Curl command below query the cpu usage on host telegraf-polling-service. The output as follows:
    # ,result,table,_start,_stop,_time,_value,_field,_measurement,cpu,host
    # ,_result,0,2022-12-14T07:55:53.164048403Z,2022-12-14T07:56:53.164048403Z,2022-12-14T07:56:40Z,0.4318136171922005,usage_system,cpu,cpu-total,telegraf-polling-service
    curl -XPOST http://${INFLUXDB2_SERVICE_HOST}:8086/api/v2/query?org=influxdata -sS \
      -H 'Accept:application/csv' \
      -H 'Content-type:application/vnd.flux' \
      -H 'Authorization: Token admin12345' \
      -d 'from(bucket:"telegraf")
            |> range(start:-1m)
            |> filter(fn: (r) => r["_measurement"] == "cpu")
            |> filter(fn: (r) => r["_field"] == "usage_system")
            |> filter(fn: (r) => r["host"] == "telegraf-polling-service")
            |> filter(fn: (r) => r["cpu"] == "cpu-total")
            |> last()' > metrics.csv


    cpu_usage=$(while IFS=, read -r dummy result table start stop time value field measurement cpu host; do
      if [ "$value" != "_value" ]; then
        echo $value
      fi
    done < metrics.csv)

    echo $cpu_usage
# Push metrics to pushgateway every 2 seconds.
cat <<EOF | curl --data-binary @- http://${PUSHGATEWAY_SERVICE_HOST}:9091/metrics/job/influxdb
# HELP intel_influxdb_cpu_usage cpu usage (%)
# TYPE intel_influxdb_cpu_usage gauge
intel_influxdb_cpu_usage $cpu_usage
EOF

    sleep 2
done