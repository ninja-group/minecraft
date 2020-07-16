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
ARG SILKSPAWNERS_URL=https://github.com/timbru31/SilkSpawners/releases/download/silkspawners-6.3.1/SilkSpawners.jar
ARG ESSENTIALSX_URL=https://github.com/EssentialsX/Essentials/releases/download/2.18.0/EssentialsX-2.18.0.0.jar
ARG BLOCKLOCKER_URL=https://github.com/rutgerkok/BlockLocker/releases/download/v1.8.1/BlockLocker.jar
ARG PAPER_API=https://papermc.io/api/v1/paper

# Runtime config
ENV HEAP=2G
ENV OPS=
ENV ALLOW=
EXPOSE 25565
VOLUME [ "/data" ]

# Download latest Paper release
WORKDIR /
RUN export BUILD=`curl -Ls ${PAPER_API}/${VERSION} | jq -j '.builds.latest'` && \
    curl -Lo paper.jar ${PAPER_API}/${VERSION}/${BUILD}/download

# Download plugins with binary releases
WORKDIR /plugins
RUN curl -Lo SilkSpawners.jar ${SILKSPAWNERS_URL} && \
    curl -Lo EssentialsX.jar ${ESSENTIALSX_URL} && \
    curl -Lo BlockLocker.jar ${BLOCKLOCKER_URL}

# Copy files
WORKDIR /
COPY --from=builder /build/mcMMO.jar plugins/mcMMO.jar
COPY datapacks datapacks
COPY conf conf
COPY startup.sh .
COPY run-server.sh .
COPY users-to-json.sh .

RUN useradd -rd /data minecraft
WORKDIR /data
CMD /startup.sh
