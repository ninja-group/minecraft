#!/bin/bash
export UNIVERSE="/data/universe"
export PLUGINS="/plugins"

DATAPACKS="${UNIVERSE}/world/datapacks"
DATADIRS="${UNIVERSE}/world /data/logs /data/cache /data/plugins /data/permissions"
PLUGIN_NAMES="bStats $(find ${PLUGINS} -name '*.jar' -exec basename \{\} .jar \;)"

for p in ${PLUGIN_NAMES} ; do
  dir="/data/plugins/${p}"
  mkdir -p "${dir}"
  ln -sf "${dir}" "/plugins/${p}"
done

mkdir -p ${DATADIRS}
chown -R minecraft:minecraft /data

ln -sf /datapacks ${DATAPACKS}

setpriv --reuid=minecraft \
        --regid=minecraft \
        --init-groups \
        --inh-caps=-all \
        /run-server.sh
