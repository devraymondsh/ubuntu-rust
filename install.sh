#!/bin/bash

echo "check_certificate = off" >> ~/.wgetrc

apt-get update && apt-get install --yes --no-install-recommends apt-utils ca-certificates &&
    apt-get --yes upgrade && apt-get install --yes --no-install-recommends sudo build-essential wget curl

DEFAULT_RUST_VERSION=1.65.0
DEFAULT_RUSTUP_VERSION=1.25.1
RUST_VERSION=${1:-$DEFAULT_RUST_VERSION}
RUSTUP_VERSION=${2:-$DEFAULT_RUSTUP_VERSION}

set -eux
dpkgArch="$(dpkg --print-architecture)"

case "${dpkgArch##*-}" in
amd64)
    rustArch='x86_64-unknown-linux-gnu'
    rustupSha256='5cc9ffd1026e82e7fb2eec2121ad71f4b0f044e88bca39207b3f6b769aaa799c'
    ;;
armhf)
    rustArch='armv7-unknown-linux-gnueabihf'
    rustupSha256='48c5ecfd1409da93164af20cf4ac2c6f00688b15eb6ba65047f654060c844d85'
    ;;
arm64)
    rustArch='aarch64-unknown-linux-gnu'
    rustupSha256='e189948e396d47254103a49c987e7fb0e5dd8e34b200aa4481ecc4b8e41fb929'
    ;;
i386)
    rustArch='i686-unknown-linux-gnu'
    rustupSha256='0e0be29c560ad958ba52fcf06b3ea04435cb3cd674fbe11ce7d954093b9504fd'
    ;;
*)
    echo >&2 "unsupported architecture: ${dpkgArch}"
    exit 1
    ;;
esac

url="https://static.rust-lang.org/rustup/archive/${RUSTUP_VERSION}/${rustArch}/rustup-init"
wget "$url"
echo "${rustupSha256} *rustup-init" | sha256sum -c -
chmod +x rustup-init

./rustup-init -y --no-modify-path --profile minimal --default-toolchain "$RUST_VERSION" --default-host ${rustArch}

rm rustup-init
apt-get autoremove --yes && apt-get autoclean --yes

chmod -R a+w "$RUSTUP_HOME" "$CARGO_HOME"

rustup --version
cargo --version
rustc --version
