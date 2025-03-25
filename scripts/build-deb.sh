#!/bin/bash
#
# Script Name: build-deb.sh
#
# Description:
# This script automates the process of building an DEB package using a specified
# version number. It ensures that the necessary tools are installed
# and that the control file exists before attempting to build the DEB. The script
# also includes error handling to provide meaningful feedback in case of failure.
#
# Usage:
# ./build-deb.sh [-v <version>] [-h] [--dry-run]
#
# Options:
#   -v, --version <version>    : Specify the version (required)
#   -h, --help                 : Display this help and exit
#   -n, --dry-run              : Show what would be done, without making any changes
#
# Example:
#   ./build-deb.sh -v 1.5.5               # Build with version 1.5.5
#
# Prerequisites:
# - The dpkg-buildpackage package must be installed (provides the dpkg-buildpackage command).
# - The control file must exist at debian/control.
#
# Error Handling:
# The script includes checks to ensure:
# - The version option (-v or --version) is provided.
# - The necessary commands are available.
# - The control file exists at the specified location.
# If any of these checks fail, the script exits with an appropriate error message.

# Enable strict mode for better error handling
set -euo pipefail

# Default values
VERSION=""
RELEASE="1"
DEBUG_BUILD=false

# Function to display usage information
usage() {
  echo "Usage: $0 [-v <version>] [-h] [--dry-run]"
  echo "  -v, --version <version>    : Specify the version (optional)"
  echo "  -h, --help                 : Display this help and exit"
  echo "  -n, --dry-run              : Show what would be done, without making any changes"
  exit 1
}

# Function to check if required commands are available
check_commands() {
  local cmds=("dpkg-buildpackage")
  for cmd in "${cmds[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
      echo "Error: Required command '$cmd' not found. Please install it before running the script."
      exit 1
    fi
  done
}

function print_changelog() {
cat <<EOF
greenplum-db-6 (${GPDB_PKG_VERSION}) stable; urgency=low

  * open-gpdb autobuild

  -- ${BUILD_USER} <${BUILD_USER}@$(hostname)>  $(date +'%a, %d %b %Y %H:%M:%S %z')
EOF
}

# Parse options
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -v|--version)
      VERSION="$2"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    -n|--dry-run)
      DRY_RUN=true
      shift
      ;;
    *)
      echo "Unknown option: ($1)"
      shift
      ;;
  esac
done

export GPDB_FULL_VERSION=$VERSION

# Set version if not provided
if [ -z "${VERSION}" ]; then
  export GPDB_FULL_VERSION=$(./getversion | cut -d'-' -f 1 | cut -d'+' -f 1)
fi

if [[ ! $GPDB_FULL_VERSION =~ ^[0-9] ]]; then
    export GPDB_FULL_VERSION="0.$GPDB_FULL_VERSION"
fi 

if [ -z ${BUILD_NUMBER+x} ]; then
  export BUILD_NUMBER=1
fi

if [ -z ${BUILD_USER+x} ]; then
  export BUILD_USER=github
fi

export GPDB_PKG_VERSION=${GPDB_FULL_VERSION}-${BUILD_NUMBER}-yandex.$(git --git-dir=.git rev-list HEAD --count).$(git --git-dir=.git rev-parse --short HEAD)

# Check if required commands are available
check_commands

# Define the control file path
CONTROL_FILE=debian/control

# Check if the spec file exists
if [ ! -f "$CONTROL_FILE" ]; then
  echo "Error: Control file not found at $CONTROL_FILE."
  exit 1
fi

# Build the rpmbuild command based on options
DEBBUILD_CMD="dpkg-buildpackage -us -uc"

# Dry-run mode
if [ "${DRY_RUN:-false}" = true ]; then
  echo "Dry-run mode: This is what would be done:"
  print_changelog
  echo ""
  echo "$DEBBUILD_CMD"
  exit 0
fi

# Run debbuild with the provided options
echo "Building DEB with Version $GPDB_FULL_VERSION ..."

print_changelog > debian/changelog

if ! eval "$DEBBUILD_CMD"; then
  echo "Error: deb build failed."
  exit 1
fi

# Print completion message
echo "DEB build completed successfully with package $GPDB_PKG_VERSION"
