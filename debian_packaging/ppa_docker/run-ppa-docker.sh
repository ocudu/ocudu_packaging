#!/bin/bash
#
# Copyright 2021-2026 Software Radio Systems Limited
#
# By using this file, you agree to the terms and conditions set
# forth in the LICENSE file which can be found at the top level of
# the distribution.
#

#
# This script will copy a .deb package
# for multiple versions of Ubuntu, for testing purposes.
#
# This script assumes that the deb's were preprepared a priori.
# A separate script should be used to create them.
#
# Run like this: ./run-ppa-docker.sh <ubuntu-version-number> <name> <cmd>
# E.g.: ./run-ppa-docker.sh 25.04 ocudu 'gnb --version'
#
set -e

main() {

  # Check number of args
  if (($# != 3)); then
    echo >&2 "Illegal number of parameters"
    echo >&2 "Run like this: \"./run-ppa-docker.sh <ubuntu-version-number> <name> <cmd>\""
    exit 1
  fi

  local distro=$1
  local name=$2
  local test_cmd=$3

  local tag="ubuntu_${distro}_ppa_tst"

  echo "Testing packaging of $name testing PPA"

  pushd $(dirname "$0") >/dev/null || exit 1

  docker build --build-arg distro_version="${distro}" --build-arg user_var="${USER}" -t "$tag" ./

  cmd="add-apt-repository ppa:ocudu/$name-testing -y &&
      apt update -y && 
      apt install $name -y &&
      $test_cmd"

  docker run -it \
    -v /dev/bus/usb:/dev/bus/usb \
    "${tag}" \
    /bin/bash -c "$cmd"

  popd >/dev/null || exit 1

}

main "$@"
