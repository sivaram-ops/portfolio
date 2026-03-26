FROM redis:7.2-alpine
LABEL maintainer="SIVARAM" component="redis microservice"
RUN mkdir -p /data && chown redis:redis /data
EXPOSE 6379
USER redis
CMD ["redis-server", "--appendonly", "yes"]