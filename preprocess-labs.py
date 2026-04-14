#!/usr/bin/env python3
"""Backward-compatible CLI entrypoint."""

from src.preprocesslabs.cli import main


if __name__ == "__main__":
    raise SystemExit(main())
