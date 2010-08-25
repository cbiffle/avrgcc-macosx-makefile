#Makefile that will build a specified version of avr-gcc,g++ with all it's helper files
#Copyright (C) 2010 Rick Anderson
#This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
#
#This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#
# Assumptions: curl is installed
# You are running Mac OS X with Xcode ver=? Installed


unexport LD_LIBRARY_PATH

#setup defaults values
MKDIR = mkdir -p
BUILD_DIR = build
LIB_DIR = /usr/local/test/avr1
INSTALL_DIR = /usr/local/test/avr1


#Setup versions of the required software
#gcc-core
AVRGCC_VER = 4.5.1
#gcc-g++, should normally be the same as AVRGCC_VER
#AVRGXX_VER = 4.5.1
AVRLIBC_VER = 1.7.0
BINUTILS_VER = 2.20.1
AVRDUDE_VER = 5.4
GDB_VER = 7.1
GMP_VER = 4.3.2
MPC_VER = 0.8.2
MPFR_VER = 2.3.1
LIBTOOL_VER = 2.2.10

#Doesn't include getsources, and unpacksource, need a rule for that.
all: build-gmp install-gmp build-mpfr install-mpfr build-mpc install-mpc build-binutils install-binutils build-libtool install-libtool build-linkprereqs build-avrgccgxx install-avrgccgxx build-avrlibc install-avrlibc

setup:
	$(MKDIR) $(CURDIR)/src
	$(MKDIR) $(CURDIR)/build

