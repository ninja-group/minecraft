#!/bin/bash
exec java -XX:+UseG1GC -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M \
          -Xms$1 -Xmx$1 -jar /paper.jar --nogui
