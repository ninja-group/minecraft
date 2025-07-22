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

apply_env() {
  confdir=$(realpath "$1")
  for conf in $(find "$confdir" -name '*.envsubst') ; do
    echo "Applying environment substitition to ${conf}"
    dir_out=$(dirname "$conf")
    file_out=$(basename "$conf" .envsubst)
    path_out="$dir_out/$file_out"
    cat "${conf}" | envsubst > "$path_out"
  done
}

# Setup persistent config and data directories
for p in ${PLUGIN_CONFIGDIRS} ; do
  dir="/data/plugins/${p}"
  mkdir -p "${dir}"
  [ -L "/plugins/${p}" ] || ln -sf "${dir}" "/plugins/${p}"
done
mkdir -p ${DATADIRS}
mkdir -p ${DATAPACKS}
chown -R minecraft:minecraft /data
rm -rf ${DATAPACKS}/*
cp -rf /datapacks/* ${DATAPACKS}/

# Apply any baked-in configurations
for conf in `ls /plugin-conf` ; do
  source="/plugin-conf/$(basename ${conf})"
  target="/data/plugins/$(basename ${conf})"
  if [ -d "${target}" ] ; then
    echo "Applying baked-in config for ${conf}"
    cp -rf "${source}"/* "${target}/"
    apply_env "${target}"
    chown -R minecraft:minecraft "${target}"
  fi
done

caps=$(seq -f "-cap_%.0f" -s "," 0 `cat /proc/sys/kernel/cap_last_cap`)

setpriv --reuid=minecraft \
        --regid=minecraft \
        --init-groups \
        --inh-caps=$caps \
        /scripts/run-server.sh
