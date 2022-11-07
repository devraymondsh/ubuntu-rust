#!/bin/bash

cd ubuntu-docker-rust

apt-get install --yes libssl-dev pkg-config git
cargo install rust-latest

LATEST_RUST_VERSION=$(rust-latest -c stable -p minimal -t all)
LATEST_NO_MINOR_RUST_VERSION=${LATEST_RUST_VERSION%.*}

git config --global user.name "github-actions"
git config --global user.email "github-actions@github.com"
git config --global --add safe.directory $(realpath .)

WORKFLOW_SAMPLE=$(<check-for-update/workflow-sample.yml)
CURRENT_RUST_VERSION=$(<check-for-update/version.txt)
CURRENT_NO_MINOR_RUST_VERSION=${CURRENT_RUST_VERSION%.*}

function version_compare {
    echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'
}
if [ "$(version_compare "$CURRENT_RUST_VERSION")" -ge "$(version_compare "$LATEST_RUST_VERSION")" ]; then
    echo "Nothing to do!"

    exit 0
fi

function workflow_creator {
    local repo="devraymondsh/ubuntu-docker-rust"
    local rust_version="$1"
    local ubuntu_codename="$2"
    local ubuntu_version="$3"
    local is_the_latest="$4"

    local tags=""

    # devraymondsh/ubuntu-docker-rust:22.10
    # devraymondsh/ubuntu-docker-rust:22.10-1.65
    tags+="$repo:$ubuntu_version,$repo:$ubuntu_version-$rust_version,"

    # devraymondsh/ubuntu-docker-rust:22.10-latest
    # devraymondsh/ubuntu-docker-rust:kinetic
    tags+="$repo:$ubuntu_version-latest,$repo:$ubuntu_codename,"

    # devraymondsh/ubuntu-docker-rust:kinetic-1.65
    # devraymondsh/ubuntu-docker-rust:kinetic-latest,
    tags+="$repo:$ubuntu_codename-$rust_version,$repo:$ubuntu_codename-latest"

    if $is_the_latest; then
        # devraymondsh/ubuntu-docker-rust:1.65,
        # devraymondsh/ubuntu-docker-rust:latest, 
        # devraymondsh/ubuntu-docker-rust:latest-1.65
        tags+=",$repo:$rust_version,$repo:latest,$repo:latest-$rust_version"
    fi

    local workflow=${WORKFLOW_SAMPLE//_UBUNTU_RELEASE_VERSION_/$ubuntu_version}
    workflow=${workflow//_UBUNTU_RELEASE_CODENAME_/$ubuntu_codename}
    workflow=${workflow//_DOCKER_IMAGE_TAGS_/$tags}

    local file_destination=".github/workflows/docker-$ubuntu_codename.yml"
    echo "$workflow" > "$file_destination"
}
workflow_creator "$LATEST_NO_MINOR_RUST_VERSION" "kinetic" "22.10" true
workflow_creator "$LATEST_NO_MINOR_RUST_VERSION" "jammy" "22.04" false
workflow_creator "$LATEST_NO_MINOR_RUST_VERSION" "focal" "20.04" false

README=$(<README.md)
README=${README//$CURRENT_NO_MINOR_RUST_VERSION/$LATEST_NO_MINOR_RUST_VERSION}
echo "$README" > "README.md"

INSTALL_SCRIPT=$(<install.sh)
INSTALL_SCRIPT=${INSTALL_SCRIPT//$CURRENT_RUST_VERSION/$LATEST_RUST_VERSION}
echo "$INSTALL_SCRIPT" > "install.sh"

git add .
git commit -m "Add rust v$LATEST_RUST_VERSION"
git push "https://devraymondsh:$GITHUB_TOKEN@github.com/devraymondsh/ubuntu-docker-rust.git"

echo "$LATEST_RUST_VERSION" > "check-for-update/version.txt"