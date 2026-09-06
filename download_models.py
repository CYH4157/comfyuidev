"""
下載 MiniMax H3 文生影片所需的官方模型（來源：HuggingFace Comfy-Org/MiniMax-H3）。
檔案會放到 ./ComfyUI/models 對應子資料夾，共約 44GB，支援中斷續傳。

用法（先跑過 setup.ps1 建好 venv 後）：
    ComfyUI\.venv\Scripts\python.exe download_models.py
"""
import os
import time
from huggingface_hub import hf_hub_download

REPO = "Comfy-Org/MiniMax-H3"
# 以本腳本所在位置為基準，指向 ComfyUI/models（可攜，不寫死絕對路徑）
MODELS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "ComfyUI", "models")

# (倉庫內路徑, 約略大小GB) —— 倉庫路徑前綴即對應 ComfyUI/models 下的子資料夾
FILES = [
    ("vae/minimax_h3_audio_vae_fp32.safetensors", 0.61),
    ("loras/minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors", 1.96),
    ("vae/minimax_h3_video_vae_fp16.safetensors", 5.21),
    ("text_encoders/qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors", 15.69),
    ("diffusion_models/minimax_h3_fl2va_pruned_int8_convrot.safetensors", 20.97),
]

def main():
    os.makedirs(MODELS, exist_ok=True)
    total = sum(s for _, s in FILES)
    print(f"下載目的地: {MODELS}")
    print(f"共 {len(FILES)} 個檔案，約 {total:.1f} GB\n")
    for i, (f, gb) in enumerate(FILES, 1):
        print(f"===== [{i}/{len(FILES)}] {f}  (~{gb} GB) =====", flush=True)
        t0 = time.time()
        p = hf_hub_download(repo_id=REPO, filename=f, local_dir=MODELS)
        sz = os.path.getsize(p) / 1e9
        print(f"完成: {sz:.2f} GB, {time.time()-t0:.0f}s\n", flush=True)
    print("全部模型下載完成。")

if __name__ == "__main__":
    main()
