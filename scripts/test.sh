#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2023-2025, NVIDIA CORPORATION & AFFILIATES.

echo "[testing dask]"
pushd dask || exit
pytest dask -v -m gpu
dask_status=$?
popd || exit

echo "[testing distributed]"
pushd distributed || exit
pytest distributed -v -m gpu --runslow
distributed_status=$?
popd || exit

if [ $dask_status -ne 0 ] || [ $distributed_status -ne 0 ]; then
    echo "Tests faild"
    exit 1
fi
