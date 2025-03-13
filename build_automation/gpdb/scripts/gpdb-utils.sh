#!/bin/bash
# --------------------------------------------------------------------
#
# Library: gpdb-utils.sh
# Description: Common utility functions for Greenplum build
# and test scripts
#
# --------------------------------------------------------------------

DEFAULT_BUILD_DESTINATION=/opt/greenplum-db-6

# Initialize logging and environment
init_environment() {

    local script_name=$1
    local log_file=$2
    local build_destination=$3

    if [ -z "$build_destination" ]; then
        build_destination=${DEFAULT_BUILD_DESTINATION}
    fi
    export BUILD_DESTINATION=$build_destination

    echo "=== Initializing environment for ${script_name} ==="
    echo "${script_name} executed at $(date)" | tee -a "${log_file}"
    echo "Whoami: $(whoami)" | tee -a "${log_file}"
    echo "Hostname: $(hostname)" | tee -a "${log_file}"
    echo "Working directory: $(pwd)" | tee -a "${log_file}"
    echo "Source directory: ${SRC_DIR}" | tee -a "${log_file}"
    echo "Log directory: ${LOG_DIR}" | tee -a "${log_file}"
    echo "Build destination: ${BUILD_DESTINATION}" | tee -a "${log_file}"

    if [ -z "${SRC_DIR:-}" ]; then
        echo "Error: SRC_DIR environment variable is not set" | tee -a "${log_file}"
        exit 1
    fi

    mkdir -p "${LOG_DIR}"
}

# Function to echo and execute command with logging
execute_cmd() {
    local cmd_str="$*"
    local timestamp=$(date "+%Y.%m.%d-%H.%M.%S")
    echo "Executing at ${timestamp}: $cmd_str" | tee -a "${LOG_DIR}/commands.log"
    "$@" 2>&1 | tee -a "${LOG_DIR}/commands.log"
    return ${PIPESTATUS[0]}
}

# Function to run psql commands with logging
run_psql_cmd() {
    local cmd=$1
    local timestamp=$(date "+%Y.%m.%d-%H.%M.%S")
    echo "Executing psql at ${timestamp}: $cmd" | tee -a "${LOG_DIR}/psql-commands.log"
    psql -P pager=off template1 -c "$cmd" 2>&1 | tee -a "${LOG_DIR}/psql-commands.log"
    return ${PIPESTATUS[0]}
}

# Function to source Cloudberry environment
source_cloudberry_env() {
    echo "=== Sourcing Cloudberry environment ===" | tee -a "${LOG_DIR}/environment.log"
    source /usr/local/cloudberry-db/greenplum_path.sh
    source ${SRC_DIR}/../cloudberry/gpAux/gpdemo/gpdemo-env.sh
}

# Function to log section start
log_section() {
    local section_name=$1
    local timestamp=$(date "+%Y.%m.%d-%H.%M.%S")
    echo "=== ${section_name} started at ${timestamp} ===" | tee -a "${LOG_DIR}/sections.log"
}

# Function to log section end
log_section_end() {
    local section_name=$1
    local timestamp=$(date "+%Y.%m.%d-%H.%M.%S")
    echo "=== ${section_name} completed at ${timestamp} ===" | tee -a "${LOG_DIR}/sections.log"
}

# Function to log script completion
log_completion() {
    local script_name=$1
    local log_file=$2
    local timestamp=$(date "+%Y.%m.%d-%H.%M.%S")
    echo "${script_name} execution completed successfully at ${timestamp}" | tee -a "${log_file}"
}
