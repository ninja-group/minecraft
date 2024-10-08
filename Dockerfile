ARG VERSION=1.21.1
FROM docker.io/openjdk:21-bullseye AS builder
RUN apt-get update && apt-get -y install git maven gradle jq && rm -rf /var/lib/apt/lists/*

# Build source plugins
WORKDIR /build
COPY source-plugins.json .
COPY build-scripts .
RUN jq -c '.[]' source-plugins.json | while read json ; do \
        ./build-plugin.sh "$json" ; \
    done ; \
    rm *.sh

# Set up run-time image
FROM docker.io/openjdk:21-slim-bullseye
RUN apt-get update && apt-get -y install curl jq unzip && rm -rf /var/lib/apt/lists/*
ARG VERSION

# Runtime config
ENV HEAP=2G
ENV OPS=
ENV ALLOW=
EXPOSE 25565 8123
VOLUME [ "/data" ]

# Copy build scripts
WORKDIR /build
COPY build-scripts .

# Download latest Paper release
WORKDIR /minecraft
RUN export PAPER_API=https://papermc.io/api/v2/projects/paper && \
    export BUILD=`curl -fLs ${PAPER_API}/versions/${VERSION} | jq -j '.builds[-1]'` && \
    curl -fLo paper.jar ${PAPER_API}/versions/${VERSION}/builds/${BUILD}/downloads/paper-${VERSION}-${BUILD}.jar

# Install plugins
WORKDIR /plugins
COPY --from=builder /build .
COPY plugins.json .
COPY source-plugins.json .
COPY plugin-jars .
RUN jq -c '.[]' plugins.json | while read json ; do \
        export name="$(echo $json | jq -j '.name')" ; \
        export url="$(echo $json | jq -j '.url')" ; \
        export jar="$(echo $json | jq -j '.jar')" ; \
        [ -f "$name.jar" ] || mv "$jar" "$name.jar" || true ; \
        [ -f "$name.jar" ] || curl -fLo "$name.jar" "$url" || exit 1 ; \
        export realname=$(/build/plugin-name.sh "${name}.jar") ; \
        mv "$name.jar" "$realname.jar" || true ; \
    done && \
    # Disable automatic updates for plugins that support it
    mkdir Updater && \
    echo "disable: true" > Updater/config.yml

# Install datapacks, scripts and plugin configs
WORKDIR /
COPY datapacks datapacks
COPY plugin-conf plugin-conf
COPY scripts scripts

# Set up Minecraft working directory
WORKDIR /minecraft
COPY conf .
RUN export PERMISSION_FILES="permissions.yml ops.json whitelist.json banned-ips.json banned-players.json" && \
    useradd -rd `realpath .` minecraft && \
    chown -R minecraft:minecraft . && \
    chown minecraft:minecraft /datapacks && \
    chown minecraft:minecraft /plugins && \
    echo "eula=true" > eula.txt && \
    ln -s /data/logs && \
    for f in ${PERMISSION_FILES} ; do ln -s /data/permissions/${f} ; done ; \
    rm -rf /build

RUN bash -c '/scripts/startup.sh & sleep 30 ; kill %1' && \
    rm -rf /data/*

CMD /scripts/startup.sh
