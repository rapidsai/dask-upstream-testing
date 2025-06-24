#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2025, NVIDIA CORPORATION & AFFILIATES.
set -euo pipefail

DASK_BRANCH=${DASK_BRANCH:-main}

# RAPIDS_CUDA_VERSION is like 12.15.1
# We want cu12
RAPIDS_PY_CUDA_SUFFIX=$(echo "cu${RAPIDS_CUDA_VERSION:-12.15.1}" | cut -d '.' -f 1)

# Controls which branch of rapids libraries give us the tests.
export RAPIDS_BRANCH="branch-25.08"
export RAPIDS_VERSION_RANGE=">=25.8.0a0,<25.10.0a0"


# scipy pinned to <1.16.0 to avoid deprecation warnings -> errors.
# https://github.com/rapidsai/dask-upstream-testing/issues/63
uv pip install --extra-index-url=https://pypi.anaconda.org/rapidsai-wheels-nightly/simple \
  --overrides=requirements/overrides.txt \
  --prerelease allow \
  --upgrade \
  "dask-image[test] @ git+https://github.com/dask/dask-image.git@main" \
  "cuml-${RAPIDS_PY_CUDA_SUFFIX}[test]${RAPIDS_VERSION_RANGE}" \
  "cudf-${RAPIDS_PY_CUDA_SUFFIX}${RAPIDS_VERSION_RANGE}" \
  "cudf-polars-${RAPIDS_PY_CUDA_SUFFIX}${RAPIDS_VERSION_RANGE}" \
  "dask-cudf-${RAPIDS_PY_CUDA_SUFFIX}${RAPIDS_VERSION_RANGE}" \
  "raft-dask-${RAPIDS_PY_CUDA_SUFFIX}${RAPIDS_VERSION_RANGE}" \
  "ucx-py-${RAPIDS_PY_CUDA_SUFFIX}" \
  "ucxx-${RAPIDS_PY_CUDA_SUFFIX}" \
  "scipy<1.16.0" \
  "dask-cuda${RAPIDS_VERSION_RANGE}" \
  "rapidsmpf-${RAPIDS_PY_CUDA_SUFFIX}${RAPIDS_VERSION_RANGE}" \
  "pytest-timeout"

# packages holds all the downstream and upstream dependencies.
# we want to avoid directories with the same name as packages
# in the working directory
mkdir -p packages

cudf_commit=$(./scripts/check-version.py cudf)

if [ ! -d "packages/cudf" ]; then
    echo "Cloning cudf@{$RAPIDS_BRANCH}"
    git clone https://github.com/rapidsai/cudf.git --branch $RAPIDS_BRANCH packages/cudf
fi

pushd packages/cudf
git fetch
git checkout $cudf_commit
popd

cuml_commit=$(./scripts/check-version.py cuml)

if [ ! -d "packages/cuml" ]; then
    echo "Cloning cuml@{$RAPIDS_BRANCH}"
    git clone https://github.com/rapidsai/cuml.git --branch $RAPIDS_BRANCH packages/cuml
fi

pushd packages/cuml
git fetch
git checkout $cuml_commit
popd

raft_commit=$(./scripts/check-version.py raft_dask)

if [ ! -d "packages/raft" ]; then
    echo "Cloning raft@{$RAPIDS_BRANCH}"
    git clone https://github.com/rapidsai/raft.git --branch $RAPIDS_BRANCH packages/raft
fi

pushd packages/raft
git fetch
git checkout $raft_commit
popd

ucxx_commit=$(./scripts/check-version.py ucxx)

if [ ! -d "packages/ucxx" ]; then
    echo "Cloning ucxx@{$RAPIDS_BRANCH}"
    git clone https://github.com/rapidsai/ucxx.git packages/ucxx
fi

pushd packages/ucxx
git fetch
git checkout $ucxx_commit
popd

if [ ! -d "packages/dask-cuda" ]; then
    echo "Cloning cudf@{$RAPIDS_BRANCH}"
    git clone https://github.com/rapidsai/dask-cuda.git --branch $RAPIDS_BRANCH packages/dask-cuda
fi

# Clone dask-cuda for tests
# dask-cuda nightly wheels currently lack a __git_commit__.
# Looking into it, but for now just use the branch.

# dask_cuda_commit=$(./scripts/check-version.py dask_cuda)

pushd packages/dask-cuda
git fetch
git checkout $RAPIDS_BRANCH
popd


if [ ! -d "packages/dask-image" ]; then
    echo "Cloning dask-image"
    git clone https://github.com/dask/dask-image.git --depth 100 packages/dask-image
fi

pushd packages/dask-image
git fetch
git checkout main
uv pip install -e . --no-deps
popd

# depth needs to be sufficient to reach the last tag, so that the package
# versions are set correctly
if [ ! -d "packages/dask" ]; then
    echo "Cloning dask@${DASK_BRANCH}"
    git clone https://github.com/dask/dask --depth 100 packages/dask --branch "${DASK_BRANCH}"
fi

if [ ! -d "packages/distributed" ]; then
    echo "Cloning distributed@${DASK_BRANCH}"
    git clone https://github.com/dask/distributed --depth 100 packages/distributed --branch "${DASK_BRANCH}"
fi

pushd packages/dask
git fetch
git checkout "${DASK_BRANCH}"
git pull
popd

pushd packages/distributed
git fetch
git checkout "${DASK_BRANCH}"
git pull
popd

echo "[Setup done]"
uv pip list
