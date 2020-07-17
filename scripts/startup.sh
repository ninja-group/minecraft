#!/bin/bash
export UNIVERSE="/data/universe"
export PLUGINS="/plugins"

DATAPACKS="${UNIVERSE}/world/datapacks"
DATADIRS="${UNIVERSE}/world /data/logs /data/cache /data/plugins /data/permissions"


# Some plugins (i.e. SilkSpawners) create extra config directories in addition
# to their "own" directory, which we have to deal with if we want those plugins
# to work properly.
PLUGIN_JSON="$(jq --slurpfile s ${PLUGINS}/source-plugins.json '$s+.|flatten' ${PLUGINS}/plugins.json)"
PLUGIN_EXTRADIRS="$(echo ${PLUGIN_JSON} | jq -r 'map(.extradirs)|flatten|.[]|select(.)')"

PLUGIN_NAMES="bStats $(find ${PLUGINS} -name '*.jar' -exec basename \{\} .jar \;)"
PLUGIN_CONFIGDIRS="${PLUGIN_NAMES} ${PLUGIN_EXTRADIRS}"

for p in ${PLUGIN_CONFIGDIRS} ; do
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
