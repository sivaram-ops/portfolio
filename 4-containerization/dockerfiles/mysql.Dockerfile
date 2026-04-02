FROM mysql:5.7
LABEL org.opencontainers.image.title="roboshop-mysql" \
      org.opencontainers.image.description="MySQL database as microservice for RoboShop" \
      org.opencontainers.image.version="v9" \
      org.opencontainers.image.authors="SIVARAM" \
      custom.environment="dev/staging"
COPY --chmod=0444 shipping.sql /docker-entrypoint-initdb.d/shipping.sql
EXPOSE 3306