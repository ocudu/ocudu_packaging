ARG distro_version
FROM ubuntu:${distro_version}

RUN apt-get update --fix-missing && apt upgrade -y && apt-get dist-upgrade -y && \
    DEBIAN_FRONTEND="noninteractive" TZ="Europe/London" apt-get install -y --no-install-recommends \
        devscripts gnupg-agent git ssh lsb-release libdistro-info-perl equivs sudo fakeroot && \
    apt-get autoremove && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set user
ARG uid=1000
ARG gid=1000
ARG user_var=packager
RUN (userdel ubuntu || true) && \
    groupadd -g $gid "$user_var" && \
    useradd -m -u $uid -g "$user_var" "$user_var" && \
    usermod -aG sudo $user_var && \
    echo "$user_var ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers

USER ${user_var}

WORKDIR /home/${user_var}

ADD debian  /usr/local/share/
ADD scripts /usr/local/bin/
