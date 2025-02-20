#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2025, NVIDIA CORPORATION & AFFILIATES.
set -euo pipefail

# RAPIDS_CUDA_VERSION is like 12.15.1
# We want cu12
RAPIDS_PY_CUDA_SUFFIX=$(echo "cu${RAPIDS_CUDA_VERSION:-12.15.1}" | cut -d '.' -f 1)

DASK_VERSION=main

# Try
uv pip install --extra-index-url=https://pypi.anaconda.org/rapidsai-wheels-nightly/simple \
  --overrides=requirements/overrides.txt \
  --prerelease allow \
  "cudf-${RAPIDS_PY_CUDA_SUFFIX}" \
  "dask-cudf-${RAPIDS_PY_CUDA_SUFFIX}" \
  "ucx-py-${RAPIDS_PY_CUDA_SUFFIX}" \
  "ucxx-${RAPIDS_PY_CUDA_SUFFIX}" \
  "scipy" \
  "dask-cuda"

# Clone cudf repo for tests
CUDF_VERSION="branch-25.04"
cudf_commit=$(./scripts/check-version.py cudf)

if [ ! -d "cudf" ]; then
    echo "Cloning cudf@{$CUDF_VERSION}"
    git clone https://github.com/rapidsai/cudf.git --branch $CUDF_VERSION
fi

pushd cudf
git checkout $cudf_commit
popd

if [ ! -d "dask-cuda" ]; then
    echo "Cloning cudf@{$CUDF_VERSION}"
    git clone https://github.com/rapidsaicudf_commit/dask-cuda.git --branch $CUDF_VERSION
fi

# Clone dask-cuda for tests
# dask-cuda nightly wheels currently lack a __git_commit__.
# Looking into it, but for now just use the branch.

# dask_cuda_commit=$(./scripts/check-version.py dask_cuda)

pushd dask-cuda
git checkout $CUDF_VERSION
popd

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

pushd dask
git checkout $DASK_VERSION
popd

pushd distributed
git checkout $DASK_VERSION
popd

echo "[Setup done]"
uv pip list
