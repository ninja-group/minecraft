#!/bin/bash
mkdir -p plugins world/datapacks
chown minecraft:minecraft . plugins world world/datapacks
for plugin in `find /plugins -type f`; do ln -sf $plugin plugins/ ; done
for pack in `find /datapacks -type f`; do ln -sf $pack world/datapacks/ ; done
ln -sf /conf/server.properties
ln -sf /conf/paper.yml
echo eula=true > eula.txt

setpriv --reuid=minecraft \
        --regid=minecraft \
        --init-groups \
        --inh-caps=-all \
        /run-server.sh
