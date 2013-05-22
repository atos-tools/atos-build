#!/usr/bin/env bash
#
# Copyright (C) STMicroelectronics Ltd. 2012
#
# This file is part of ATOS.
#
# ATOS is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License v2.0
# as published by the Free Software Foundation
#
# ATOS is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# v2.0 along with ATOS. If not, see <http://www.gnu.org/licenses/>.
#
#
# Usage: ./build.sh
#
# This script will atos-utils along with its dependencies.
# One should have run ./dependencies extract before running it.
#

set -e

dir=`cd \`dirname $0\`; pwd`
if [ "$dir" != `pwd` ]; then
    echo "error: build.sh must be run from the source tree : $srcroot" >&2
    exit 1
fi

. ./setenv.sh
exec make -j 4 release
