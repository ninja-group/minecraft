ARG VERSION=1.16.1
FROM openjdk:11 AS builder
RUN apt-get update && apt-get -y install git maven gradle jq && apt-get clean

ARG MCMMO_REPO=https://github.com/mcMMO-Dev/mcMMO.git
ARG MCMMO_TAG=master

# Build mcMMO
WORKDIR /build
COPY source-plugins.json .
COPY build-scripts .
RUN jq -c '.[]' source-plugins.json | while read json ; do \
        ./build-plugin.sh "$json" ; \
    done

# Set up run-time image
FROM openjdk:11-jre-slim
RUN apt-get update && apt-get -y install curl jq unzip && apt-get clean
ARG VERSION

# Runtime config
ENV HEAP=2G
ENV OPS=
ENV ALLOW=
EXPOSE 25565
VOLUME [ "/data" ]

# Download latest Paper release
WORKDIR /
RUN export PAPER_API=https://papermc.io/api/v1/paper && \
    export BUILD=`curl -fLs ${PAPER_API}/${VERSION} | jq -j '.builds.latest'` && \
    curl -fLo paper.jar ${PAPER_API}/${VERSION}/${BUILD}/download

# Install plugins
WORKDIR /plugins
COPY --from=builder /build/*.jar .
COPY plugins.json .
RUN jq -c '.[]' plugins.json | while read json ; do \
      export name="$(echo $json | jq -j '.name')" ; \
      export url="$(echo $json | jq -j '.url')" ; \
      curl -fLo "$name.jar" "$url" || exit 1 ; \
    done

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
    chown -R minecraft:minecraft . && \
    chown minecraft:minecraft /datapacks && \
    echo "eula=true" > eula.txt && \
    mkdir plugins && chown minecraft:minecraft plugins && \
    find /plugins -type f -exec ln -s \{\} plugins/ \; && \
    ln -s /data/logs && \
    ln -s /data/cache && \
    for f in ${PERMISSION_FILES} ; do ln -s /data/permissions/${f} ; done

CMD /startup.sh
