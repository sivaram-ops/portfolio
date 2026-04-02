FROM mongo:6.0.14
LABEL org.opencontainers.image.title="roboshop-mongodb" \
      org.opencontainers.image.description="Mongodb database as microservice for RoboShop" \
      org.opencontainers.image.version="v9" \
      org.opencontainers.image.authors="SIVARAM" \
      custom.environment="dev/staging"
COPY --chown=999:999 --chmod=0444 *.js /docker-entrypoint-initdb.d/
EXPOSE 27017