#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2025, NVIDIA CORPORATION & AFFILIATES.

# Install
set -euo pipefail

# RAPIDS_PY_CUDA_SUFFIX="$(rapids-wheel-ctk-name-gen ${RAPIDS_CUDA_VERSION})"
RAPIDS_PY_CUDA_SUFFIX=12
# TODO: set this to main once dask-cudf is compatible
# DASK_VERSION=main
DASK_VERSION=2024.12.1
export PIP_YES=true
export PIP_PRE=true

# Should this use nightly wheels or rapids-download-wheels-from-s3?

pip install --extra-index-url=https://pypi.anaconda.org/rapidsai-wheels-nightly/simple \
  "cudf-cu12" \
  "dask-cudf-cu12"

echo "Installing dask@{DASK_VERSION}"

if [ ! -d "dask" ]; then
    git clone https://github.com/dask/dask
fi

if [ ! -d "distributed" ]; then
    git clone https://github.com/dask/distributed
fi

pip uninstall dask distributed
cd dask && git clean -fdx && git checkout $DASK_VERSION && pip install -e .[test] && cd ..
cd distributed && git clean -fdx && git checkout $DASK_VERSION && pip install -e . && cd ..

./scripts/test