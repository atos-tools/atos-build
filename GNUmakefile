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
# Makefile for full ATOS tools build
#
# Usage:
#    cd atos-build
#    source ./setenv.sh
#    make all
#
srcdir=$(abspath $(dir $(MAKEFILE_LIST)))
currentdir=$(abspath .)
ifneq ($(srcdir),$(currentdir))
$(error "make must be run from the source directory: $(srcdir)")
endif

installdir=$(currentdir)/devimage

PREFIX=?/usr/local

SUBDIRS=proot qemu jsonpath jsonlib argparse docutils pworker requests atos-utils
ATOS_UTILS_DEPS=proot qemu jsonpath jsonlib argparse docutils pworker requests
JSONLIB_DEPS=jsonpath

.PHONY: all $(addprefix all-, $(SUBDIRS)) dev $(addprefix dev-, $(SUBDIRS)) clean $(addprefix clean-, $(SUBDIRS)) distclean $(addprefix distclean-, $(SUBDIRS))

all: $(addprefix dev-, $(SUBDIRS))

all-atos-utils: $(addprefix dev-, $(ATOS_UTILS_DEPS))

all-jsonlib: $(addprefix dev-, $(JSONLIB_DEPS))

all-atos-utils:
	$(MAKE) -C $(srcdir)/atos-utils all doc

clean-atos-utils distclean-atos-utils: %-atos-utils:
	$(MAKE) -C $(srcdir)/atos-utils $*

dev-atos-utils: all-atos-utils
	$(MAKE) -C $(srcdir)/atos-utils install install-doc install-shared PREFIX=$(installdir)

all-proot clean-proot distclean-proot: %-proot:
	$(MAKE) -C $(srcdir)/proot/src $* ENABLE_ADDONS="cc_deps cc_opts" CFLAGS="-Wall -O2" STATIC_BUILD=1

dev-proot: all-proot
	$(MAKE) -C $(srcdir)/proot/src install PREFIX=$(installdir)

configure-qemu: %-qemu:
	cd $(srcdir)/qemu && ./configure --target-list=i386-linux-user,x86_64-linux-user,sh4-linux-user,arm-linux-user --enable-tcg-plugin --prefix=$(installdir)

all-qemu clean-qemu distclean-qemu: %-qemu:
	$(MAKE) -C $(srcdir)/qemu $*

all-qemu: configure-qemu

dev-qemu: all-qemu
	$(MAKE) -C $(srcdir)/qemu install

all-jsonpath all-jsonlib all-argparse all-docutils all-pworker all-requests: all-%:
	cd $(srcdir)/$* && \
	sed -i 's/from setuptools import setup.*/from distutils.core import setup/' setup.py && \
	python setup.py build

dev-jsonpath dev-jsonlib dev-argparse dev-docutils dev-pworker dev-requests: dev-%: all-%
	cd $(srcdir)/$* && python setup.py install --prefix= --home=$(installdir)

clean: $(addprefix clean-, $(SUBDIRS))

clean-jsonpath clean-jsonlib clean-argparse clean-docutils clean-pworker clean-requests: clean-%:
	cd $(srcdir)/$* && python setup.py clean

distclean-jsonpath distclean-jsonlib distclean-argparse distclean-docutils distclean-pworker distclean-requests: distclean-%: clean-%

distclean: $(addprefix distclean-, $(SUBDIRS))
	rm -rf devimage

