# =====================================================================
#  MiniMax H3 + ComfyUI 一鍵環境安裝腳本 (Windows + NVIDIA)
# =====================================================================
#  這支腳本會：
#    1. 用 git clone 最新版 ComfyUI 到 .\ComfyUI（若不存在）
#    2. 用 uv 建立 Python 3.12 虛擬環境
#    3. 安裝 Blackwell 顯卡需要的 PyTorch (cu130) 與 ComfyUI 相依套件
#    4. 把 .\workflows\ 內的工作流程複製進 ComfyUI 的工作流程資料夾
#    5. 驗證 GPU
#
#  前置需求（新電腦請先裝好）：
#    - NVIDIA 顯卡 + 支援 CUDA 13 的較新驅動
#    - git        https://git-scm.com/
#    - uv         https://astral.sh/uv
#
#  安裝完成後，下載模型：  ComfyUI\.venv\Scripts\python.exe download_models.py
#  啟動：                  雙擊 start.bat
#
#  用法：於此資料夾 PowerShell 執行  .\setup.ps1
# =====================================================================

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

function Need($cmd, $url) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        Write-Host "缺少 $cmd，請先安裝：$url" -ForegroundColor Red
        exit 1
    }
}
Need git "https://git-scm.com/"
Need uv  "https://astral.sh/uv"

# 1) 取得 ComfyUI 原始碼
if (-not (Test-Path ".\ComfyUI\main.py")) {
    Write-Host "==> Clone 最新版 ComfyUI"
    git clone --depth 1 https://github.com/comfyanonymous/ComfyUI.git
} else {
    Write-Host "==> 已存在 ComfyUI，略過 clone"
}

Set-Location "$PSScriptRoot\ComfyUI"

# 2) 建立虛擬環境
Write-Host "==> 建立 Python 3.12 venv"
if (Test-Path ".\.venv") { Remove-Item ".\.venv" -Recurse -Force }
uv venv --python 3.12 .venv

# 3) 安裝 PyTorch（依顯卡自動判斷）
$py = ".\.venv\Scripts\python.exe"
$gpuNames = (Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name) -join " | "
$isNvidia = ($null -ne (Get-Command nvidia-smi -ErrorAction SilentlyContinue)) -or ($gpuNames -match "NVIDIA")
$isAmd = ($gpuNames -match "AMD|Radeon")

if ($isNvidia) {
    Write-Host "==> 偵測到 NVIDIA 顯卡，安裝 PyTorch cu130"
    uv pip install --python $py torch==2.14.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu130
} elseif ($isAmd) {
    Write-Host "偵測到 AMD 顯卡：$gpuNames" -ForegroundColor Yellow
    Write-Host "Windows 上 AMD 需依 ComfyUI 官方 ROCm/DirectML 說明手動安裝 PyTorch（較複雜、屬實驗性）：" -ForegroundColor Yellow
    Write-Host "  https://github.com/comfyanonymous/ComfyUI#amd-gpus" -ForegroundColor Yellow
    Write-Host "裝好對應 PyTorch 後，再執行： uv pip install --python $py -r requirements.txt" -ForegroundColor Yellow
    Write-Host "註：MiniMax H3 量化核心以 CUDA 為主，非 NVIDIA 不保證可跑。" -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "未偵測到 NVIDIA/AMD 獨立顯卡（$gpuNames）。純 CPU 無法實際生成影片。" -ForegroundColor Red
    exit 1
}

Write-Host "==> 安裝 ComfyUI 相依套件"
uv pip install --python $py -r requirements.txt

# 4) 放置工作流程
$wfSrc = "$PSScriptRoot\workflows"
$wfDst = "$PSScriptRoot\ComfyUI\user\default\workflows"
if (Test-Path $wfSrc) {
    New-Item -ItemType Directory -Force -Path $wfDst | Out-Null
    Copy-Item "$wfSrc\*.json" $wfDst -Force -ErrorAction SilentlyContinue
    Write-Host "==> 已複製工作流程到 ComfyUI"
}

# 5) 驗證 GPU
Write-Host "==> 驗證 GPU"
.\.venv\Scripts\python.exe -c "import torch;print('CUDA:',torch.cuda.is_available(), torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'NO GPU', '| torch', torch.__version__)"

Set-Location $PSScriptRoot
Write-Host ""
Write-Host "環境安裝完成！" -ForegroundColor Green
Write-Host "下一步 1/2  下載模型(約44GB)： .\ComfyUI\.venv\Scripts\python.exe download_models.py" -ForegroundColor Yellow
Write-Host "下一步 2/2  啟動：             雙擊 start.bat（或 .\start.bat）" -ForegroundColor Yellow
