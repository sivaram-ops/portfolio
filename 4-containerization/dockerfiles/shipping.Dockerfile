# Stage 1:
FROM maven:3.9.6-eclipse-temurin-21-alpine AS builder
WORKDIR /shipping
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests -B
# Stage 2:
FROM eclipse-temurin:21-jre-alpine
LABEL org.opencontainers.image.title="roboshop-shipping" \
      org.opencontainers.image.description="Shipping microservice for RoboShop" \
      org.opencontainers.image.version="v9" \
      org.opencontainers.image.authors="SIVARAM" \
      custom.environment="dev/staging"
RUN addgroup -S roboshop && adduser -S -G roboshop roboshop
WORKDIR /shipping
COPY --from=builder --chown=roboshop:roboshop /shipping/target/shipping-*.jar shipping.jar
USER roboshop
EXPOSE 8080
CMD [ "java", "-XX:+ExitOnOutOfMemoryError", "-XX:MaxRAMPercentage=80.0", "-jar", "shipping.jar" ]