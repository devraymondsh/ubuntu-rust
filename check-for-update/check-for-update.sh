#!/bin/bash

cd ubuntu-rust

apt-get install --yes libssl-dev pkg-config git
cargo install rust-latest

LATEST_RUST_VERSION=$(rust-latest -c stable -p minimal -t all)
CURRENT_RUST_VERSION=$(<check-for-update/version.txt)

function version_compare {
    echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'
}
if [ "$(version_compare "$CURRENT_RUST_VERSION")" -ge "$(version_compare "$LATEST_RUST_VERSION")" ]; then
    echo "Nothing to do!"

    exit 0
fi

CURRENT_NO_MINOR_RUST_VERSION=${CURRENT_RUST_VERSION%.*}
LATEST_NO_MINOR_RUST_VERSION=${LATEST_RUST_VERSION%.*}

WORKFLOW_SAMPLE=$(<check-for-update/workflow-sample.yml)
DOCKERHUB_DESCRIPTION_UPDATER=$(tail -n +2 "check-for-update/dockerhub-description.txt")

git config --global user.name "github-actions"
git config --global user.email "github-actions@github.com"
git config --global --add safe.directory $(realpath .)

function workflow_creator {
    local repo="devraymondsh/ubuntu-rust"
    local rust_version="$1"
    local ubuntu_codename="$2"
    local ubuntu_version="$3"
    local is_the_latest="$4"

    local tags=""

    # e.g: devraymondsh/ubuntu-rust:22.10
    # e.g: devraymondsh/ubuntu-rust:22.10-1.66
    tags+="$repo:$ubuntu_version,$repo:$ubuntu_version-$rust_version,"

    # e.g: devraymondsh/ubuntu-rust:22.10-latest
    # e.g: devraymondsh/ubuntu-rust:kinetic
    tags+="$repo:$ubuntu_version-latest,$repo:$ubuntu_codename,"

    # e.g: devraymondsh/ubuntu-rust:kinetic-1.66
    # e.g: devraymondsh/ubuntu-rust:kinetic-latest,
    tags+="$repo:$ubuntu_codename-$rust_version,$repo:$ubuntu_codename-latest"

    local workflow=${WORKFLOW_SAMPLE//_UBUNTU_RELEASE_VERSION_/$ubuntu_version}

    if $is_the_latest; then
        # e.g: devraymondsh/ubuntu-rust:1.66,
        # e.g: devraymondsh/ubuntu-rust:latest, 
        # e.g: devraymondsh/ubuntu-rust:latest-1.66
        tags+=",$repo:$rust_version,$repo:latest,$repo:latest-$rust_version"

        workflow+=$DOCKERHUB_DESCRIPTION_UPDATER
    fi

    workflow=${workflow//_UBUNTU_RELEASE_CODENAME_/$ubuntu_codename}
    workflow=${workflow//_DOCKER_IMAGE_TAGS_/$tags}

    local file_destination=".github/workflows/docker-$ubuntu_codename.yml"
    echo "$workflow" > "$file_destination"
}
workflow_creator "$LATEST_NO_MINOR_RUST_VERSION" "lunar" "23.04" true
workflow_creator "$LATEST_NO_MINOR_RUST_VERSION" "kinetic" "22.10" false
workflow_creator "$LATEST_NO_MINOR_RUST_VERSION" "jammy" "22.04" false
workflow_creator "$LATEST_NO_MINOR_RUST_VERSION" "focal" "20.04" false

README=$(<README.md)
README=${README//$CURRENT_NO_MINOR_RUST_VERSION/$LATEST_NO_MINOR_RUST_VERSION}
echo "$README" > "README.md"

INSTALL_SCRIPT=$(<install.sh)
INSTALL_SCRIPT=${INSTALL_SCRIPT//$CURRENT_RUST_VERSION/$LATEST_RUST_VERSION}
echo "$INSTALL_SCRIPT" > "install.sh"

echo "$LATEST_RUST_VERSION" > "check-for-update/version.txt"

git add .
git commit -m "Add rust v$LATEST_RUST_VERSION"
git push "https://devraymondsh:$GITHUB_TOKEN@github.com/devraymondsh/ubuntu-rust.git"