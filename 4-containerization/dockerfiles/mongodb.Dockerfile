FROM mongo:6.0.14
LABEL maintainer="SIVARAM" description="Mongodb microservices as container" version="v9" environment="dev/staging"
WORKDIR /docker-entrypoint-initdb.d
COPY --chown=999:999 *.js .
RUN chmod 0444 *.js