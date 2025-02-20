#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2025, NVIDIA CORPORATION & AFFILIATES.

set -euo pipefail

./scripts/setup.sh

if ! command -v uv > /dev/null; then
    source $HOME/.local/bin/env
fi

uv venv --allow-existing
source .venv/bin/activate

./scripts/install.sh
./scripts/test.sh
