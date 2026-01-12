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
# Run like this: ./dpkg_all.sh <name> <version> <minor>
# E.g.: ./dpkg_all.sh ocudu 26.04.1 1
#
set -e

source $(dirname "$0")/get_ubuntu_versions.sh

main() {

  # Check number of args
  if (($# != 3)); then
    echo >&2 "Illegal number of parameters"
    echo >&2 "Run like this: \"./dpkg_all.sh <name> <version> <minor>\""
    exit 1
  fi

  local name=$1
  local release=$2
  local minor=$3

  eval "$(get_ubuntu_version_array)"

  local ubuntu_num
  for ubuntu_num in $sorted_ubuntu_versions; do
    echo "================================================================"
    echo "Building deb $name $release (minor $minor) Ubuntu $ubuntu_num"
    echo "================================================================"
    $(dirname "$0")/../packaging_docker/run-pkg-docker.sh $ubuntu_num "dpkg.sh $name $release $minor"
  done
}

main "$@"
