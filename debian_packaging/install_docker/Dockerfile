#
# Copyright 2021-2026 Software Radio Systems Limited
#
# By using this file, you agree to the terms and conditions set
# forth in the LICENSE file which can be found at the top level of
# the distribution.
#

# Create docker with dependencies installed to make packaging easier
ARG distro_version
FROM ubuntu:${distro_version}
ARG user_var
ARG build_folder

# Set no interactive for apt
ARG DEBIAN_FRONTEND=noninteractive

# Update Ubuntu Software repository
RUN apt update --fix-missing && apt dist-upgrade -y

# Make docker creation non-interactive
RUN apt install tzdata -y

# Convinience utilities
RUN apt install vim iproute2 iputils-ping -y

RUN apt install uhd-host -y
RUN uhd_images_downloader


