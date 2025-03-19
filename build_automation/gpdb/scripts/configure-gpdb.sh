#!/bin/bash
# --------------------------------------------------------------------
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed
# with this work for additional information regarding copyright
# ownership.  The ASF licenses this file to You under the Apache
# License, Version 2.0 (the "License"); you may not use this file
# except in compliance with the License.  You may obtain a copy of the
# License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.  See the License for the specific language governing
# permissions and limitations under the License.
#
# --------------------------------------------------------------------
#
# Script: configure-gpdb.sh
# Description: Configures Open-gpdb build environment and runs
#             ./configure with optimized settings. Performs the
#             following:
#             1. Prepares /opt/greenplum-db-6 directory
#             2. Sets up library dependencies
#             3. Configures build with required features enabled
#
# Configuration Features:
#   - Cloud Storage Integration (gpcloud)
#   - IC Proxy Support
#   - MapReduce Processing
#   - Oracle Compatibility (orafce)
#   - ORCA Query Optimizer
#   - PXF External Table Access
#   - Test Automation Support (tap-tests)
#
# System Integration:
#   - GSSAPI Authentication
#   - LDAP Authentication
#   - XML Processing
#   - LZ4 Compression
#   - OpenSSL Support
#   - PAM Authentication
#   - Perl Support
#   - Python Support
#
# Required Environment Variables:
#   SRC_DIR - Root source directory
#
# Optional Environment Variables:
#   BUILD_DESTINATION - Directory to store build files, by default /opt/greenplum-db-6
#   LOG_DIR - Directory for logs (defaults to ${SRC_DIR}/build-logs)
#   ENABLE_DEBUG - Enable debug build options (true/false, defaults to
#                  false)
#
#                 When true, enables:
#                   --enable-debug
#                   --enable-profiling
#                   --enable-cassert
#                   --enable-debug-extensions
#
#   CONFIGURE_EXTRA_OPTS - args to pass to configure
#
# Prerequisites:
#   - System dependencies must be installed:
#     * xerces-c development files
#     * OpenSSL development files
#     * Python development files
#     * Perl development files
#     * LDAP development files
#   - /usr/local must be writable
#   - User must have sudo privileges
#
# Usage:
#   Export required variables:
#     export SRC_DIR=/path/to/open-gpdb/source
#     export BUILD_DESTINATION = debian/build
#   Then run:
#     ./configure-gpdb.sh
#
# Exit Codes:
#   0 - Configuration completed successfully
#   1 - Environment setup failed
#   2 - Directory preparation failed
#   3 - Library setup failed
#   4 - Configure command failed
#
# --------------------------------------------------------------------

set -euo pipefail

# Source common utilities
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/gpdb-utils.sh"

# Define log directory and files
export LOG_DIR="${SRC_DIR}/build-logs"
mkdir -p "${LOG_DIR}"
CONFIGURE_LOG="${LOG_DIR}/configure.log"

# Initialize environment
init_environment "Open-Gpdb Configure Script" "${CONFIGURE_LOG}" "${BUILD_DESTINATION}"

# Initial setup
log_section "Initial Setup"

execute_cmd sudo rm -rf ${BUILD_DESTINATION} || exit 2
execute_cmd sudo mkdir -p ${BUILD_DESTINATION}/lib || exit 2
execute_cmd sudo chmod -R 776 ${BUILD_DESTINATION} || exit 2
execute_cmd sudo chown -R "$(whoami)" ${BUILD_DESTINATION} || exit 2
log_section_end "Initial Setup"

# Add debug options if ENABLE_DEBUG is set to "true"
CONFIGURE_DEBUG_OPTS=""

if [ "${ENABLE_DEBUG:-false}" = "true" ]; then
    CONFIGURE_DEBUG_OPTS="--enable-debug \
                          --enable-profiling \
                          --enable-cassert \
                          --enable-debug-extensions"
fi

# Configure build
log_section "Configure"
execute_cmd ./configure --with-perl --with-python --with-libxml --enable-mapreduce --with-gssapi \
        --with-extra-version="-oss" \
        --with-libs=${BUILD_DESTINATION}/lib \
        --with-includes=${BUILD_DESTINATION}/include \
        --prefix=${BUILD_DESTINATION} \
        ${CONFIGURE_DEBUG_OPTS} \
        --with-ldap \
        --enable-gpperfmon \
        --with-pam \
        --with-openssl \
        --disable-pxf \
        --enable-ic-proxy \
        --with-system-tzdata=/usr/share/zoneinfo \
        --enable-orafce \
        --without-mdblocales \
        --with-zstd ${CONFIGURE_EXTRA_OPTS}

log_section_end "Configure"

log_section "Version Information"
execute_cmd grep -E "GP_VERSION | GP_VERSION_NUM | PG_VERSION | PG_VERSION_NUM | PG_VERSION_STR" src/include/pg_config.h
log_section_end "Version Information"

# Log completion
log_completion "Greenplum Configure Script" "${CONFIGURE_LOG}"
exit 0
