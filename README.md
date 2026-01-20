# Debian Packaging

This repository contains packaging helper scripts for creating debian packages.

If you wish to upload the packages, you will need to have previously
configured your GPG keys.

## TL;DR

```bash
PACKAGING_URL=https://gitlab.com/ocudu/ocudu.git
PACKAGING_REF=release_26_04
PACKAGING_NAME=ocudu
PACKAGING_VERSION="26.04"
PACKAGING_MINOR="1"
PACKAGING_TEST_CMD="gnb --version"

# Making the original tarball and preparing the sources
./debian_packaging/scripts/package_all.sh ${PACKAGING_URL} ${PACKAGING_REF} ${PACKAGING_NAME} ${PACKAGING_VERSION} ${PACKAGING_MINOR}

# Building Testing Deb Stage. **Not to advance if this fails**
./debian_packaging/scripts/dpkg_all.sh ${PACKAGING_NAME} ${PACKAGING_VERSION} ${PACKAGING_MINOR}

# Installing the generated deb. **Not to advance if this fails**
./debian_packaging/scripts/deb_all.sh ${PACKAGING_NAME} ${PACKAGING_VERSION} ${PACKAGING_MINOR} "${PACKAGING_TEST_CMD}"

# Uploading generated deb to testing repository
# Go to the Uploading Stage section

# Test packages in testing repository
./debian_packaging/scripts/ppa_all.sh ${PACKAGING_NAME} ${PACKAGING_VERSION} ${PACKAGING_MINOR} "${PACKAGING_TEST_CMD}"

# Moving packages from testing repository to final one
# Go to the Finalizing Stage section
```

## Packaging Stage

### Steps

#### Preparing for packaging

First, create and run the packaging docker by doing:

```bash
./debian_packaging/packaging_docker/run-pkg-docker.sh 25.04
```

Note, that this will try to mount a build-area, ssh keys and GPG keys.

**Following steps will run inside the container!**

#### Making the original tarball

Before packaging, you need to make the original tarball for this release.

Before doing this, make sure that the `debian/changelog` is correct (you might have to make a commit after doing this).
Once that is done, run the `make_orig_tarball` script by giving it as argument the downloaded repository, the commit (or tag) to package, and the packaging name and version.

E.g, for release `26.04.1`, do:

```bash
make_orig_tarball.sh https://gitlab.com/ocudu/ocudu.git release_26_04_1 ocudu 26.04.1
```

#### Preparing the sources

Before doing the actual packaging, you will need to prepare the sources by running the `package.sh` script.
The `minor` version (aka `pkgrel` or *package release number*) should be `1`, unless you need to bump it to fix packaging mistakes for the same software version.

Before running this, make sure that you edit the Ubuntu versions that you wish to target.
See "<https://ubuntu.com/about/release-cycle>" and "<https://wiki.ubuntu.com/Releases>", to see which Ubuntu versions are currently supported.

E.g, for release `26.04.1`, do:

```bash
package.sh ocudu 26.04.1 1
```

After preparing the packaging, go to the folders in `build-area/<name>_<release>/minor_v<minor_version>/`
and double check whether everything is correct (e.g. on the `debian/changelog`).

### All Ubuntu versions

Previous steps can be automatically executed for all supported Ubuntu versions by running:

```bash
./debian_packaging/scripts/package_all.sh https://gitlab.com/ocudu/ocudu.git release_26_04_1 ocudu 26.04.1 1
```

## Building Testing Deb Stage

### Steps

#### Preparing for build a testing deb

Follow instructions in `Preparing for packaging` section

**Following steps will run inside the container!**

### Building a testing deb

Before uploading, try to make sure the build is successful by running:

```bash
dpkg.sh ocudu 26.04.1 1
```

This will run `dpkg-buildpackage -us -uc`.
This allows you to see any compilation errors or other errors in the `debian/` folder.

*Do not upload the package if this fails.*
Delete any commits in the OCUDU packaging repos, and the files related to this build in this area and fix the issue.
Once that is done, test the `.deb`.

### All Ubuntu versions

Previous steps can be automatically executed for all supported Ubuntu versions by running:

```bash
./debian_packaging/scripts/dpkg_all.sh ocudu 26.04.1 1
```

## Installing the generated deb

### Steps

#### Preparing

First, create and run the install docker by doing:

```bash
./debian_packaging/install_docker/run-deb-docker.sh 25.04 ocudu 26.04.1 1 'gnb --version'
```

This will execute, inside the container:

```bash
apt update
DEBIAN_FRONTEND='noninteractive' TZ='Europe/London' apt install $deb_name -y 
```

And your installed binary would be run with the provided command_

```bash
gnb --version
```

*Do not upload the package if this fails.*

### All Ubuntu versions

Previous steps can be automatically executed for all supported Ubuntu versions by running:

```bash
./debian_packaging/scripts/deb_all.sh ocudu 26.04.1 1 'gnb --version'
```

## Uploading Stage

Finally, after all testing as passed, go inside the packaging docker and create and sign the package for uploading:

```bash
/usr/bin/gpg-agent 
debuild -S
```

If you want to use a key that is not the default for your user, use:

```bash
debuild -S -kpedro@srs.io
```

Finally, upload to the launchpad testing ppa:

```bash
dput ppa:ocudu/ocudu-testing <ocudu_changes_file>_source.changes
```

## Installing packages from testing repository

### Steps

#### Preparing

First, create and run the ppa docker by doing:

```bash
./debian_packaging/install_docker/run-ppa-docker.sh 25.04 ocudu 26.04.1 1 'gnb --version'
```

This will install your package in the testing repo by doing:

```bash
add-apt-repository ppa:ocudu/$name-testing -y &&
      apt update -y &&
      apt install $name -y
```

After that, your installed binary will be tested by running the provided command:

```bash
gnb --version"
```

### All Ubuntu versions

Previous steps can be automatically executed for all supported Ubuntu versions by running:

```bash
./debian_packaging/scripts/ppa_all.sh ocudu 26.04.1 1 'gnb --version'
```

## Finalizing Stage

Once you are done with testing, copy the packages to the releases PPA using the Launchpad interface.
