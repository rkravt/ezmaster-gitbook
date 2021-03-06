FROM nginx:1.13.12

# to help docker debugging
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -y update && apt-get -y install vim curl gnupg2 git jq procps

# nodejs instalation used for startup scripts
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install -y build-essential nodejs

#install dependencies
RUN mkdir -p /app
WORKDIR /app
COPY ./package.json /app/package.json

RUN npm install npm-watch -g
RUN npm install gitbook-cli@2.3.2 -g

#ENTRYPOINT
COPY config.json /
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
COPY pull.periodically.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/pull.periodically.sh
COPY watcher.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/watcher.sh

#Html file creation to indicate the end of the build
COPY build.html /app/

# nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# ezmasterization of gitbook
# see https://github.com/Inist-CNRS/ezmaster-gitbook
RUN echo '{ \
  "httpPort": 80, \
  "configPath": "/config.json", \
  "configType": "json", \
  "dataPath": "/app/src/" \
}' > /etc/ezmaster.json

ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]
