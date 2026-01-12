#!/bin/bash

#
# This script will copy a .deb package
# for multiple versions of Ubuntu, for testing purposes.
#
# This script assumes that the deb's were preprepared a priori.
# A separate script should be used to create them.
#
# Run like this: ./ppa_all.sh <name> <mcd>
# E.g.: ./ppa_all.sh ocudu `gnb --version`
#
set -e

source $(dirname "$0")/get_ubuntu_versions.sh

main() {

  # Check number of args
  if (($# != 2)); then
    echo >&2 "Illegal number of parameters"
    echo >&2 "Run like this: \"./ppa_all.sh <name> <cmd>\""
    exit 1
  fi

  local name=$1
  local cmd=$2

  eval "$(get_ubuntu_version_array)"

  local ubuntu_num
  for ubuntu_num in $sorted_ubuntu_versions; do
    echo "=============================================================================="
    echo "Installing testing PPA deb $name $release (minor $minor) Ubuntu $ubuntu_num"
    echo "=============================================================================="
    $(dirname "$0")/../ppa_docker/run-ppa-docker.sh "$ubuntu_num" "$name" "$cmd"
  done
}

main "$@"
