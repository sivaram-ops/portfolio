FROM redis:7.2-alpine
LABEL org.opencontainers.image.title="roboshop-redis" \
      org.opencontainers.image.description="Redis database as microservice for RoboShop" \
      org.opencontainers.image.version="v9" \
      org.opencontainers.image.authors="SIVARAM" \
      custom.environment="dev/staging"
EXPOSE 6379
CMD ["redis-server", "--appendonly", "yes"]