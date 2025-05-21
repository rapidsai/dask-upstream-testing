#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2025, NVIDIA CORPORATION & AFFILIATES.

set -euo pipefail

./scripts/setup.sh

if ! command -v uv > /dev/null; then
    source $HOME/.local/bin/env
fi

# Temporarily pin to uv 7.5's python-build-standalone.
# Follow https://github.com/astral-sh/python-build-standalone/issues/619
# and https://github.com/rapidsai/dask-upstream-testing/issues/56 for details.
uvx uv@0.7.5 python install --reinstall 3.12
uv venv --allow-existing --python 3.12 --managed-python --no-cache

source .venv/bin/activate

./scripts/install.sh
./scripts/test.sh
