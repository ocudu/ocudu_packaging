#!/bin/bash
#
# Copyright 2021-2026 Software Radio Systems Limited
#
# By using this file, you agree to the terms and conditions set
# forth in the LICENSE file which can be found at the top level of
# the distribution.
#

#
# This script will package a particular release
# for a single versions of Ubuntu.
#
# This script assumes that an original tarball has been created a priori,
# A separate script should be used to create it.
#
# Run like this: ./package.sh <name> <version> <minor> [<ubuntu-version> <ubuntu-name>]
# E.g.: ./package.sh ocudu 26.04.1 1
# E.g.: ./package.sh ocudu 26.04.1 1 25.04 plucky
#
set -e

. /etc/os-release

main() {

  # Check number of args
  if [ $# != 3 ] && [ $# != 5 ]; then
    echo >&2 "Illegal number of parameters"
    echo >&2 "Run like this: \"./package.sh <name> <version> <minor> [<ubuntu-version> <ubuntu-name>]\""
    exit 1
  fi

  echo "== Packaging sources =="

  local name=$1
  local release=$2
  local minor_version=$3

  local ubuntu_num="${4:-$VERSION_ID}"
  local ubuntu_name="${5:-$VERSION_CODENAME}"

  local orig_tar_location=~/build-area/${name}_$release/${name}_$release.orig.tar.gz
  local build_dir=~/build-area/${name}_$release/minor_v$minor_version/$ubuntu_name
  local src_dir=$build_dir/$name

  echo "Packaging ${name} release $release, minor release $minor_version, for Ubuntu $ubuntu_name"
  echo "Original tarball location: $orig_tar_location"

  # Make build dir for the package
  mkdir -p "$src_dir"
  echo 'Project location: ' "$src_dir"

  # Copy and extract original tarball
  cp "$orig_tar_location" "$build_dir"
  pushd "$src_dir" >/dev/null || exit 1
  tar xf "$orig_tar_location"
  popd >/dev/null || exit 1

  # Copy debian folder
  mkdir -p "$src_dir"/debian

  original_debian_src="$(dirname "$0")/../debian/$name"
  if [ -d "/usr/local/share/$name" ]; then
    # Docker mode
    original_debian_src=/usr/local/share/"$name"
  fi
  cp -r "$original_debian_src"/* "$src_dir"/debian/

  # Change debian/changelog
  # The package version naming is based on the recomendations here: https://help.launchpad.net/Packaging/PPA/BuildingASourcePackage
  local debchange_msg="Update to $name $release with minor version $minor_version (Ubuntu $ubuntu_num)"
  local pkg_name="$release-0ubuntu1ppa$minor_version~$ubuntu_num"

  pushd "$src_dir" >/dev/null || exit 1
  debchange --package "$name" --newversion="$pkg_name" --changelog=debian/changelog --distribution="$ubuntu_name" -m "$debchange_msg" || exit 1
  popd >/dev/null || exit 1

  # Copy back modified debian folder
  cp -r "$src_dir"/debian/* "$original_debian_src"/

}

main "$@"