getsources: setup
	$(shell cd $(CURDIR)/src; \
	curl -O ftp://ftp.gmplib.org/pub/gmp-$(GMP_VER)/gmp-$(GMP_VER).tar.bz2 ;\
	curl -O http://www.mpfr.org/mpfr-$(MPFR_VER)/mpfr-$(MPFR_VER).tar.gz ;\
	curl -O http://www.multiprecision.org/mpc/download/mpc-$(MPC_VER).tar.gz ; \
	curl -O ftp://ftp.gnu.org/gnu/binutils/binutils-$(BINUTILS_VER).tar.gz ; \
	curl -O http://ftp.gnu.org/gnu/libtool/libtool-$(LIBTOOL_VER).tar.gz ; \
	curl -O ftp://ftp.gnu.org/gnu/gcc/gcc-$(AVRGCC_VER)/gcc-g++-$(AVRGCC_VER).tar.gz ; \
	curl -O ftp://ftp.gnu.org/gnu/gcc/gcc-$(AVRGCC_VER)/gcc-core-$(AVRGCC_VER).tar.gz ; \
	curl -O http://nongnu.askapache.com/avr-libc/avr-libc-$(AVRLIBC_VER).tar.bz2 ; \
	curl -O http://ftp.gnu.org/gnu/gdb/gdb-$(GDB_VER).tar.gz ; \
	curl -O http://mirror.its.uidaho.edu/pub/savannah/avrdude/avrdude-$(AVRDUDE_VER).tar.gz ;)
	
unpacksources:
	tar xvjf $(CURDIR)/src/gmp-$(GMP_VER).tar.bz2  -C $(CURDIR)/build
	tar xvzf $(CURDIR)/src/mpc-$(MPC_VER).tar.gz  -C $(CURDIR)/build
	tar xvzf $(CURDIR)/src/mpfr-$(MPFR_VER).tar.gz  -C $(CURDIR)/build
	tar xvzf $(CURDIR)/src/binutils-$(BINUTILS_VER).tar.gz  -C $(CURDIR)/build
	tar xvzf $(CURDIR)/src/libtool-$(LIBTOOL_VER).tar.gz -C $(CURDIR)/build
	tar xvzf $(CURDIR)/src/gcc-core-$(AVRGCC_VER).tar.gz  -C $(CURDIR)/build
	tar xvzf $(CURDIR)/src/gcc-g++-$(AVRGCC_VER).tar.gz  -C $(CURDIR)/build
	tar xvjf $(CURDIR)/src/avr-libc-$(AVRLIBC_VER).tar.bz2  -C $(CURDIR)/build
	tar xvzf $(CURDIR)/src/avrdude-$(AVRDUDE_VER).tar.gz -C $(CURDIR)/build
	tar xvzf $(CURDIR)/src/gdb-$(GDB_VER).tar.gz -C $(CURDIR)/build

	
#build-prereqs: build-gmp build-mpfr build-mpc
#Because these prereq libraries are built as part of the gcc source, that don't need to be installed after being built
build-gmp:
	$(MKDIR) build/gmp-$(GMP_VER)/tmp
	cd build/gmp-$(GMP_VER)/tmp &&  ../configure --prefix=$(LIB_DIR)
	cd build/gmp-$(GMP_VER)/tmp && time $(MAKE)

check-gmp:
	cd build/gmp-$(GMP_VER)/tmp && $(MAKE) check

install-gmp:
	cd build/gmp-$(GMP_VER)/tmp && sudo $(MAKE) install

build-mpfr:
	#mpfr
	$(MKDIR) build/mpfr-$(MPFR_VER)/tmp
	cd  build/mpfr-$(MPFR_VER)/tmp && ../configure --prefix=$(LIB_DIR) --with-gmp-build=../../gmp-$(GMP_VER)/tmp
	cd  build/mpfr-$(MPFR_VER)/tmp && time $(MAKE)

check-mpfr:
	cd  build/mpfr-$(MPFR_VER)/tmp && $(MAKE)  check

install-mpfr:
	cd  build/mpfr-$(MPFR_VER)/tmp && sudo $(MAKE) install

build-mpc:	
	#mpc
	$(MKDIR) build/mpc-$(MPC_VER)/tmp 
	cd build/mpc-$(MPC_VER)/tmp  && ../configure --prefix=$(INSTALL_DIR) --with-gmp=$(LIB_DIR) --with-mpfr=$(LIB_DIR)
	cd build/mpc-$(MPC_VER)/tmp  && time $(MAKE)

install-mpc:
	cd build/mpc-$(MPC_VER)/tmp  && sudo $(MAKE)  install;
	
build-binutils:
	$(MKDIR) build/binutils-$(BINUTILS_VER)/tmp
	cd build/binutils-$(BINUTILS_VER)/tmp && ../configure --target=avr --prefix=$(INSTALL_DIR) --disable-nsl --enable-install-libbfd --disable-werror
	cd build/binutils-$(BINUTILS_VER)/tmp && time $(MAKE)

install-binutils:
	cd build/binutils-$(BINUTILS_VER)/tmp && sudo $(MAKE) install

build-libtool:
	$(MKDIR) build/libtool-$(LIBTOOL_VER)/tmp
	cd build/libtool-$(LIBTOOL_VER)/tmp && ../configure --target=avr --prefix=$(INSTALL_DIR) --disable-nsl --enable-install-libbfd --disable-werror
	cd build/libtool-$(LIBTOOL_VER)/tmp && time $(MAKE)

install-libtool:
	cd build/libtool-$(LIBTOOL_VER)/tmp && sudo $(MAKE) install



build-linkprereqs:
	#Build the libraries then symlink to tmp build directories for easier compilationg, because reference the libraries is not working yet. 
	$(shell cd build/gcc-$(AVRGCC_VER);\
	ln -s ../mpfr-$(MPFR_VER) mpfr;\
	ln -s ../mpc-$(MPC_VER)/ mpc;\
	ln -s ../gmp-$(GMP_VER)/ gmp;\)

build-avrgccgxx:
	$(MKDIR) build/gcc-$(AVRGCC_VER)/tmp
	#my custom library location is not working 
	#../configure --target=avr --prefix=/usr/local/test/avr --disable-nsl --enable-languages=c,c++ --disable-libssp -with-gmp=/usr/local/test/lib/lib --with-mpfr=/usr/local/test/lib/lib  --with-mpc=/usr/local/test/lib/lib -isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5 -no_compact_linkedit 
	cd build/gcc-$(AVRGCC_VER)/tmp && ../configure --target=avr --prefix=$(INSTALL_DIR) --disable-nsl --enable-languages=c,c++ --disable-libssp --disable-dependency-tracking --disable-werror --with-dwarf2 --enable-thread=single 
	cd build/gcc-$(AVRGCC_VER)/tmp && time $(MAKE)

install-avrgccgxx:
	cd build/gcc-$(AVRGCC_VER)/tmp && sudo $(MAKE) install
	$(INSTALL_DIR)/bin/avr-gcc --version
	
build-avrlibc:
	$(MKDIR) build/avr-libc-$(AVRLIBC_VER)/tmp
	cd build/avr-libc-$(AVRLIBC_VER)/tmp && ../configure --build=`../config.guess` --host=avr --prefix=$(INSTALL_DIR)
	cd build/avr-libc-$(AVRLIBC_VER)/tmp && time $(MAKE)

install-avrlibc:
	cd build/avr-libc-$(AVRLIBC_VER)/tmp && sudo $(MAKE) install

build-avrdude:
	$(MKDIR) build/avrdude-$(AVRDUDE_VER)/tmp
	cd  build/avrdude-$(AVRDUDE_VER)/tmp && ../configure --prefix=$(INSTALL_DIR)
	cd  build/avrdude-$(AVRDUDE_VER)/tmp && time $(MAKE)

install-avrdude:
	cd  build/avrdude-$(AVRDUDE_VER)/tmp && sudo $(MAKE) install

build-avrgdb:
	$(MKDIR) build/gdb-$(GDB_VER)/tmp
	cd build/gdb-$(GDB_VER)/tmp  && ../configure --target=avr --prefix=$(INSTALL_DIR) --disable-werror
	cd build/gdb-$(GDB_VER)/tmp  && time $(MAKE)

install-avrgdb:
	cd build/gdb-$(GDB_VER)/tmp  && sudo $(MAKE) install


clean:
	rm -rf src
	rm -rf build
