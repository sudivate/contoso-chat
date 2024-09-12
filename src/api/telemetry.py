import os
import logging
from azure.core.settings import settings
from azure.core.tracing.ext.opentelemetry_span import OpenTelemetrySpan
from azure.monitor.opentelemetry.exporter import AzureMonitorTraceExporter, AzureMonitorMetricExporter, AzureMonitorLogExporter
from fastapi import FastAPI
from opentelemetry import metrics
from opentelemetry import trace
from opentelemetry.sdk._logs.export import BatchLogRecordProcessor
from opentelemetry.sdk._logs import (
    LoggerProvider,
    LoggingHandler,
)
from opentelemetry._logs import set_logger_provider
from opentelemetry.sdk._logs import LoggerProvider, LoggingHandler
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader
from opentelemetry.sdk.resources import SERVICE_NAME, Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor


def setup_azure_monitor_exporters(conn_str: str):
    OTEL_SERVICE_NAME = os.getenv("OTEL_SERVICE_NAME", "contoso-chat-dev")
    resource = Resource(attributes={
        SERVICE_NAME: OTEL_SERVICE_NAME
    })

    # Traces
    tracer_provider = TracerProvider(resource=resource)
    trace.set_tracer_provider(tracer_provider)
    processor = BatchSpanProcessor(
        AzureMonitorTraceExporter.from_connection_string(conn_str)
    )
    tracer_provider.add_span_processor(processor)

    # Metrics
    exporter = AzureMonitorMetricExporter.from_connection_string(conn_str)
    reader = PeriodicExportingMetricReader(exporter,export_interval_millis=60000)
    meter_provider = MeterProvider(metric_readers=[reader])
    metrics.set_meter_provider(meter_provider)

    # Logs
    logger_provider = LoggerProvider(resource=resource)
    set_logger_provider(logger_provider)
    exporter = AzureMonitorLogExporter.from_connection_string(conn_str)
    logger_provider.add_log_record_processor(BatchLogRecordProcessor(exporter, schedule_delay_millis=60000))
    handler = LoggingHandler(level=logging.NOTSET, logger_provider=logger_provider)
    logging.getLogger().addHandler(handler)


def setup_telemetry(app: FastAPI):
    settings.tracing_implementation = OpenTelemetrySpan
    app_insights_conn_str = os.getenv("APPINSIGHTS_CONNECTIONSTRING")
    # Set up exporters
    if app_insights_conn_str:
        setup_azure_monitor_exporters(conn_str=app_insights_conn_str)

    # Instrumentations
    FastAPIInstrumentor.instrument_app(app)