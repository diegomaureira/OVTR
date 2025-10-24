#!/usr/bin/env bash
set -euo pipefail

# =============================
# Configuration
# =============================
DATA_DIR="${DATA_DIR:-/media/disk/dm_test}"
OVTR_DIR="${OVTR_DIR:-/media/disk/OVTR}"
IMAGE_NAME="${IMAGE_NAME:-ovtr-cu111}"
CONTAINER_NAME="${CONTAINER_NAME:-ovtr}"
PIP_CACHE_DIR="${PIP_CACHE_DIR:-$HOME/.cache/pip}"

# =============================
# Pre-flight checks
# =============================
if [ ! -d "$DATA_DIR" ]; then
    echo "❌ ERROR: Data directory not found: $DATA_DIR"
    exit 1
fi

if [ ! -d "$OVTR_DIR" ]; then
    echo "❌ ERROR: OVTR directory not found: $OVTR_DIR"
    exit 1
fi

mkdir -p "$PIP_CACHE_DIR"

# =============================
# Startup info
# =============================
echo "🚀 Starting OVTR container..."
echo "   🧩 Image:       $IMAGE_NAME"
echo "   📦 Container:   $CONTAINER_NAME"
echo "   💻 Mount code:  $OVTR_DIR → /workspace/OVTR"
echo "   📂 Mount data:  $DATA_DIR → /workspace/OVTR/data"
echo "   🧰 Pip cache:   $PIP_CACHE_DIR → /root/.cache/pip"
echo ""

# =============================
# Container entry command
# =============================
SETUP_CMD=$(cat <<'EOF'
set -e
echo "🔍 Installing OVTR dependencies..."
pip install -U openmim
mim install mmcv_full==1.3.17
pip install --no-cache-dir -r requirements.txt
cd ovtr/models/ops
python setup.py clean
python setup.py build_ext --inplace
python -m pip install .
export LD_LIBRARY_PATH=$(python3 -c "import torch; import os; print(os.path.join(torch.__path__[0], 'lib'))"):$LD_LIBRARY_PATH
cd /workspace/OVTR
echo ""
echo "✅ OVTR environment ready!"
exec bash
EOF
)

# =============================
# Run container
# =============================
docker run --gpus all \
    --name "$CONTAINER_NAME" \
    --rm \
    --shm-size=8g \
    -it \
    -v "${OVTR_DIR}:/workspace/OVTR" \
    -v "${DATA_DIR}:/workspace/OVTR/data" \
    -v "${PIP_CACHE_DIR}:/root/.cache/pip" \
    --network host \
    -e PYTHONPATH=/workspace/OVTR:${PYTHONPATH:-} \
    -w /workspace/OVTR \
    "$IMAGE_NAME" \
    bash -c "$SETUP_CMD"
