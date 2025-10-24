# --- Base image: CUDA 11.1 + cuDNN8 + Ubuntu 20.04 ---
FROM nvidia/cuda:11.1.1-cudnn8-devel-ubuntu20.04

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# --- Install system dependencies and Python 3.9 ---
RUN apt update && apt install -y --no-install-recommends \
    wget \
    build-essential \
    ninja-build \
    git \
    curl \
    ca-certificates \
    python3.9 \
    python3.9-venv \
    python3.9-distutils \
    python3.9-dev \
    python3-pip \
    python3-tk \
    build-essential \
    libavdevice-dev \
    libavfilter-dev \
    libavformat-dev \
    libavcodec-dev \
    libswscale-dev \
    pkg-config \
    ffmpeg \
    libavcodec-extra \
    libgl1 && \
    rm -rf /var/lib/apt/lists/*

# Set Python 3.9 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.9 1 && \
    python -m pip install --upgrade pip setuptools wheel

# --- Create and set working directory ---
WORKDIR /workspace/OVTR

# --- Install PyTorch 1.10.1 + cu111 and other dependencies ---
RUN pip install --no-cache-dir torch==1.10.1+cu111 torchvision==0.11.2+cu111 torchaudio==0.10.1 \
    -f https://download.pytorch.org/whl/cu111/torch_stable.html && \
    pip install ftfy regex tqdm && \
    pip install git+https://github.com/openai/CLIP.git