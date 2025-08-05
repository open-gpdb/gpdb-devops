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
# Script: vendor.sh
# Description: Copies vendor libraries to the build destination.
#             Performs the following steps:
#             1. Copies libsigar.so from /usr/local/lib to build lib directory
#             2. Copies libxerces* libraries from /usr/local/lib to build lib directory
#
# Required Environment Variables:
#   BUILD_DESTINATION - Directory to store build data
#
# Optional Environment Variables:
#   LOG_DIR - Directory for logs (defaults to ${SRC_DIR}/build-logs)
#
# Usage:
#   Export required variables:
#     export BUILD_DESTINATION=/opt/greenplum-db-6
#   Then run:
#     ./vendor.sh
#
# Prerequisites:
#   - /usr/local/lib must contain required libraries
#   - BUILD_DESTINATION/lib must exist and be writable
#
# Exit Codes:
#   0 - Vendor libraries copied successfully
#   1 - Environment setup failed
#   2 - Library copy failed
#
# --------------------------------------------------------------------

set -euo pipefail

# Source common utilities
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/gpdb-utils.sh"

# Define log directory and files
export LOG_DIR="${SRC_DIR:-$(pwd)}/build-logs"
VENDOR_LOG="${LOG_DIR}/vendor.log"

# Initialize environment
init_environment "Vendor Libraries Script" "${VENDOR_LOG}" "${BUILD_DESTINATION}"

# Copy vendor libraries
log_section "Copying Vendor Libraries"
execute_cmd cp /usr/local/lib/libsigar.so ${BUILD_DESTINATION}/lib || exit 2
execute_cmd cp /usr/local/lib/libxerces* ${BUILD_DESTINATION}/lib || exit 2
log_section_end "Copying Vendor Libraries"

# Log completion
log_completion "Vendor Libraries Script" "${VENDOR_LOG}"
exit 0