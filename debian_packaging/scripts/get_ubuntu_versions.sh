#!/bin/bash

#
# Dynamically get all currently supported Ubuntu versions
#

get_ubuntu_version_array() {

    # Versions of Ubuntu that we whish to package for
    # See: https://wiki.ubuntu.com/Releases

    distro_info=$(
        docker run -i --rm ubuntu /bin/bash <<-EOF

apt-get update >/dev/null 2>&1
apt-get install -y --no-install-recommends distro-info >/dev/null 2>&1
apt-get install -y --only-upgrade distro-info-data >/dev/null 2>&1

if echo "\$(distro-info -d 2>&1)" | grep -q "Distribution data outdated"; then
    echo "Distribution data in distro-info outdated."
    exit 1
fi

codenames=\$(distro-info --supported | grep -v "\$(distro-info --devel)")
releases=\$(distro-info --supported --release | grep -v "\$(distro-info --devel --release)" | sed 's/ LTS//g')

echo \$(paste <(echo "\$releases") <(echo "\$codenames"))

EOF
    )

    pairs=($distro_info)

    # Get versions array
    local -A ubuntu_version_array
    for ((i = 0; i < ${#pairs[@]}; i += 2)); do
        key=${pairs[$i]}
        value=${pairs[$i + 1]}
        ubuntu_version_array["$key"]=$value
    done

    # Sort Ubuntu versions by release number (and older to new)
    keys=(${!ubuntu_version_array[@]})
    IFS=$'\n' sorted_keys=($(sort <<<"${keys[*]}"))
    unset IFS

    # Convert from array to string separated by spaces
    sorted_ubuntu_versions=""
    for version in "${sorted_keys[@]}"; do
        sorted_ubuntu_versions+="${version} "
    done

    declare -p ubuntu_version_array
    declare -p sorted_ubuntu_versions

}
