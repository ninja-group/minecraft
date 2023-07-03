#!/bin/bash

# Merge ops/allow from config with ops/allow set by Minecraft
cp ops.json ops.json.old
/scripts/users-to-json.sh $OPS | \
  jq 'map(. + {"level":4, "bypassesPlayerLimit":true})' > ops.json.env
cat ops.json.env ops.json.old | jq '.[]' | jq -s '' | \
  jq 'unique_by(.uuid)' > ops.json
rm ops.json.env ops.json.old

cp whitelist.json allow.json.old
/scripts/users-to-json.sh $OPS $ALLOW > allow.json.env
cat allow.json.env allow.json.old | jq '.[]' | jq -s '' | \
  jq 'unique_by(.uuid)' > whitelist.json
rm allow.json.env allow.json.old

exec java -XX:+UseG1GC -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M \
          -Xms$HEAP -Xmx$HEAP -jar /minecraft/paper.jar \
          --nojline \
          --universe ${UNIVERSE} \
          --plugins ${PLUGINS}
