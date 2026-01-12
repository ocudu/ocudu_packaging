#!/bin/bash
#
# This script creates a docker for packaging
# It mounts a few folders for ease-of-packaging, namely:
#
# 1 - Build area folder, for storing old packages: $HOME/build-area
# 2 - GPG keys for signing the packages: $HOME/.gnupg
# 3 - SSH keys for being able to download repos using git+ssh
#
# Run like this: ./run-pkg-docker.sh [<ubuntu-num-version> [<cmd>]]
# E.g.: ./run-pkg-docker.sh
# E.g.: ./run-pkg-docker.sh 25.04
# E.g.: ./run-pkg-docker.sh 25.04 ls
#

main() {

  # Check number of args
  if (($# >= 3)); then
    echo >&2 "Illegal number of parameters"
    echo >&2 "Run like this: \"./run-pkg-docker.sh [<ubuntu-num-version> [<cmd>]]\""
    exit 1
  fi

  local distro="${1:-25.04}"
  local cmd="${2:-bash}"

  tag=ubuntu_${distro}_img_pkg

  pushd $(dirname "$0") >/dev/null || exit 1

  docker build --build-arg distro_version="${distro}" --build-arg uid=$(id -u ${USER}) --build-arg gid=$(id -g ${USER}) --build-arg user_var="${USER}" -t $tag ./

  mkdir -p ${HOME}/build-area ${HOME}/.gnupg ${HOME}/.ssh

  docker run -it --rm \
    --ulimit nofile=1024:1024 \
    -v ./debian:/usr/local/share \
    -v "${HOME}/build-area:${HOME}/build-area" \
    -v "${HOME}/.gnupg:${HOME}/.gnupg" \
    -v "${HOME}/.ssh:${HOME}/.ssh" \
    -u $(id -u ${USER}):$(id -g ${USER}) \
    ${tag} ${cmd}

  popd >/dev/null || exit 1

}

main "$@"
