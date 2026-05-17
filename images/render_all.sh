#!/bin/bash
cd "$(dirname "$0")"
for name in diagrama_2_1 diagrama_2_2 diagrama_2_3 diagrama_3_2 diagrama_3_3 diagrama_3_4; do
  echo "=== $name ==="
  /home/novox/.local/bin/d2 --theme=0 --layout=dagre --pad=20 "${name}.d2" "${name}.pdf" 2>&1 | tail -2
done
