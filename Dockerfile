FROM node:18 AS builder
WORKDIR /maputnik

# Only copy package.json to prevent npm install from running on every build
COPY package.json package-lock.json .npmrc ./
RUN npm ci

# Build maputnik
COPY . .
RUN npm run build

RUN apt-get update && apt-get install -y golang make
RUN npm run build-desktop

#---------------------------------------------------------------------------
# Create a clean nginx-alpine slim image with just the build results
FROM nginx:alpine-slim

COPY --from=builder /maputnik/dist /usr/share/nginx/html/

COPY --from=builder /maputnik/desktop/bin/linux/maputnik /usr/bin/maputnik
RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

ADD ./desktop/docker/start.sh /docker-entrypoint.d/99-start-maputnik.sh

ENV MAPUTNIK=false
ENV SUBPATH=/maputnik

VOLUME [ "/data" ]