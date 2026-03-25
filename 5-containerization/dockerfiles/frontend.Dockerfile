FROM nginxinc/nginx-unprivileged:1.25-alpine
WORKDIR /usr/share/nginx/html
USER root
RUN rm -rf /etc/nginx/conf.d/default.conf && rm -rf /usr/share/nginx/html/* && chown -R nginx:nginx /usr/share/nginx/html
USER nginx
COPY --chown=nginx:nginx app-code /usr/share/nginx/html/
# COPY --chown=nginx:nginx nginx.conf /etc/nginx/nginx.conf
EXPOSE 8080
