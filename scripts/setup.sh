#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2025, NVIDIA CORPORATION & AFFILIATES.

# Install
set -euo pipefail

if ! command -v uv > /dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi
