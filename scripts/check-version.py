#!/usr/bin/env python
# SPDX-FileCopyrightText: Copyright (c) 2023-2025, NVIDIA CORPORATION & AFFILIATES.
"""
Print the git commit a rapids package was built from.
"""

import argparse
import importlib
import sys
import importlib.resources


def parse_args(args=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("distribution", help="Package name to check.")

    return parser.parse_args(args)


def main(args=None):
    args = parse_args(args)
    dist = args.distribution

    try:
        sha = importlib.resources.files(dist).joinpath("GIT_COMMIT").read_text().strip()
    except ModuleNotFoundError:
        print(f"Error: {dist} is not installed.", file=sys.stderr)
    except FileNotFoundError:
        print(f"Error: {dist} does not contain 'GIT_COMMIT' file.", file=sys.stderr)
    else:
        print(sha)
        sys.exit(0)
    sys.exit(1)


if __name__ == "__main__":
    main()
