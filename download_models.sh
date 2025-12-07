#!/bin/bash
set -e

COMFYUI_PATH=/workspace/ComfyUI

echo "========================================"
echo "Checking and downloading required models..."
echo "This may take 30-60 minutes on first run."
echo "========================================"

# Function to download with aria2c (faster, multi-connection, resume support)
download_model() {
    local url=$1
    local dest=$2
    local name=$(basename "$dest")
    
    if [ -f "$dest" ]; then
        echo "✓ Already exists: $name"
        return 0
    fi
    
    echo "⬇ Downloading: $name"
    echo "  From: $url"
    
    # Create directory if needed
    mkdir -p "$(dirname "$dest")"
    
    # Download with aria2c (16 connections, resume enabled)
    aria2c \
        --max-connection-per-server=16 \
        --split=16 \
        --min-split-size=1M \
        --continue=true \
        --max-tries=5 \
        --retry-wait=10 \
        --timeout=600 \
        --connect-timeout=60 \
        --dir="$(dirname "$dest")" \
        --out="$name" \
        "$url"
    
    if [ -f "$dest" ]; then
        echo "✓ Downloaded: $name"
    else
        echo "✗ Failed to download: $name"
        return 1
    fi
}

# Alternative download function using wget (fallback)
download_model_wget() {
    local url=$1
    local dest=$2
    local name=$(basename "$dest")
    
    if [ -f "$dest" ]; then
        echo "✓ Already exists: $name"
        return 0
    fi
    
    echo "⬇ Downloading (wget): $name"
    
    mkdir -p "$(dirname "$dest")"
    
    wget --continue --tries=5 --timeout=60 -O "$dest" "$url"
    
    if [ -f "$dest" ]; then
        echo "✓ Downloaded: $name"
    else
        echo "✗ Failed to download: $name"
        return 1
    fi
}

echo ""
echo "--- Text Encoder ---"
download_model \
    "https://huggingface.co/NSFW-API/NSFW-Wan-UMT5-XXL/resolve/main/nsfw_wan_umt5-xxl_fp8_scaled.safetensors" \
    "${COMFYUI_PATH}/models/text_encoders/nsfw_wan_umt5-xxl_fp8_scaled.safetensors"

echo ""
echo "--- Diffusion Model (High Lighting) ---"
download_model \
    "https://huggingface.co/FX-FeiHou/wan2.2-Remix/resolve/main/NSFW/Wan2.2_Remix_NSFW_i2v_14b_high_lighting_v2.0.safetensors" \
    "${COMFYUI_PATH}/models/diffusion_models/Wan2.2_Remix_NSFW_i2v_14b_high_lighting_v2.0.safetensors"

echo ""
echo "--- Diffusion Model (Low Lighting) ---"
download_model \
    "https://huggingface.co/FX-FeiHou/wan2.2-Remix/resolve/main/NSFW/Wan2.2_Remix_NSFW_i2v_14b_low_lighting_v2.0.safetensors" \
    "${COMFYUI_PATH}/models/diffusion_models/Wan2.2_Remix_NSFW_i2v_14b_low_lighting_v2.0.safetensors"

echo ""
echo "--- VAE ---"
download_model \
    "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors" \
    "${COMFYUI_PATH}/models/vae/wan_2.1_vae.safetensors"

echo ""
echo "--- LoRA (High Lighting) ---"
download_model \
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/LoRAs/Wan22-Lightning/old/Wan2.2-Lightning_I2V-A14B-4steps-lora_HIGH_fp16.safetensors" \
    "${COMFYUI_PATH}/models/loras/Wan2.2-Lightning_I2V-A14B-4steps-lora_HIGH_fp16.safetensors"

echo ""
echo "--- LoRA (Low Lighting) ---"
download_model \
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/LoRAs/Wan22-Lightning/old/Wan2.2-Lightning_I2V-A14B-4steps-lora_LOW_fp16.safetensors" \
    "${COMFYUI_PATH}/models/loras/Wan2.2-Lightning_I2V-A14B-4steps-lora_LOW_fp16.safetensors"

echo ""
echo "========================================"
echo "✓ All models ready!"
echo "========================================"
