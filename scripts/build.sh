#!/usr/bin/env bash

set -euo pipefail

root_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
upstream_version=$(tr -d '[:space:]' < "${root_dir}/UPSTREAM_VERSION")
patch_version=$(tr -d '[:space:]' < "${root_dir}/PATCH_VERSION")
image=${IMAGE:-dafal/linkding}
source_dir="${root_dir}/.build/linkding"

rm -rf "${source_dir}"
mkdir -p "${source_dir}"
git clone --depth 1 --branch "${upstream_version}" \
  https://github.com/sissbruecker/linkding.git "${source_dir}"
git -C "${source_dir}" apply --check "${root_dir}/patches/usage-tracking.patch"
git -C "${source_dir}" apply "${root_dir}/patches/usage-tracking.patch"

docker buildx build \
  --target linkding \
  --load \
  -f "${source_dir}/docker/default.Dockerfile" \
  -t "${image}:${upstream_version}-usage.${patch_version}" \
  "${source_dir}"
