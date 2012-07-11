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

set -e
dir=`cd \`dirname $0\`; pwd`
srcroot=`dirname $dir`

pwd=$PWD
uname=`uname -m`
case $uname in
    i386|i486|i586|i686) arch=i386
	;;
    x86_64) arch=$uname
	;;
    *) arch=$uname
	;;
esac

version=`cat $dir/VERSION`

atosfiles=/home/compwork/projects/atos/

echo "Building atos version $version..."
rm -rf build distimage distro atos-$version
mkdir build distimage distro

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

if [ "$NO_BUILD_DEPS" = "" -a "$NO_BUILD_PYGRAPH" = "" ]; then
    echo
    echo "Building pygraph..."
    mkdir build/pygraph
    pushd build/pygraph >/dev/null
    tar xzf $atosfiles/python-graph-core-1.8.1.tar.gz
    cd ./python-graph-core-1.8.1
    ./setup.py install --root=$pwd/distimage --install-lib=lib/atos/python
    popd >/dev/null
fi

if [ "$NO_BUILD_DEPS" = "" -a "$NO_BUILD_JSONPATH" = "" ]; then
    echo
    echo "Building jsonpath..."
    mkdir build/jsonpath
    pushd build/jsonpath >/dev/null
    tar xzf $atosfiles/jsonpath-0.53.tar.gz
    cd ./jsonpath-0.53
    ./setup.py install --root=$pwd/distimage --install-lib=lib/atos/python
    popd >/dev/null
fi

if [ "$NO_BUILD_DEPS" = "" -a "$NO_BUILD_JSONLIB" = "" ]; then
    echo
    echo "Building jsonlib..."
    mkdir build/jsonlib
    pushd build/jsonlib >/dev/null
    tar xzf $atosfiles/jsonlib-0.1.tar.gz
    cd ./jsonlib-0.1
    ./setup.py install --root=$pwd/distimage --install-lib=lib/atos/python
    popd >/dev/null
fi

if [ "$NO_BUILD_DEPS" = "" -a "$NO_BUILD_DISTRO_I386" = "" ]; then
    echo
    echo "Creating rhlinux-i586-5el distro in distro/rhlinux-i586-5el-rootfs..."
    mkdir distro/rhlinux-i586-5el-rootfs
    tar xzf $atosfiles/opensuse.org.repo.RHEL_5.i586.tgz -C distro/rhlinux-i586-5el-rootfs 2>/dev/null || true
fi

if [ "$NO_BUILD_DEPS" = "" -a "$NO_BUILD_DISTRO_X86_64" = "" ]; then
    echo
    echo "Creating rhlinux-x86_64-5el distro in distro/rhlinux-rhlinux-x86_64-5el-rootfs..."
    mkdir distro/rhlinux-x86_64-5el-rootfs
    tar xzf $atosfiles/opensuse.org.repo.RHEL_5.x86_64.tgz -C distro/rhlinux-x86_64-5el-rootfs 2>/dev/null || true
fi

if [ "$NO_BUILD_DEPS" = "" -a "$NO_BUILD_PROOT_ATOS_I386" = "" ]; then
    echo
    echo "Building proot atos for i386 on RHEL_5 distro..."
    mkdir build/proot-atos-i386
    pushd build/proot-atos-i386 >/dev/null
    $pwd/devimage/bin/proot -W -Q $pwd/devimage/bin/qemu-i386 -b $pwd/devimage -b $srcroot/proot $pwd/distro/rhlinux-i586-5el-rootfs /usr/bin/make -f $srcroot/proot/src/GNUmakefile clean all install ENABLE_ADDONS="cc_deps cc_opts" PREFIX=$pwd/devimage/i386 CFLAGS="-Wall -O2"
    popd >/dev/null
fi

if [ "$NO_BUILD_DEPS" = "" -a "$NO_BUILD_PROOT_ATOS_X86_64" = "" ]; then
    echo
    echo "Building proot atos for x86_64 on RHEL_5 distro..."
    mkdir build/proot-atos-x86_64
    pushd build/proot-atos-x86_64 >/dev/null
    $pwd/devimage/bin/proot -W -Q $pwd/devimage/bin/qemu-x86_64 -b $pwd/devimage -b $srcroot/proot $pwd/distro/rhlinux-x86_64-5el-rootfs /usr/bin/make -f $srcroot/proot/src/GNUmakefile clean all install ENABLE_ADDONS="cc_deps cc_opts" PREFIX=$pwd/devimage/x86_64 CFLAGS="-Wall -O2"
    popd >/dev/null
fi

echo
echo "Building atos..."
pushd $srcroot/atos-utils >/dev/null
make PREFIX=$pwd/distimage all install
popd >/dev/null
for arch in i386 x86_64; do
    mkdir -p distimage/lib/atos/$arch
    cp -a devimage/$arch/bin/proot distimage/lib/atos/$arch
done

echo
echo "Testing atos..."
pushd $srcroot/atos-utils >/dev/null
ROOT=$pwd/distimage make tests
popd >/dev/null

echo
echo "Packaging atos..."
cp -a distimage atos-$version
tar czf atos-$version.tgz atos-$version

echo
echo "ATOS package available in atos-$version.tgz."
echo "Completed."
