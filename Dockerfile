# RunPod ComfyUI Template - Wan2.2 Remix NSFW I2V Workflow
# Base image with CUDA support
FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV COMFYUI_PATH=/workspace/ComfyUI
ENV PATH="/root/.local/bin:${PATH}"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3.10-venv \
    python3-pip \
    git \
    wget \
    curl \
    aria2 \
    ffmpeg \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    && rm -rf /var/lib/apt/lists/*

# Create workspace directory
WORKDIR /workspace

# Clone ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git ${COMFYUI_PATH}

# Install Python dependencies
WORKDIR ${COMFYUI_PATH}
RUN pip3 install --upgrade pip && \
    pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 && \
    pip3 install -r requirements.txt && \
    pip3 install xformers accelerate huggingface_hub

# Install ComfyUI Manager
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git ${COMFYUI_PATH}/custom_nodes/ComfyUI-Manager

# Install required custom nodes for the workflow
RUN git clone https://github.com/kijai/ComfyUI-WanVideoWrapper.git ${COMFYUI_PATH}/custom_nodes/ComfyUI-WanVideoWrapper && \
    cd ${COMFYUI_PATH}/custom_nodes/ComfyUI-WanVideoWrapper && \
    pip3 install -r requirements.txt || true

RUN git clone https://github.com/kijai/ComfyUI-KJNodes.git ${COMFYUI_PATH}/custom_nodes/ComfyUI-KJNodes && \
    cd ${COMFYUI_PATH}/custom_nodes/ComfyUI-KJNodes && \
    pip3 install -r requirements.txt || true

# Create model directories
RUN mkdir -p ${COMFYUI_PATH}/models/text_encoders && \
    mkdir -p ${COMFYUI_PATH}/models/diffusion_models && \
    mkdir -p ${COMFYUI_PATH}/models/vae && \
    mkdir -p ${COMFYUI_PATH}/models/loras && \
    mkdir -p ${COMFYUI_PATH}/user/default/workflows

# Copy workflow file
COPY Wan22-I2V-Remix.json ${COMFYUI_PATH}/user/default/workflows/

# Copy download script
COPY download_models.sh /download_models.sh
RUN chmod +x /download_models.sh

# Create startup script
RUN echo '#!/bin/bash\n\
echo "Starting ComfyUI Wan2.2 Remix Template..."\n\
\n\
# Download models if not present\n\
/download_models.sh\n\
\n\
# Start ComfyUI\n\
cd /workspace/ComfyUI\n\
python3 main.py --listen 0.0.0.0 --port 8188 --enable-cors-header\n\
' > /start.sh && chmod +x /start.sh

# Expose port
EXPOSE 8188

# Set working directory
WORKDIR ${COMFYUI_PATH}

# Start ComfyUI (will download models on first run)
CMD ["/start.sh"]
