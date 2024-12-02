FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
RUN apt update && apt install nginx -y
COPY 2113_earth/* /var/www/html/
CMD ["nginx", "-g", "daemon off"]