ARG VERSION=1.16.1
FROM openjdk:11 AS builder
RUN apt-get update && apt-get -y install git maven && apt-get clean

ARG MCMMO_REPO=https://github.com/mcMMO-Dev/mcMMO.git
ARG MCMMO_TAG=master

# Build mcMMO
WORKDIR /build
RUN git clone ${MCMMO_REPO} && \
    cd mcMMO && \
    git checkout ${MCMMO_TAG} && \
    mvn package && \
    mv target/mcMMO.jar /build/mcMMO.jar && \
    cd .. && rm -rf mcMMO

# Set up run-time image
FROM openjdk:11-jre-slim
RUN apt-get update && apt-get -y install curl jq && apt-get clean

ARG VERSION
ARG SILKSPAWNERS=https://github.com/timbru31/SilkSpawners/releases/download/silkspawners-6.3.1/SilkSpawners.jar
ARG ESSENTIALSX=https://github.com/EssentialsX/Essentials/releases/download/2.18.0/EssentialsX-2.18.0.0.jar
ARG BLOCKLOCKER=https://github.com/rutgerkok/BlockLocker/releases/download/v1.8.1/BlockLocker.jar

# Runtime config
ENV HEAP=2G
ENV OPS=
ENV ALLOW=
EXPOSE 25565
VOLUME [ "/data" ]

# Download latest Paper release
WORKDIR /
RUN export PAPER_API=https://papermc.io/api/v1/paper && \
    export BUILD=`curl -Ls ${PAPER_API}/${VERSION} | jq -j '.builds.latest'` && \
    curl -Lo paper.jar ${PAPER_API}/${VERSION}/${BUILD}/download

# Install plugins
WORKDIR /plugins
RUN curl -Lo SilkSpawners.jar ${SILKSPAWNERS} && \
    curl -Lo EssentialsX.jar ${ESSENTIALSX} && \
    curl -Lo BlockLocker.jar ${BLOCKLOCKER}
COPY --from=builder /build/mcMMO.jar .

# Install datapacks
WORKDIR /
COPY datapacks datapacks

# Install scripts
COPY scripts .

# Set up Minecraft environment
WORKDIR /minecraft
COPY conf .
RUN export PERMISSION_FILES="permissions.yml ops.json whitelist.json banned-ips.json banned-players.json" && \
    useradd -rd `realpath .` minecraft && \
    chown minecraft:minecraft . /datapacks && \
    echo "eula=true" > eula.txt && \
    mkdir plugins && chown minecraft:minecraft plugins && \
    find /plugins -type f -exec ln -s \{\} plugins/ \; && \
    ln -s /data/logs && \
    ln -s /data/cache && \
    for f in ${PERMISSION_FILES} ; do ln -s /data/permissions/${f} ; done

CMD /startup.sh