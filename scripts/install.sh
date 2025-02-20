#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2025, NVIDIA CORPORATION & AFFILIATES.
set -euo pipefail

if ! command -v uv > /dev/null; then
    source $HOME/.local/bin/env
fi

# RAPIDS_CUDA_VERSION is like 12.15.1
# We want cu12
RAPIDS_PY_CUDA_SUFFIX=$(echo "cu${RAPIDS_CUDA_VERSION:-12.15.1}" | cut -d '.' -f 1)

uv pip install --extra-index-url=https://pypi.anaconda.org/rapidsai-wheels-nightly/simple \
  --overrides=requirements/overrides.txt \
  --prerelease allow \
  "cuml-${RAPIDS_PY_CUDA_SUFFIX}[test]" \
  "cudf-${RAPIDS_PY_CUDA_SUFFIX}" \
  "dask-cudf-${RAPIDS_PY_CUDA_SUFFIX}" \
  "raft-dask-${RAPIDS_PY_CUDA_SUFFIX}" \
  "ucx-py-${RAPIDS_PY_CUDA_SUFFIX}" \
  "ucxx-${RAPIDS_PY_CUDA_SUFFIX}" \
  "scipy" \
  "dask-cuda"

# packages holds all the downstream and upstream dependencies.
# we want to avoid directories with the same name as packages
# in the working directory
mkdir -p packages

# Clone cudf repo for tests
CUDF_VERSION="branch-25.04"

cudf_commit=$(./scripts/check-version.py cudf)

if [ ! -d "cudf" ]; then
    echo "Cloning cudf@{$CUDF_VERSION}"
    git clone https://github.com/rapidsai/cudf.git --branch $CUDF_VERSION packages
fi

pushd packages/cudf
git checkout $cudf_commit
popd

cuml_commit=$(./scripts/check-version.py cuml)

if [ ! -d "cuml" ]; then
    echo "Cloning cuml@{$CUDF_VERSION}"
    git clone https://github.com/rapidsai/cuml.git --branch $CUDF_VERSION packages
fi

pushd packages/cuml
git checkout $cuml_commit
popd

raft_commit=$(./scripts/check-version.py raft_dask)

if [ ! -d "raft" ]; then
    echo "Cloning raft@{$CUDF_VERSION}"
    git clone https://github.com/rapidsai/raft.git --branch $CUDF_VERSION packages
fi

pushd packages/raft
git checkout $raft_commit
popd

if [ ! -d "dask-cuda" ]; then
    echo "Cloning cudf@{$CUDF_VERSION}"
    git clone https://github.com/rapidsaicudf_commit/dask-cuda.git --branch $CUDF_VERSION packages
fi

# Clone dask-cuda for tests
# dask-cuda nightly wheels currently lack a __git_commit__.
# Looking into it, but for now just use the branch.

# dask_cuda_commit=$(./scripts/check-version.py dask_cuda)

pushd packages/dask-cuda
git checkout $CUDF_VERSION
popd

# depth needs to be sufficient to reach the last tag, so that the package
# versions are set correctly
if [ ! -d "dask" ]; then
    echo "Cloning dask@main"
    git clone https://github.com/dask/dask --depth 100 packages
fi

if [ ! -d "distributed" ]; then
    echo "Cloning distributed@main"
    git clone https://github.com/dask/distributed --depth 100 packages
fi

pushd packages/dask
git checkout main
popd

pushd packages/distributed
git checkout main
popd

# Finally, ensure that
uv pip install --no-deps -e ./packages/dask ./packages/distributed

echo "[Setup done]"
uv pip list
