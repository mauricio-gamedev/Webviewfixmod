#!/usr/bin/env bash
set -euo pipefail

CHECK_PATH="${1:-$PWD}"
MIN_RAM_KB=$((8 * 1024 * 1024))
RECOMMENDED_RAM_KB=$((16 * 1024 * 1024))
MIN_DISK_KB=$((100 * 1024 * 1024))

ARCH="$(uname -m)"
if [[ "$ARCH" != "x86_64" ]]; then
  echo "ERROR: Chromium Android build requires an x86-64 Linux host; found $ARCH." >&2
  exit 2
fi

if [[ ! -r /proc/meminfo ]]; then
  echo "ERROR: cannot read /proc/meminfo to verify RAM." >&2
  exit 2
fi
RAM_KB="$(awk '/^MemTotal:/ {print $2; exit}' /proc/meminfo)"
if [[ -z "$RAM_KB" || "$RAM_KB" -lt "$MIN_RAM_KB" ]]; then
  echo "ERROR: at least 8 GiB RAM is required; detected $((RAM_KB / 1024)) MiB." >&2
  exit 2
fi
if [[ "$RAM_KB" -lt "$RECOMMENDED_RAM_KB" ]]; then
  echo "WARNING: Chromium recommends more than 16 GiB RAM; this host has $((RAM_KB / 1024)) MiB." >&2
fi

mkdir -p "$CHECK_PATH"
FREE_KB="$(df -Pk "$CHECK_PATH" | awk 'NR == 2 {print $4}')"
if [[ -z "$FREE_KB" || "$FREE_KB" -lt "$MIN_DISK_KB" ]]; then
  FREE_GIB=0
  if [[ -n "$FREE_KB" ]]; then FREE_GIB=$((FREE_KB / 1024 / 1024)); fi
  echo "ERROR: at least 100 GiB free disk space is required; detected about ${FREE_GIB} GiB at $CHECK_PATH." >&2
  exit 2
fi

echo "Build host preflight passed: x86_64, $((RAM_KB / 1024)) MiB RAM, $((FREE_KB / 1024 / 1024)) GiB free."
