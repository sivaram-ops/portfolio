FROM rabbitmq:3.12-management-alpine
LABEL org.opencontainers.image.title="roboshop-rabbitmq" \
      org.opencontainers.image.description="RabbitMQ as microservice for RoboShop" \
      org.opencontainers.image.version="v9" \
      org.opencontainers.image.authors="SIVARAM" \
      custom.environment="dev/staging"
HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD rabbitmq-diagnostics -q ping || exit 1
EXPOSE 5672 15672