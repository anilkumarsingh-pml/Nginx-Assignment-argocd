FROM nginx:alpine

# Build from repo root: docker build --build-arg VERSION=v1 -t nginx-app:v1 app/
# Or from app/: docker build --build-arg VERSION=v1 -t nginx-app:v1 .
ARG VERSION=v1

COPY ${VERSION}/index.html /usr/share/nginx/html/index.html

EXPOSE 80
