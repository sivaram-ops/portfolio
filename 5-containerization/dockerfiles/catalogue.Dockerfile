# Stage 1:
FROM node:alpine AS builder
WORKDIR /build-dir
COPY ./app-code/package*.json ./
RUN npm install --omit=dev 
# Stage 2:
FROM node:alpine
RUN apk add --no-cache dumb-init
RUN addgroup -g 1001 roboshop && adduser -u 1001 -G roboshop -s /bin/sh -D roboshop
WORKDIR /catalogue-app
ENV NODE_ENV=production
ENV MONGO=true
ENV MONGO_URL="mongodb://mongodb:27017/catalogue"
RUN chown roboshop:roboshop /catalogue-app
USER 1001
COPY --chown=1001:1001 ./app-code/server.js .
COPY --chown=1001:1001 --from=builder /build-dir/node_modules ./node_modules 
EXPOSE 8080
CMD ["dumb-init", "node", "server.js"]