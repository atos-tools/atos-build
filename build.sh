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
# This script will extract dependencies and build atos-utils along
# with its dependencies.
#

set -e

dir=`cd \`dirname $0\`; pwd`
srcroot=$dir
pwd=`pwd`

if [ "$srcroot" != `pwd` ]; then
    echo "error: build.sh must be run from the source trre : $srcroot" >&2
    exit 1
fi

# Extract dependencies
${DEPTOOLS:-./dependencies} extract

version=`cd $srcroot/atos-utils && config/get_version.sh`

cleanup() {
    local code=$?
    trap - INT TERM QUIT EXIT
    [ ! -d "atos-$version" ] || rm -rf atos-$version
    [ ! -f "atos-$version.tgz" -o $code = 0 ] || rm -f atos-$version.tgz
    rm -f *.tmp
}
trap cleanup INT TERM QUIT EXIT

uname=`uname -m`
case $uname in
    i386|i486|i586|i686) arch=i386
	;;
    x86_64) arch=$uname
	;;
    *) arch=$uname
	;;
esac


echo "Building atos version $version..."
[ "$NO_BUILD_DEPS" != "" ] || rm -rf devimage
rm -rf build distimage atos-$version atos-$version.tgz
mkdir -p build distimage devimage devimage/lib/python

OLD_PATH=$PATH
export PYTHONPATH=$pwd/devimage/lib/python
export PATH=$pwd/devimage/bin:$PATH

if [ "$NO_BUILD_DEPS" = "" -a "$NO_BUILD_PROOT" = "" ]; then
    echo
    echo "Building proot..."
    mkdir build/proot
    pushd build/proot >/dev/null
    make -f $srcroot/proot/src/GNUmakefile clean all install PREFIX=$pwd/devimage
    popd >/dev/null
fi

if [ "$NO_BUILD_DEPS" = "" -a "$NO_BUILD_QEMU" = "" ]; then
    echo
    echo "Building qemu-user-mode..."
    mkdir build/qemu
    pushd build/qemu >/dev/null
    $srcroot/qemu/configure --disable-system --target-list=i386-linux-user,x86_64-linux-user --prefix=$pwd/devimage
    make -j 4 all
    make install
    popd >/dev/null
fi

if [ "$NO_BUILD_DEPS" = "" -a "$NO_BUILD_JSONPATH" = "" ]; then
    echo
    echo "Building jsonpath..."
    pushd ./jsonpath >/dev/null
    ./setup.py install --prefix= --home=$pwd/devimage
    popd >/dev/null
fi

if [ "$NO_BUILD_DEPS" = "" -a "$NO_BUILD_JSONLIB" = "" ]; then
    echo
    echo "Building jsonlib..."
    pushd ./jsonlib >/dev/null
    ./setup.py install --prefix= --home=$pwd/devimage
    popd >/dev/null
fi

if [ "$NO_BUILD_DEPS" = "" -a "$NO_BUILD_ARGPARSE" = "" ]; then
    echo
    echo "Building argparse..."
    pushd ./argparse >/dev/null
    sed -i 's/from setuptools import setup.*/from distutils.core import setup/' setup.py
    python ./setup.py install --prefix= --home=$pwd/devimage
    popd >/dev/null
fi

if [ "$NO_BUILD_DEPS" = "" -a "$NO_BUILD_DOCUTILS" = "" ]; then
    echo
    echo "Building docutils..."
    pushd ./docutils >/dev/null
    python ./setup.py install --prefix= --home=$pwd/devimage
    popd >/dev/null
fi

if [ "$NO_BUILD_DEPS" = "" -a "$NO_BUILD_PROOT_ATOS_I386" = "" ]; then
    echo
    echo "Building proot atos for i386 on RHEL_5 distro..."
    mkdir build/proot-atos-i386
    pushd build/proot-atos-i386 >/dev/null
    $pwd/devimage/bin/proot -W -Q $pwd/devimage/bin/qemu-i386 -b $pwd/devimage -b $srcroot/proot $pwd/distros/rhlinux-i586-5el-rootfs /usr/bin/make -f $srcroot/proot/src/GNUmakefile clean all install ENABLE_ADDONS="cc_deps cc_opts" PREFIX=$pwd/devimage/i386 CFLAGS="-Wall -O2" STATIC_BUILD=1
    popd >/dev/null
fi

if [ "$NO_BUILD_DEPS" = "" -a "$NO_BUILD_PROOT_ATOS_X86_64" = "" ]; then
    echo
    echo "Building proot atos for x86_64 on RHEL_5 distro..."
    mkdir build/proot-atos-x86_64
    pushd build/proot-atos-x86_64 >/dev/null
    $pwd/devimage/bin/proot -W -Q $pwd/devimage/bin/qemu-x86_64 -b $pwd/devimage -b $srcroot/proot $pwd/distros/rhlinux-x86_64-5el-rootfs /usr/bin/make -f $srcroot/proot/src/GNUmakefile clean all install ENABLE_ADDONS="cc_deps cc_opts" PREFIX=$pwd/devimage/x86_64 CFLAGS="-Wall -O2" STATIC_BUILD=1
    popd >/dev/null
fi

echo
echo "Building atos..."
pushd ./atos-utils >/dev/null
make -j 4 PREFIX=$pwd/distimage all doc install install-doc install-shared
popd >/dev/null
mkdir -p distimage/lib/atos
cp -a devimage/lib/python distimage/lib/atos/
for arch in i386 x86_64; do
    cp -a devimage/$arch distimage/lib/atos/
done


echo
echo "Testing atos..."
unset PYTHONPATH
PATH=$OLD_PATH
pushd ./atos-utils >/dev/null
ROOT=$pwd/distimage make -C tests -j 4
popd >/dev/null

echo
echo "Building manifests..."
(cd distimage && find * -type f | xargs sha1sum 2>/dev/null) > RELEASE_MANIFEST.tmp
mv RELEASE_MANIFEST.tmp distimage/share/atos/RELEASE_MANIFEST
./dependencies dump_actual > distimage/share/atos/BUILD_MANIFEST

echo
echo "Packaging atos..."
cp -a distimage atos-$version
tar czf atos-$version.tgz atos-$version

echo
echo "ATOS package available in atos-$version.tgz."
echo "Completed."
