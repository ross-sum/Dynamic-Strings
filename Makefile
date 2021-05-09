#########################################################
#                Make file for dStrings                 #
#########################################################

# The following flag defines if static or dynamic library
# for serial_comms.  Set a value for true, leave empty for
# false.
DYNAMIC = true
# Use standard variables to define compile and link flags
#
TN=test/test_dstr_io
SC=dstrings
SOURCE=.
ACC=gprbuild
TS=$(TN).gpr
SS=$(SC).gpr
HOST_TYPE := $(shell uname -m)
OS_TYPE := $(shell uname -o)
ifeq ($(HOST_TYPE),amd)
        TARGET=sparc
else ifeq ($(HOST_TYPE),x86_64)
ifeq ($(OS_TYPE),Cygwin)
        TARGET=win
else
        TARGET=amd64
endif
else ifeq ($(HOST_TYPE),x86)
        TARGET=x86
else ifeq ($(HOST_TYPE),i686)
        TARGET=x86
else ifeq ($(HOST_TYPE),arm)
        TARGET=pi
else ifeq ($(HOST_TYPE),armv7l)
        TARGET=pi
endif
TD=obj_$(TARGET)
BIN=/usr/local/bin
ETC=/usr/local/etc
LIB=/usr/local/lib
ifeq ("$1.",".")
	FLAGS=-Xhware=$(TARGET)
else
	FLAGS=-Xhware=$(TARGET) $1
endif
ifeq ($(OS_TYPE),Cygwin)
	FLAGS+=-cargs -I/usr/include/sys
endif

test_dstr_io:
	echo "Building for $(HOST_TYPE) at $(TD):"
	$(ACC) -P $(TS) $(FLAGS)

serial_comms:
	$(ACC) -P $(SS) $(FLAGS)

# Define the target "all"
all:
	test_dstr_io
	serial_comms

         # Clean up to force the next compilation to be everything
clean:
	rm -f $(TD)/*.o $(TD)/*.ali $(TD)/$(TN) $(TD)/*.a

dist-clean: distclean

distclean: clean

