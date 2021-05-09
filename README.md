# Dynamic Strings
$Date:$

This project contains the dStrings tool.  Its origin dates back to Ada 83, which did not have such a concept.  Since then, this library suite has been updated to use the in-built dynamic strings package as well as to extend it out to handle input/output to serial devices (mostly USB devices).

For windows, 
1. you will need to copy termios.h in (assuming Cygwin is installed) viz:
	cp /usr/include/sys/termios.h /cygdrive/c/GNAT/2020/x86_64-pc-mingw32/include/`
2. you will need to edit (assuming Cygwin is installed), 
	/cygdrive/c/GNAT/2020/x86_64-pc-mingw32/include/fcntl.h
then append the folowing to the bottom:
~~~
#ifndef O_NOCTTY
# define O_NOCTTY          0400 /* Not fcntl.  */
#endif
#ifndef O_SYNC
# define O_SYNC        04010000
#endif
~~~
