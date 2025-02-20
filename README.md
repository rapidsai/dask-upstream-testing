# Dask Upstream Testing

[![Test dask-upstream](https://github.com/rapidsai/dask-upstream-testing/actions/workflows/cron.yaml/badge.svg)](https://github.com/rapidsai/dask-upstream-testing/actions/workflows/cron.yaml)

This repository contains the scripts to run Dask's `gpu`-marked tests on a schedule
and dask-dependent tests from some downstream libraries.

## Version Policy

The primary goal here is to quickly identify breakages in tests defined in `dask/dask` and `dask/distributed`, so we'll use the latest `main` from each of those.

When breakages occur, they'll generally be fixed either in Dask or in the the nightly versions of the downstream packages (rapids, cupy, numba, etc.). And so we install the nightly (rather than `latest`) version of the downstream packages.
