# How to use?
## Requirements

1. Operating System: Ubuntu 22.04

2. Disk Configuration: 100 GB system disk, 1 TB data disk

3. Software that must be installed:
    - Docker
    - Docker Compose 
    - Python 3.10 or later

## Step by Step
### Step 1: Docker compose runs all the components
1. File structure
    ```shell
    /data
    ├── docker-compose             # docker compose configure
    │   ├── docker-compose.yml
    │   ├── grafana-provisioning
    │   │   └── datasources
    │   │       └── datasource.yml
    │   ├── otel-config.yaml
    │   ├── prometheus.yml
    │   ├── python-app
    │   │   └── app.py
    │   └── tempo.yaml
    ├── grafana                     # Grafana data
    ├── loki                        # Loki logs data
    ├── otel-collector              # OpenTelemetry Collector logs data
    ├── prometheus                  # Prometheus data
    └── tempo                       # Tempo traces data
    ```
2. Create directory
    ```shell
    sudo mkdir -p /data/{otel-collector,prometheus,loki,tempo,grafana,docker-compose}
    sudo mkdir -p /data/docker-compose/python-app
    sudo mkdir -p /data/otel-collector/logs
    sudo mkdir -p /data/docker-compose/grafana-provisioning/datasources/
    sudo chmod -R 777 /data
    sudo chown -R 65534:65534 /data/prometheus  # Prometheus user
    sudo chown -R 10001:10001 /data/loki       # Loki user
    sudo chown -R 472:472 /data/grafana        # Grafana user
    ```
3. Clone repo
    ```shell
    git clone https://github.com/mo-silent/o11y-deploy.git
    cd o11y-deploy/single-grafana
    sudo cp -r ./* /data/docker-compose
    ```
4. Run service
    ```shell
    cd /data/docker-compose/
    sudo mv grafana-datasource.yml /data/docker-compose/grafana-provisioning/datasources/datasource.yml
    sudo docker compose up -d
    ```
5. Check service status
    ```shell
    $  sudo docker ps
    ```

### Step 2: Run python test application
1. Install dependencies
    ```shell
    cd /data/docker-compose/python-app
    python3 -m venv venv
    source venv/bin/activate
    pip3 install opentelemetry-distro opentelemetry-exporter-otlp-proto-http opentelemetry-instrumentation-logging opentelemetry-instrumentation-requests requests
    opentelemetry-bootstrap -a install
    ```
2. Run app
    ```shell
    export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318
    export OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
    export OTEL_SERVICE_NAME=my-app
    export OTEL_TRACES_EXPORTER=otlp
    export OTEL_METRICS_EXPORTER=otlp
    export OTEL_LOGS_EXPORTER=otlp
    export OTEL_PYTHON_LOG_LEVEL=info
    export OTEL_PYTHON_LOG_CORRELATION=true
    export OTEL_PYTHON_LOGGING_AUTO_INSTRUMENTATION_ENABLED=true
    opentelemetry-instrument python3 app.py
    ```
### Step 3: Verify data
1. Logs
    - curl
        ```shell
        curl -G "http://localhost:3100/loki/api/v1/query_range" \
        --data-urlencode 'query={service_name="test-app"}' \
        --data-urlencode 'start=1744803330892070099' \
        --data-urlencode 'end=1744805130892070099' \
        --data-urlencode 'limit=100'
        ```
2. Metrics
    - curl 
        ```shell
        curl http://locahost:8889/metrics
        ```
3. Traces
    - curl 
        ```shell
        curl -G -s http://localhost:3200/api/search --data-urlencode 'tags=service.name=cartservice' --data-urlencode minDuration=600ms
        ```