FROM rabbitmq:3.12-management-alpine
HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD rabbitmq-diagnostics -q ping || exit 1