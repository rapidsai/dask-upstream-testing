# Dask Upstream Testing

[![Test dask-upstream](https://github.com/rapidsai/dask-upstream-testing/actions/workflows/cron.yaml/badge.svg)](https://github.com/rapidsai/dask-upstream-testing/actions/workflows/cron.yaml)

This repository contains the scripts to run Dask's `gpu`-marked tests on a schedule
and dask-dependent tests from some downstream libraries.

## Version Policy

The primary goal here is to quickly identify breakages in tests defined in `dask/dask` and `dask/distributed`, so we'll use the latest `main` from each of those.

When breakages occur, they'll generally be fixed either in Dask or in the the nightly versions of the downstream packages (rapids, cupy, numba, etc.). And so we install the nightly (rather than `latest`) version of the downstream packages.

## Workflow Dispatch

This repository uses [workflow dispatch](https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions#onworkflow_dispatch) to enable running tests against
a specific version of Dask.

Navigate to the [cron workflow](https://github.com/rapidsai/dask-upstream-testing/actions/workflows/cron.yaml), select "Run workflow", and input a Dask version to test. This must be a branch name (like `main`) or a tag that is available in both Dask and Distributed repositorys (like `2025.4.1`). The default is `main`.

## Version Upgrades

We'd like to have a complete test run against a specific releaesd version of Dask prior to bumping the pin in [rapids-dask-dependency](https://github.com/rapidsai/rapids-dask-dependency). To test that

1. Update `DASK_BRACH` in `install.sh` to select the tag for a specific version
2. Update `overrides.txt` to pin to a specific version, rather than `main`

## RAPIDS version update

After code freeze for a specific RAPIDS version (e.g. 25.06) when it's anticipated that no Dask version update is imminent,
update the targeted RAPIDS version by changing

- `RAPIDS_BRANCH` in `install.sh`
- `RAPID_VERSION_RANGE` in `install.sh`
- The branch in the `jobs.dask-tests.uses` field of `cron.yaml`
