# Stage 1:
FROM python:3.9.18-alpine3.19 AS builder
WORKDIR /build-dir
RUN apk add --no-cache python3-dev build-base linux-headers pcre-dev
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
# Stage 2:
FROM python:3.9.18-alpine3.19
LABEL org.opencontainers.image.title="roboshop-payment" \
      org.opencontainers.image.description="Payment application as microservice for RoboShop" \
      org.opencontainers.image.version="v9" \
      org.opencontainers.image.authors="SIVARAM" \
      custom.environment="dev/staging"
WORKDIR /payment
RUN apk add --no-cache pcre && addgroup -g 1001 roboshop && adduser -S -u 1001 -G roboshop roboshop
COPY --from=builder /usr/local /usr/local
COPY ./app-code .
RUN chown -R roboshop:roboshop /payment
USER 1001
ENV PYTHONUNBUFFERED=1
EXPOSE 8080
CMD ["uwsgi", "--ini", "payment.ini"]