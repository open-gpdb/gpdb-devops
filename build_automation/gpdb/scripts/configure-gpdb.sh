#!/bin/bash
# --------------------------------------------------------------------
#
# Script: configure-gpdb.sh
# Description: Configures Greenplum build environment and runs
#             ./configure with optimized settings.
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
init_environment "Cloudberry Configure Script" "${CONFIGURE_LOG}"

# Initial setup
log_section "Initial Setup"
execute_cmd sudo rm -rf /usr/local/greenplum-db || exit 2
execute_cmd sudo chmod a+w /usr/local || exit 2
execute_cmd mkdir -p /usr/local/greenplum-db/lib || exit 2
execute_cmd sudo chown -R gpadmin:gpadmin /usr/local/greenplum-db || exit 2
log_section_end "Initial Setup"

BUILD_DESTINATION=/usr/local/greenplum-db

# Configure build
log_section "Configure"
execute_cmd ./configure --with-perl --with-python --with-libxml --enable-mapreduce --with-gssapi \
		--with-extra-version="-oss" \
        --with-libs=${BUILD_DESTINATION}/lib \
        --with-includes=${BUILD_DESTINATION}/include \
        --prefix=${BUILD_DESTINATION} \
        --with-ldap \
        --enable-gpperfmon \
	    --with-pam \
        --with-openssl \
        --disable-pxf \
        --enable-ic-proxy \
        --with-system-tzdata=/usr/share/zoneinfo \
        --enable-orafce \
		--without-mdblocales \
        --with-zstd

log_section_end "Configure"

log_section "Version Information"
execute_cmd grep -E "GP_VERSION | GP_VERSION_NUM | PG_VERSION | PG_VERSION_NUM | PG_VERSION_STR" src/include/pg_config.h
log_section_end "Version Information"

# Log completion
log_completion "Greenplum Configure Script" "${CONFIGURE_LOG}"
exit 0