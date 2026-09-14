#!/bin/bash

# SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
# SPDX-License-Identifier: BSD-3-Clause-Open-MPI

#
# This script will copy a .deb package
# for multiple versions of Ubuntu, for testing purposes.
#
# This script assumes that the deb's were preprepared a priori.
# A separate script should be used to create them.
#
# Run like this: ./deb_all.sh <name> <version> <minor> <cmd>
# E.g.: ./deb_all.sh ocudu 26.04.1 1 `gnb --version`
#
set -e

source $(dirname "$0")/get_ubuntu_versions.sh

main() {

  # Check number of args
  if (($# != 4)); then
    echo >&2 "Illegal number of parameters"
    echo >&2 "Run like this: \"./deb_all.sh <name> <version> <minor> <cmd>\""
    exit 1
  fi

  local name=$1
  local release=$2
  local minor=$3
  local cmd=$4

  eval "$(get_ubuntu_version_array)"

  local ubuntu_num
  for ubuntu_num in $sorted_ubuntu_versions; do
    echo "========================================================================"
    echo "Installing local deb $name $release (minor $minor) Ubuntu $ubuntu_num"
    echo "========================================================================"
    $(dirname "$0")/../install_docker/run-deb-docker.sh "$ubuntu_num" "$name" "$release" "$minor" "$cmd"
  done
}

main "$@"
