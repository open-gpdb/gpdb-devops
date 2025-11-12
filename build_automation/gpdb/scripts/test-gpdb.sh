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
# Script: test-gpdb.sh
# Description: Executes Greenplum test suite using specified
#             make target.  Supports different test types through make
#             target configuration.  Sources Greenplum environment
#             before running tests.
#
# Required Environment Variables:
#   MAKE_TARGET    - Make target to execute (e.g., installcheck-world)
#   MAKE_DIRECTORY - Directory where make command will be executed
#   MAKE_NAME      - Name of the make operation (for logging)
#
# Optional Environment Variables:
#   LOG_DIR - Directory for logs (defaults to build-logs)
#   PGOPTIONS - PostgreSQL server options
#
# Prerequisites:
#   - Greenplum must be installed (/opt/greenplum-db-6)
#   - create-gpdb-demo-cluster.sh must be run first
#
# Usage:
#   Export required variables:
#     export MAKE_TARGET=installcheck-world
#     export MAKE_DIRECTORY="/path/to/make/dir"
#     export MAKE_NAME="Install Check"
#   Then run:
#     ./test-gpdb.sh
#
# Exit Codes:
#   0 - All tests passed successfully
#   1 - Environment setup failed (missing required variables, environment sourcing failed)
#   2 - Test execution failed (make command returned error)
#
# --------------------------------------------------------------------

set -euo pipefail

export BUILD_DESTINATION="/opt/greenplum-db-6"

# Source common utilities
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/gpdb-utils.sh"

# Define log directory and files
export LOG_DIR="build-logs"
TEST_LOG="${LOG_DIR}/test.log"

# Initialize environment
init_environment "Greenplum Test Script" "${TEST_LOG}" "/opt/greenplum-db-6"

# Source Greenplum environment
log_section "Environment Setup"
source_greenplum_env || exit 1
log_section_end "Environment Setup"

echo "MAKE_TARGET: ${MAKE_TARGET}"
echo "MAKE_DIRECTORY: ${MAKE_DIRECTORY}"
echo "PGOPTIONS: ${PGOPTIONS}"

# Execute specified target
log_section "Install Check"
execute_cmd make install -C src/test/regress || exit 2
execute_cmd make install -C src/test/modules || exit 2
execute_cmd make ${MAKE_TARGET} ${MAKE_DIRECTORY} || exit 2
log_section_end "Install Check"

# Log completion
log_completion "Greenplum Test Script" "${TEST_LOG}"
exit 0