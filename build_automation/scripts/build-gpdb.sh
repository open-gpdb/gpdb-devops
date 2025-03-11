#!/bin/bash
# --------------------------------------------------------------------
#
# Script: build-gpdb.sh
# Description: Builds Greenplum from source code and installs it.
#
# --------------------------------------------------------------------

make -j8 && make -j8 install