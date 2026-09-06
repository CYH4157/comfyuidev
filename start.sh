#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/ComfyUI"
if [ ! -x "./.venv/bin/python" ]; then
  echo "尚未安裝環境，請先執行 ./setup.sh"
  exit 1
fi
echo "啟動 ComfyUI... 開瀏覽器 http://127.0.0.1:8188"
exec ./.venv/bin/python main.py
