#!/bin/bash

# Merge ops/allow from config with ops/allow set by Minecraft
/scripts/users-to-json.sh $OPS | \
  jq 'map(. + {"level":4, "bypassesPlayerLimit":true})' > ops.json.env
cat ops.json.env ops.json | jq '.[]' | jq -s '' | \
  jq 'unique_by(.uuid)' > ops.json.merged
mv ops.json.merged ops.json
rm ops.json.env

/scripts/users-to-json.sh $OPS $ALLOW > allow.json.env
cat allow.json.env whitelist.json | jq '.[]' | jq -s '' | \
  jq 'unique_by(.uuid)' > allow.json.merged
mv allow.json.merged whitelist.json
rm allow.json.env

exec java -XX:+UseG1GC -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M \
          -Xms$HEAP -Xmx$HEAP -jar /paper.jar \
          --nojline \
          --universe ${UNIVERSE} \
          --plugins ${PLUGINS}
