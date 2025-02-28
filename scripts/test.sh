#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2023-2025, NVIDIA CORPORATION & AFFILIATES.

if [ $# -eq 0 ]; then
    run_cuml=true
    run_dask=true
    run_dask_cuda=true
    run_dask_cudf=true
    run_distributed=true
    run_raft_dask=true
    run_ucxx=true
else
    run_cuml=false
    run_dask=false
    run_dask_cuda=false
    run_dask_cudf=false
    run_distributed=false
    run_raft_dask=false
    run_ucxx=false
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
        --ucxx-only)
            run_ucxx=true
            ;;
        --help)
            echo "Usage: $0 [--dask-only] [--distributed-only] [--dask-cuda-only] [--dask-cudf-only] [--ucx-only]"
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

    # -k not ... skips are for https://github.com/rapidsai/dask-upstream-testing/issues/27
    pytest -v --timeout=120 packages/dask-cuda/dask_cuda/tests -k "not (test_compatibility_mode_dataframe_shuffle or test_worker_force_spill_to_disk or test_cupy_cluster_device_spill or test_cudf_spill_cluster)"

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
    # -k not ... skips are for https://github.com/rapidsai/dask-upstream-testing/issues/27
    pytest -v --timeout=120 -m gpu --runslow packages/distributed/distributed -k "not (test_stress or test_transpose or test_rmm_metrics or test_malloc_trim_threshold)"

    if [[ $? -ne 0 ]]; then
        exit_code=1
    fi

fi


if $run_ucxx; then

    echo "[testing ucxx]"
    # this imports distributed.comms.tests, so has to come after we install distributed above.
    # And we need to do an editable install here for distributed-ucxx's tests to be importable
    uv pip install --no-deps -e "distributed-ucxx-cu12 @ ./packages/ucxx/python/distributed-ucxx"
    # -k not ... skips are for https://github.com/rapidsai/dask-upstream-testing/issues/27
    pytest -v --timeout=120 packages/ucxx/python/distributed-ucxx/distributed_ucxx "-k not (test_transpose)"

    if [[ $? -ne 0 ]]; then
        exit_code=1
    fi

fi


exit $exit_code
