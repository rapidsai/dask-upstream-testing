#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2023-2025, NVIDIA CORPORATION & AFFILIATES.

if [ $# -eq 0 ]; then
    run_cuml=true
    run_dask=true
    run_dask_cuda=true
    run_dask_cudf=true
    run_distributed=true
    run_raft_dask=true
else
    run_cuml=false
    run_dask=false
    run_dask_cuda=false
    run_dask_cudf=false
    run_distributed=false
    run_raft_dask=false
fi

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
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
        --distributed-only)
            run_distributed=true
            ;;
        --raft-dask-only)
            run_raft_dask=true
            ;;
        --help)
            echo "Usage: $0 [--dask-only] [--distributed-only] [--dask-cuda-only] [--dask-cudf-only]"
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

# --- cuml ---
if $run_cuml; then

    echo "[testing cuml]"
    pytest -v --timeout=120 --quick_run --import-mode importlib packages/cuml/python/cuml/cuml/tests/dask

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

# --- dask ---

if $run_dask; then

    echo "[testing dask]"
    pytest -v --timeout=120 -m gpu packages/dask/dask

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



# --- distributed ---

if $run_distributed; then

    echo "[testing distributed]"
    pytest -v --timeout=120 -m gpu --runslow packages/distributed/distributed

    if [[ $? -ne 0 ]]; then
        exit_code=1
    fi

fi

exit $exit_code
