#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2023-2025, NVIDIA CORPORATION & AFFILIATES.

if [ $# -eq 0 ]; then
    run_dask=true
    run_dask_cuda=true
    run_dask_cudf=true
    run_distributed=true
else
    run_dask=false
    run_dask_cuda=false
    run_dask_cudf=false
    run_distributed=false
fi

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
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

# --- dask-cudf ---
if $run_dask_cudf; then

    echo "[testing dask-cudf]"
    pushd cudf/python/dask_cudf || exit 1
    pytest -v dask_cudf

    if [[ $? -ne 0 ]]; then
        exit_code=1
    fi

    popd || exit 1

fi

# --- dask-cuda ---

if $run_dask_cuda; then
    echo "[testing dask-cuda]"
    pushd dask-cuda/dask_cuda/tests || exit 1
    pytest -v .

    if [[ $? -ne 0 ]]; then
        exit_code=1
    fi

    popd || exit 1
fi

# --- dask ---

if $run_dask; then

    echo "[testing dask]"
    pushd dask/dask || exit 1
    pytest -v -m gpu .

    if [[ $? -ne 0 ]]; then
        exit_code=1
    fi

    popd || exit 1

fi

# --- distributed ---

if $run_distributed; then

    echo "[testing distributed]"
    pushd distributed || exit 1
    pytest -v -m gpu --runslow distributed

    if [[ $? -ne 0 ]]; then
        exit_code=1
    fi

    popd || exit 1

fi

exit $exit_code
