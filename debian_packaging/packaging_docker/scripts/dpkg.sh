#!/bin/bash
#
# Copyright 2021-2026 Software Radio Systems Limited
#
# By using this file, you agree to the terms and conditions set
# forth in the LICENSE file which can be found at the top level of
# the distribution.
#

#
# This script will run dpkg-buildpackage on particular release
# for multiple versions of Ubuntu, for testing purposes.
#
# This script assumes that the sources were preprepared a priori.
# A separate script should be used to create it.
#
# Run like this: ./dpkg.sh <name> <version> <minor>
# E.g.: ./dpkg.sh ocudu 26.04.1 1
#
set -e

. /etc/os-release

main() {

  # Check number of args
  if (($# != 3)); then
    echo >&2 "Illegal number of parameters"
    echo >&2 "Run like this: \"./dpkg.sh <name> <version> <minor>\""
    exit 1
  fi

  local name=$1
  local release=$2
  local minor_version=$3

  local ubuntu_num=$VERSION_ID
  local ubuntu_name=$VERSION_CODENAME

  local build_dir=~/build-area/${name}_$release/minor_v$minor_version/$ubuntu_name
  local src_dir=$build_dir/$name
  local deps_dir=$build_dir/deps

  echo "== Installing build dependencies =="

  rm -Rf "$deps_dir" && mkdir -p "$deps_dir"
  pushd "$deps_dir" >/dev/null || exit 1
  sudo apt update
  sudo mk-build-deps --install --tool='apt-get --no-install-recommends --yes' "$src_dir"/debian/control || true
  sudo chown -R "$(whoami)":"$(whoami)" .* || true
  popd >/dev/null || exit 1

  echo "== Building deb =="
  echo "Testing packaging of ${name} release $release, minor version: $minor_version"
  echo 'Build location: ' "$build_dir"

  pushd "$src_dir" >/dev/null || exit 1
  dpkg-buildpackage -us -uc
  cp ../${name}_${release}-0ubuntu1ppa${minor_version}~${ubuntu_num}_amd64.deb ~/build-area/${name}_$release/minor_v$minor_version/
  popd >/dev/null || exit 1

}

main "$@"
