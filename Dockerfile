FROM openjdk:11 AS builder

RUN apt-get update && apt-get -y install curl git maven

# Build mcMMO
ENV MCMMO_REPO https://github.com/mcMMO-Dev/mcMMO.git
WORKDIR /build
RUN git clone ${MCMMO_REPO} && \
    cd mcMMO && \
    mvn package && \
    mkdir -p /plugins && \
    mv target/mcMMO.jar /plugins/mcMMO.jar && \
    cd .. && rm -rf mcMMO

# Download Paper
ENV VERSION 1.16.1
WORKDIR /
RUN curl -Lo paper_versions.json https://papermc.io/api/v1/paper/${VERSION} && \
    export BUILD=`sed -e 's/.*"latest":"\([0-9]\+\)".*/\1/g' paper_versions.json` && \
    curl -Lo paper.jar https://papermc.io/api/v1/paper/${VERSION}/${BUILD}/download && \
    rm paper_versions.json

# Download plugins with binary releases
ENV SILKSPAWNERS_URL https://github.com/timbru31/SilkSpawners/releases/download/silkspawners-6.3.1/SilkSpawners.jar
ENV ESSENTIALSX_URL https://github.com/EssentialsX/Essentials/releases/download/2.18.0/EssentialsX-2.18.0.0.jar
ENV BLOCKLOCKER_URL https://github.com/rutgerkok/BlockLocker/releases/download/v1.8.1/BlockLocker.jar
WORKDIR /plugins
RUN curl -Lo SilkSpawners.jar ${SILKSPAWNERS_URL} && \
    curl -Lo EssentialsX.jar ${ESSENTIALSX_URL} && \
    curl -Lo BlockLocker.jar ${BLOCKLOCKER_URL}

# Set up run-time image
FROM openjdk:11-jre-slim
ENV HEAP 2G
VOLUME [ "/data" ]
RUN apt-get update && apt-get -y install curl jq && apt-get clean
RUN useradd -rd /data minecraft

# Copy all necessary files
WORKDIR /
COPY --from=builder /plugins plugins
COPY --from=builder /paper.jar .
COPY datapacks datapacks
COPY conf conf
COPY run-server.sh .
COPY users-to-json.sh .

WORKDIR /data
EXPOSE 25565
CMD mkdir -p plugins world/datapacks && \
    chown minecraft:minecraft . plugins world world/datapacks && \
    for plugin in `find /plugins -type f`; do ln -sf $plugin plugins/ ; done && \
    for pack in `find /datapacks -type f`; do ln -sf $pack world/datapacks/ ; done && \
    ln -sf /conf/server.properties && \
    ln -sf /conf/paper.yml && \
    echo eula=true > eula.txt && \
    setpriv --reuid=minecraft --regid=minecraft --init-groups --inh-caps=-all /run-server.sh
