#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2023-2025, NVIDIA CORPORATION & AFFILIATES.

if [ $# -eq 0 ]; then
    run_cudf_polars=true
    run_cuml=true
    run_dask=true
    run_dask_cuda=true
    run_dask_cudf=true
    run_dask_image=true
    run_distributed=true
    run_raft_dask=true
    run_ucxx=true
else
    run_cudf_polars=false
    run_cuml=false
    run_dask=false
    run_dask_cuda=false
    run_dask_cudf=false
    run_dask_image=false
    run_distributed=false
    run_raft_dask=false
    run_ucxx=false
fi

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --cudf-polars-only)
            run_cudf_polars=true
            ;;
        --cuml-only)
            run_cuml=true
            ;;
        --dask-only)
            run_dask=true
            ;;
        --dask-cuda-only)
            run_dask_cuda=true
            ;;
        --dask-cudf-only)
            run_dask_cudf=true
            ;;
        --dask-image-only)
            run_dask_image=true
            ;;
        --distributed-only)
            run_distributed=true
            ;;
        --raft-dask-only)
            run_raft_dask=true
            ;;
        --ucxx-only)
            run_ucxx=true
            ;;
        --help)
            echo "Usage: $0 [--dask-only] [--distributed-only] [--dask-cuda-only] [--dask-cudf-only] [--dask-image-only] [--ucx-only]"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

exit_code=0;

# --- cudf-polars ---
if $run_cudf_polars; then
    echo "[testing cudf-polars]"
    pytest -v --timeout 120 packages/cudf/python/cudf_polars/tests/experimental/ --executor streaming --scheduler distributed

    if [[ $? -ne 0 ]]; then
        exit_code=1
    fi
fi


# --- cuml ---
if $run_cuml; then

    echo "[testing cuml]"
    pytest -v --timeout=120 --quick_run packages/cuml/python/cuml/cuml/tests/dask

    if [[ $? -ne 0 ]]; then
        exit_code=1
    fi

fi

# --- dask-cudf ---
if $run_dask_cudf; then

    echo "[testing dask-cudf]"
    pytest -v --timeout=120 packages/cudf/python/dask_cudf

    if [[ $? -ne 0 ]]; then
        exit_code=1
    fi

fi

# --- dask-cuda ---

if $run_dask_cuda; then
    echo "[testing dask-cuda]"

    pytest -v --timeout=120 packages/dask-cuda/dask_cuda/tests

    if [[ $? -ne 0 ]]; then
        exit_code=1
    fi

fi

# --- dask-image ---
if $run_dask_image; then

    echo "[testing dask-image]"
    pytest -v packages/dask-image/ -m cupy

    if [[ $? -ne 0 ]]; then
        exit_code=1
    fi

fi


# --- raft-dask ---
if $run_raft_dask; then

    echo "[testing raft-dask]"
    pytest -v --timeout=120 packages/raft/python/raft-dask/raft_dask/tests

    if [[ $? -ne 0 ]]; then
        exit_code=1
    fi

fi


# --- dask ---

if $run_dask; then

    echo "[testing dask]"
    # https://github.com/rapidsai/dask-upstream-testing/issues/23
    # cuML fails to import tests when Dask / distributed is installed in editable mode.
    uv pip install --no-deps -e ./packages/dask
    pytest -v --timeout=120 -m gpu packages/dask/dask

    if [[ $? -ne 0 ]]; then
        exit_code=1
    fi

fi


# --- distributed ---

if $run_distributed; then

    echo "[testing distributed]"
    # https://github.com/rapidsai/dask-upstream-testing/issues/23
    # cuML fails to import tests when Dask / distributed is installed in editable mode.
    uv pip install --no-deps -e ./packages/distributed
    pytest -v --timeout=120 -m gpu --runslow packages/distributed/distributed --deselect "distributed/comm/tests/test_ucx.py::test_registered" --deselect "distributed/comm/tests/test_ucx.py::test_ucx_specific"

    if [[ $? -ne 0 ]]; then
        exit_code=1
    fi

fi


if $run_ucxx; then

    echo "[testing ucxx]"
    # this imports distributed.comms.tests, so has to come after we install distributed above.
    # And we need to do an editable install here for distributed-ucxx's tests to be importable

    RAPIDS_PY_CUDA_SUFFIX=$(echo "cu${RAPIDS_CUDA_VERSION:-12.15.1}" | cut -d '.' -f 1)

    uv pip install --no-deps -e "distributed-ucxx-${RAPIDS_PY_CUDA_SUFFIX} @ ./packages/ucxx/python/distributed-ucxx"
    pytest -v --timeout=120 packages/ucxx/python/distributed-ucxx/distributed_ucxx

    if [[ $? -ne 0 ]]; then
        exit_code=1
    fi

fi


exit $exit_code
