#!/bin/bash

# SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
# SPDX-License-Identifier: BSD-3-Clause-Open-MPI

#
# Make original tarball. Will be run once per release packaging.
# A new orig tarball should be used for each minor version.
# The commit to make the tarball from is passed as a parameter.
#
# Run like this: ./make_orig_tarball.sh <repo> <tag/branch/hash> <name> <version>
# E.g.: ./make_orig_tarball.sh https://gitlab.com/ocudu/ocudu.git release_26_04_1 ocudu 26.04.1
#
set -e

main() {

  # Check number of args
  if (($# != 4)); then
    echo >&2 "Illegal number of parameters"
    echo >&2 "Run like this: \"./make_orig_tarball.sh <repo> <tag/branch/hash> <name> <version>\""
    exit 1
  fi

  echo "== Making original tarball =="

  # Get source dir
  local orig_repo=$1
  local orig_commit=$2
  local name=$3
  local release=$4

  echo "Making original tarball $name release $release"

  # Get original tarball dir
  local orig_dir=~/build-area/${name}_"$release"
  mkdir -p "$orig_dir"

  # Checkout repo
  local src_dir=$orig_dir/$name
  rm -Rf "$src_dir"
  git clone "$orig_repo" $src_dir

  # Get original tarball name and location
  local orig_name=${name}_"$release".orig.tar.gz
  local orig_tar_location=$orig_dir/$orig_name

  # Check if original tarball already exits
  if [ -f "$orig_tar_location" ]; then
    echo >&2 "Original tarball already exists!"
    exit 1
  fi

  # Create original tarball
  echo 'Location: ' "$orig_tar_location"
  pushd "$src_dir" >/dev/null || exit 1
  git archive "$orig_commit" -o "$orig_tar_location"
  popd >/dev/null || exit 1

}

main "$@"
