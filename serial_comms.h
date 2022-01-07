#include <errno.h>
#include <fcntl.h> 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <termios.h>
#include <unistd.h>


int set_interface_attribs(int fd, unsigned speed, unsigned databits, 
                          unsigned stopbits, int parity, int flow, int local);

/* should_block = 0 for non-blocking, VMIN time (i.e. minimum number of
   characters to wait for) for blocking. For time-out, this is fixed at
   0.5 seconds.
   int set_blocking (int fd, int should_block);
   Alternative, maybe better, version, where mcount == should_block. */
int set_mincount(int fd, int mcount);
/* The following sets both the blocking and time-out values */
int set_blocking_and_timeout(int fd, int mcount, int timeout);

/* Open the file, where port name is defined as something like:
    char *portname = "/dev/ttyUSB0"; */
int Open(int fd, char *portname);
/* And as read only */
int Open_RO(int fd, char *portname);

  /* tcgetattr gets the current terminal information and stores it in t.
     If cmd is 1, the local input flag in t is set to non-blocking input. 
     Otherwise it is reset. Then tcsetattr changes standard input to t. */
void stdin_set(int cmd);

/* Close the file */
int Close(int fd);
   
/* Write the buffer, data out the device. len is the number of
   valid characters in the buffer to write. */
int Write(int fd, char *data, int len);

// data is something like: unsigned char data[80];
// returns the number of bytes read.  If there is no data yet, then
// 0 is returned.
int Read(int fd, char *data, int length);

void Errno_Message(int err, char *data, int len);
// Assuming the error has just occurred, turns the error number into
// a string and returns it in 'data'.
