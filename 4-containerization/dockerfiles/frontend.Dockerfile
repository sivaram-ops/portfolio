FROM nginxinc/nginx-unprivileged:1.25-alpine
LABEL org.opencontainers.image.title="roboshop-frontend" \
      org.opencontainers.image.description="Frontend microservice for RoboShop" \
      org.opencontainers.image.version="v9" \
      org.opencontainers.image.authors="SIVARAM" \
      custom.environment="dev/staging"
WORKDIR /usr/share/nginx/html
USER root
RUN rm -rf /etc/nginx/conf.d/default.conf && rm -rf /usr/share/nginx/html/* && chown -R nginx:nginx /usr/share/nginx/html
USER nginx
COPY --chown=nginx:nginx app-code /usr/share/nginx/html/
COPY --chown=nginx:nginx nginx.conf /etc/nginx/nginx.conf
EXPOSE 8888
