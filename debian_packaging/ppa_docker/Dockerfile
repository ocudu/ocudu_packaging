# Create docker with dependencies installed to make packaging easier
ARG distro_version
FROM ubuntu:${distro_version}
ARG user_var
ARG build_folder

# Set no interactive for apt
ARG DEBIAN_FRONTEND=noninteractive

# Update Ubuntu Software repository
RUN apt update --fix-missing && apt dist-upgrade -y

# Add command for adding PPAs
RUN apt install software-properties-common -y

# Make docker creation non-interactive
RUN apt install tzdata -y

# Convenience utilities
RUN apt install vim iproute2 iputils-ping -y

RUN apt install uhd-host -y
RUN uhd_images_downloader


