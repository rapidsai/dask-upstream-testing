#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2023-2025, NVIDIA CORPORATION & AFFILIATES.

echo "[testing dask-cudf]"
pushd cudf/python/dask_cudf || exit 1
pytest dask_cudf -v
dask_cudf_status=$?
popd || exit 1

echo "[testing dask]"
pushd dask || exit 1
pytest dask -v -m gpu
dask_status=$?
popd || exit 1

echo "[testing distributed]"
pushd distributed || exit 1
pytest distributed -v -m gpu --runslow
distributed_status=$?
popd || exit 1

if [ $dask_cudf_status -ne 0 ] || [ $dask_status -ne 0 ] || [ $distributed_status -ne 0 ]; then
    echo "Tests faild"
    exit 1
fi
