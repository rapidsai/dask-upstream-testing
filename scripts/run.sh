#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2025, NVIDIA CORPORATION & AFFILIATES.

set -euo pipefail

./scripts/setup.sh
./scripts/install.sh
./scripts/test.sh
