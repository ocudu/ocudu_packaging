#!/bin/bash

#
# This script will package a particular release of the specified project
# for multiple versions of Ubuntu.
#
# Run like this: ./package_all.sh <repo> <tag/branch/hash> <name> <version> <minor>
# E.g.: ./package_all.sh https://gitlab.com/ocudu/ocudu.git release_26_04_1 ocudu 26.04.1 1
#
set -e

source $(dirname "$0")/get_ubuntu_versions.sh

main() {

  # Check number of args
  if (($# != 5)); then
    echo >&2 "Illegal number of parameters"
    echo >&2 "Run like this: \"./package_all.sh <repo> <tag/branch/hash> <name> <version> <minor>\""
    exit 1
  fi

  local orig_repo=$1
  local orig_commit=$2
  local name=$3
  local release=$4
  local minor=$5

  eval "$(get_ubuntu_version_array)"

  # Get latest released Ubuntu
  local last_ubuntu_num
  IFS=$' ' read -r -a _versions_array_ <<<"$sorted_ubuntu_versions"
  last_ubuntu_num="${_versions_array_[-1]}"

  echo "======================="
  echo "Making Original Tarball"
  echo "======================="
  $(dirname "$0")/../packaging_docker/run-pkg-docker.sh "$last_ubuntu_num" "make_orig_tarball.sh $orig_repo $orig_commit $name $release"

  for ubuntu_num in $sorted_ubuntu_versions; do
    echo "==============================================================="
    echo "Making package $name $release (minor $minor) Ubuntu $ubuntu_num"
    echo "==============================================================="
    $(dirname "$0")/../packaging_docker/run-pkg-docker.sh "$last_ubuntu_num" "package.sh $name $release $minor $ubuntu_num ${ubuntu_version_array[$ubuntu_num]}"
  done
}

main "$@"
