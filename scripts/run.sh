#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2025, NVIDIA CORPORATION & AFFILIATES.

# Install
set -euo pipefail


# RAPIDS_CUDA_VERSION is like 12.15.1
# We want cu12
RAPIDS_PY_CUDA_SUFFIX=$(echo "cu${RAPIDS_CUDA_VERSION:-12.15.1}" | cut -d '.' -f 1)

# TODO: set this to main once dask-cudf is compatible
# DASK_VERSION=main
DASK_VERSION=main
export PIP_YES=true
export PIP_PRE=true

pip install --extra-index-url=https://pypi.anaconda.org/rapidsai-wheels-nightly/simple \
  "cudf-${RAPIDS_PY_CUDA_SUFFIX}" \
  "dask-cudf-${RAPIDS_PY_CUDA_SUFFIX}" \
  "ucx-py-${RAPIDS_PY_CUDA_SUFFIX}" \
  "ucxx-${RAPIDS_PY_CUDA_SUFFIX}" \
  "scipy" \
  "dask-cuda"


# Clone cudf repo for tests
CUDF_VERSION="branch-25.04"

if [ ! -d "cudf" ]; then
    echo "Cloning cudf@{$CUDF_VERSION}"
    git clone https://github.com/rapidsai/cudf.git --branch $CUDF_VERSION
fi

# Clone dask-cuda for tests

if [ ! -d "dask-cuda" ]; then
    echo "Cloning cudf@{$CUDF_VERSION}"
    git clone https://github.com/rapidsai/dask-cuda.git --branch $CUDF_VERSION
fi


# depth needs to be sufficient to reach the last tag, so that the package
# versions are set correctly
if [ ! -d "dask" ]; then
    echo "Cloning dask@{$DASK_VERSION}"
    git clone https://github.com/dask/dask --depth 100 --branch $DASK_VERSION
fi

if [ ! -d "distributed" ]; then
    echo "Cloning dask@{$DASK_VERSION}"
    git clone https://github.com/dask/distributed --depth 100 --branch $DASK_VERSION
fi

# Install everything, including any new dependencies
pip uninstall dask distributed
pip install -e ./dask[test]
pip install -e ./distributed

echo "[Setup done]"
pip list

./scripts/test.sh
