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
# Run like this: ./run-deb-docker.sh <ubuntu-num-version> <name> <version> <minor> <cmd>
# E.g.: ./run-deb-docker.sh 25.04 ocudu 26.04.1 1 'gnb --version'
#
set -e

main() {

  # Check number of args
  if (($# != 5)); then
    echo >&2 "Illegal number of parameters"
    echo >&2 "Run like this: \"./run-deb-docker.sh <ubuntu-num-version> <name> <version> <minor> <cmd>\""
    exit 1
  fi

  local distro=$1
  local name=$2
  local release=$3
  local minor_version=$4
  local test_cmd=$5

  local tag="ubuntu_${distro}_deb_tst"

  pushd $(dirname "$0") >/dev/null || exit 1

  docker build --build-arg distro_version="${distro}" --build-arg user_var="${USER}" -t "$tag" ./

  local deb_path=/root/build-area/${name}_${release}/minor_v${minor_version}/${name}_${release}-0ubuntu1ppa${minor_version}~${distro}_amd64.deb
  local cmd="apt install $deb_path -y && $test_cmd"

  docker run -it \
    -v "${HOME}/build-area/:/root/build-area/" \
    -v /dev/bus/usb:/dev/bus/usb \
    "${tag}" \
    /bin/bash -c "$cmd"

  popd >/dev/null || exit 1

}

main "$@"
