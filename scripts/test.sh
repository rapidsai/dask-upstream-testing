#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2023-2025, NVIDIA CORPORATION & AFFILIATES.

echo "[testing dask]"
pushd dask
pytest dask -v -m gpu
dask_status=$?
popd

echo "[testing distributed]"
pushd distributed
pytest distributed -v -m gpu --runslow
distributed_status=$?
popd

echo "[testing downstream]"

pushd downstream
pytest -v .
downstream_status=$?
popd

if [ $dask_status -ne 0 ] || [ $distributed_status -ne 0 ] || [ $downstream_status -ne 0 ] ; then
    echo "Tests faild"
    exit 1
fi
