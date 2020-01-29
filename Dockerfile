FROM openjdk:slim-buster
LABEL maintainer="HimaJyun"

ENV EULA="false"
ENV VERSION="latest"
ENV JVM_OPTS="-XX:+UseG1GC -XX:MaxGCPauseMillis=50"
ENV SERVER_OPTS="nogui"

COPY minecraft.sh /minecraft.sh

RUN set -x \
    && groupadd -r minecraft \
    && useradd -r -s /bin/false -d /minecraft -M -g minecraft minecraft \
    && apt-get update \
    && apt-get install -y gosu curl jq \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

VOLUME /minecraft

EXPOSE 25565

CMD ["/minecraft.sh"]
