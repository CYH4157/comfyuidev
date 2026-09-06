#!/usr/bin/env bash
# =====================================================================
#  MiniMax H3 + ComfyUI 一鍵環境安裝 (Linux / macOS)
#  自動偵測顯卡：NVIDIA(cu130) / AMD(ROCm) / Apple Silicon(MPS)
#
#  前置需求：git、uv (https://astral.sh/uv)
#  安裝完成後下載模型： ./ComfyUI/.venv/bin/python download_models.py
#  啟動：               ./start.sh
# =====================================================================
set -euo pipefail
cd "$(dirname "$0")"

need() { command -v "$1" >/dev/null 2>&1 || { echo "缺少 $1，請先安裝：$2"; exit 1; }; }
need git "https://git-scm.com/"
need uv  "https://astral.sh/uv"

# 1) 取得 ComfyUI
if [ ! -f "./ComfyUI/main.py" ]; then
  echo "==> Clone 最新版 ComfyUI"
  git clone --depth 1 https://github.com/comfyanonymous/ComfyUI.git
else
  echo "==> 已存在 ComfyUI，略過 clone"
fi

cd ComfyUI

# 2) 建立 venv
echo "==> 建立 Python 3.12 venv"
rm -rf .venv
uv venv --python 3.12 .venv
PY="./.venv/bin/python"

# 3) 依平台/顯卡安裝 PyTorch
OS="$(uname -s)"
if [ "$OS" = "Darwin" ]; then
  echo "==> 偵測到 macOS（Apple Silicon / MPS），安裝預設 PyTorch"
  echo "    註：MiniMax H3 量化核心以 CUDA 為主，MPS 上僅能走 eager 後端，可能較慢或不完全支援。"
  uv pip install --python "$PY" torch torchvision torchaudio
elif command -v nvidia-smi >/dev/null 2>&1; then
  echo "==> 偵測到 NVIDIA 顯卡，安裝 PyTorch cu130"
  uv pip install --python "$PY" torch==2.14.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu130
elif command -v rocminfo >/dev/null 2>&1 || lspci 2>/dev/null | grep -iq "AMD\|Radeon"; then
  echo "==> 偵測到 AMD 顯卡，安裝 PyTorch ROCm（版本號請依你的 ROCm 調整）"
  echo "    如安裝失敗，請至 https://pytorch.org 查對應 ROCm 的 index-url。"
  uv pip install --python "$PY" torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.2
else
  echo "未偵測到可用 GPU；純 CPU 無法實際生成影片。" >&2
  exit 1
fi

echo "==> 安裝 ComfyUI 相依套件"
uv pip install --python "$PY" -r requirements.txt

# 4) 放置工作流程
if [ -d "../workflows" ]; then
  mkdir -p ./user/default/workflows
  cp -f ../workflows/*.json ./user/default/workflows/ 2>/dev/null || true
  echo "==> 已複製工作流程到 ComfyUI"
fi

# 5) 驗證
echo "==> 驗證"
"$PY" -c "import torch;print('device ok | torch', torch.__version__, '| cuda', torch.cuda.is_available(), '| mps', getattr(getattr(torch,'backends',None),'mps',None) and torch.backends.mps.is_available())"

echo ""
echo "環境安裝完成！"
echo "下一步 1/2  下載模型(約44GB)： ./ComfyUI/.venv/bin/python download_models.py"
echo "下一步 2/2  啟動：             ./start.sh"
