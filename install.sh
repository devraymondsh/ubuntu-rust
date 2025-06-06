#!/bin/bash

echo "check_certificate = off" >> ~/.wgetrc

apt-get update && apt-get install --yes --no-install-recommends apt-utils ca-certificates &&
    apt-get --yes upgrade && apt-get install --yes --no-install-recommends sudo build-essential wget curl

DEFAULT_RUST_VERSION=1.87.0
DEFAULT_RUSTUP_VERSION=1.27.0
RUST_VERSION=${1:-$DEFAULT_RUST_VERSION}
RUSTUP_VERSION=${2:-$DEFAULT_RUSTUP_VERSION}

set -eux
dpkgArch="$(dpkg --print-architecture)"

case "${dpkgArch##*-}" in
amd64)
    rustArch='x86_64-unknown-linux-gnu'
    rustupSha256='a3d541a5484c8fa2f1c21478a6f6c505a778d473c21d60a18a4df5185d320ef8'
    ;;
armhf)
    rustArch='armv7-unknown-linux-gnueabihf'
    rustupSha256='7cff34808434a28d5a697593cd7a46cefdf59c4670021debccd4c86afde0ff76'
    ;;
arm64)
    rustArch='aarch64-unknown-linux-gnu'
    rustupSha256='76cd420cb8a82e540025c5f97bda3c65ceb0b0661d5843e6ef177479813b0367'
    ;;
i386)
    rustArch='i686-unknown-linux-gnu'
    rustupSha256='cacdd10eb5ec58498cd95dbb7191fdab5fa4343e05daaf0fb7cdcae63be0a272'
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
