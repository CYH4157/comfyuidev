# MiniMax H3 本地文生影片（ComfyUI）

在本機用開源的 **MiniMax H3** 模型 + **ComfyUI** 做文字生成影片（含原生音訊）。
本 repo 只放安裝腳本、下載腳本與工作流程；ComfyUI 原始碼與約 44GB 的模型**不進版控**，由腳本自動取得。

---

## 需求

- **作業系統**：Windows 10/11
- **顯卡**：NVIDIA，建議 12GB VRAM 以上（Blackwell / Ada / Ampere 皆可），需支援 CUDA 13 的較新驅動
- **硬碟**：至少 60GB 可用空間（模型約 44GB）
- **記憶體**：建議 32GB（顯存不足時靠 RAM offload）
- **先安裝好**：
  - git — <https://git-scm.com/>
  - uv （Python 環境管理器）— <https://astral.sh/uv>

> Blackwell（RTX 50 系列）**必須**用 cu130 版 PyTorch，否則 ComfyUI 的最佳化 CUDA 核心（nvfp4 / int8_convrot）會被停用。腳本已預設 cu130。

---

## 安裝步驟

安裝腳本會**自動偵測顯卡**選對 PyTorch（NVIDIA→cu130、AMD→ROCm、Apple Silicon→MPS）。

### Windows（NVIDIA，主要支援）

```powershell
git clone <你的-repo-網址> minmaxm3
cd minmaxm3
powershell -ExecutionPolicy Bypass -File .\setup.ps1          # 建環境
.\ComfyUI\.venv\Scripts\python.exe download_models.py         # 下載 44GB 模型
.\start.bat                                                    # 啟動
```

### Linux / macOS

```bash
git clone <你的-repo-網址> minmaxm3
cd minmaxm3
chmod +x setup.sh start.sh
./setup.sh                                    # 建環境（自動偵測 NVIDIA/AMD/Apple）
./ComfyUI/.venv/bin/python download_models.py # 下載 44GB 模型
./start.sh                                    # 啟動
```

啟動後開 <http://127.0.0.1:8188>。

---

## 使用

1. 啟動後開 <http://127.0.0.1:8188>
2. 左側「工作流程」→ 開啟 **烽火邊關_H3_t2v**（已內建中文提示詞與正確模型設定）
   - 或「範本」搜尋 `MiniMax H3` → 選「MiniMax H3：文生影片」自行建立
3. 修改大節點裡的 **prompt**，按右上 **▶ 執行**
4. 成品存於 `ComfyUI\output\video\`，也會顯示在「儲存影片」節點

### 12GB 顯存的解析度對照（改「解析度選擇器」的 megapixels）

| megapixels | 輸出 (16:9) | 建議 |
|---|---|---|
| 0.2 | 608×352 | 最快，測試用（實測 5 秒片約 4 分鐘）|
| 0.3 | 736×416 | 日常較穩 |
| 0.4 | 864×480 | 可試，較慢 |
| 0.98 | 1344×768 | 官方 768p，12GB 易 OOM，顯存大再用 |

策略：先用小尺寸短秒數多抽種子挑構圖，滿意再拉高解析度／時長重生成。

---

## 模型清單（download_models.py 會抓，來源 HuggingFace `Comfy-Org/MiniMax-H3`）

| 檔案 | 目錄 | 大小 |
|---|---|---|
| minimax_h3_fl2va_pruned_int8_convrot.safetensors | diffusion_models | 21GB |
| qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors | text_encoders | 15.7GB |
| minimax_h3_video_vae_fp16.safetensors | vae | 5.2GB |
| minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors | loras | 2GB |
| minimax_h3_audio_vae_fp32.safetensors | vae | 0.6GB |

---

## 專案結構

```
minmaxm3/
├── README.md
├── .gitignore            # 排除 ComfyUI/、模型、venv、輸出
├── .gitattributes        # .sh 強制 LF 換行
├── setup.ps1             # Windows 一鍵安裝
├── setup.sh              # Linux/macOS 一鍵安裝
├── download_models.py    # 下載 44GB 官方模型（跨平台）
├── start.bat             # Windows 啟動
├── start.sh              # Linux/macOS 啟動
├── workflows/
│   └── 烽火邊關_H3_t2v.json   # 內建範例工作流程
└── ComfyUI/              # (git 忽略) 由 setup 腳本產生
```

---

## 平台支援與注意

| 平台 | 顯卡 | PyTorch | 狀態 |
|---|---|---|---|
| Windows / Linux | NVIDIA | cu130 | ✅ 完整支援（開發／實測平台）|
| Linux | AMD | ROCm | ⚠️ 實驗性，index-url 需依你的 ROCm 版本調整 |
| macOS | Apple Silicon | 預設(MPS) | ⚠️ 實驗性 |
| Windows | AMD | ROCm/DirectML | ⚠️ 需手動，見 ComfyUI 官方說明 |

> **重要**：MiniMax H3 的量化核心（nvfp4 / int8_convrot）是為 **CUDA** 最佳化的。非 NVIDIA 平台只能走 pure-PyTorch 的 eager 後端，可能明顯較慢，甚至部分運算不支援。若要穩定使用，建議 NVIDIA 顯卡。

## 授權與注意

ComfyUI 與 MiniMax H3 各有其授權，請依原始授權使用。第三方「去審查／越獄版」編碼器非官方發布，來源與授權需自行判斷，並在合法正當用途下使用。
