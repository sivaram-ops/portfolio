FROM mysql:5.7
RUN mkdir -p /etc/mysql/conf.d
COPY shipping.sql /docker-entrypoint-initdb.d/shipping.sql
EXPOSE 3306