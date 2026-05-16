ARG VERSION=26.1.2
ARG JAVA_VERSION=26

FROM docker.io/eclipse-temurin:${JAVA_VERSION}-jammy AS builder
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
FROM docker.io/eclipse-temurin:${JAVA_VERSION}-jammy
RUN apt-get update && apt-get -y install curl jq unzip gettext-base && rm -rf /var/lib/apt/lists/*
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
RUN PAPER_API=https://fill.papermc.io/v3/projects/paper && \
    URL=$(curl -s ${PAPER_API}/versions/${VERSION}/builds/latest | jq -r '.downloads["server:default"].url') && \
    curl -o paper.jar "${URL}"

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
