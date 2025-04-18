#!/bin/bash

python3 -m venv venv
source venv/bin/activate
pip3 install opentelemetry-distro opentelemetry-exporter-otlp-proto-http opentelemetry-instrumentation-logging opentelemetry-instrumentation-requests requests
opentelemetry-bootstrap -a install

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