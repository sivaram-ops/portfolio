# Stage 1:
FROM maven:3.9.6-eclipse-temurin-21-alpine AS builder
WORKDIR /shipping
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests -B
# Stage 2:
FROM eclipse-temurin:21-jre-alpine
LABEL maintainer="SIVARAM" org.opencontainers.image.title="RoboShop Shipping Service" \
      org.opencontainers.image.description="a microservice which calculates the shipping cost based on distance" \
      org.opencontainers.image.version="v9"
EXPOSE 8080
RUN addgroup -S roboshop && adduser -S -G roboshop roboshop
WORKDIR /shipping
COPY --from=builder --chown=roboshop:roboshop /shipping/target/shipping-*.jar shipping.jar
USER roboshop
CMD [ "java", "-XX:+ExitOnOutOfMemoryError", "-XX:MaxRAMPercentage=80.0", "-jar", "shipping.jar" ]