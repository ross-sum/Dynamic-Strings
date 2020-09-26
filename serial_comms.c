#include "serial_comms.h"
/*
#include <errno.h>
#include <fcntl.h> 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <termios.h>
#include <unistd.h>
*/

int set_interface_attribs(int fd, unsigned speed, unsigned databits, 
                          unsigned stopbits, int parity, int flow, int local)
{
   struct termios tty;

   if (tcgetattr(fd, &tty) < 0) {
      //printf("Set I/F Attr: Error from tcgetattr for %d: %s\n", fd, strerror(errno));
      return -(errno);
   }
   
   /* convert the baud rate */
   cfsetospeed(&tty, (speed_t)speed);
   cfsetispeed(&tty, (speed_t)speed);

   /* determine modem controls */
   if (local == 0) {
      tty.c_cflag |= CREAD;
   } 
   else {
      tty.c_cflag |= (CLOCAL | CREAD);    /* ignore modem controls */
   }
   tty.c_cflag &= ~CSIZE;
   tty.c_cflag |= databits;
   /* convert parity into a bit pattern */
   if (parity == 512) { // odd parity
      tty.c_cflag |= (PARENB | PARODD);
   } 
   else if (parity == 256) { // even parity
      tty.c_cflag |= PARENB;
   } 
   else {  // no parity
      tty.c_cflag &= ~PARENB;
   }
   /* interpret the number of stop bits */
   if (stopbits == 0) {    // 1 stop bit
      tty.c_cflag &= ~CSTOPB;
   } 
   else {               // 2 stop bits
      tty.c_cflag |= CSTOPB;
   }
   /* interpret the flow control required */
   if (flow == 0) {
      tty.c_cflag &= ~CRTSCTS;    /* no hardware flow control */
   } 
   else if (flow == 1) {
      tty.c_cflag |= CRTSCTS;    /* hardware flow control */
   } 
   else {  // flow == 2
      tty.c_cflag |= IXON;    /* XOn/XOff flow control */
   }
   
   /* setup for non-canonical mode */
   tty.c_iflag &= ~(IGNBRK | BRKINT | PARMRK | ISTRIP | INLCR | IGNCR | ICRNL | IXON);
   tty.c_lflag &= ~(ECHO | ECHONL | ICANON | ISIG | IEXTEN);
   tty.c_oflag &= ~OPOST;

   /* fetch bytes as they become available */
   tty.c_cc[VMIN] = 1;
   tty.c_cc[VTIME] = 1;

   if (tcsetattr(fd, TCSANOW, &tty) != 0) {
      //printf("Error from tcsetattr: %s\n", strerror(errno));
      return -(errno);
   } 
   return 0;
}

int set_blocking_and_timeout(int fd, int mcount, int timeout)
{
   struct termios tty;

   if (tcgetattr(fd, &tty) < 0) {
      //printf("Blocking: Error tcgetattr: %s\n", strerror(errno));
      return -(errno);
   }

   tty.c_cc[VMIN] = mcount ? 1 : 0;  /* minimum characters to receive */
   tty.c_cc[VTIME] = timeout;        /* (timeout * 0.1) seconds timer */

   if (tcsetattr(fd, TCSANOW, &tty) < 0) {
      //printf("Error tcsetattr: %s\n", strerror(errno));
      return -(errno);
   }
   return 0;
}

int set_mincount(int fd, int mcount)
{
   return set_blocking_and_timeout(fd, mcount, 5);
}

/* e.g.:
    char *portname = "/dev/ttyUSB0"; */

int Open(int fd, char *portname)
{
   fd = open(portname, O_RDWR | O_NOCTTY | O_SYNC);
   if (fd < 0) {
      // printf("Error opening %s: %s\n", portname, strerror(errno));
      return -errno;
   }
   return fd;
}

int Close(int fd)
{
   int res;
   res = close(fd);
   if (res < 0) {
      // printf("Error opening %s: %s\n", portname, strerror(errno));
      return -errno;
   }
   return 0;
}

/* Write the buffer, data out the device. len is the number of
   valid characters in the buffer to write. */
int Write(int fd, char *data, int len)
{
   int wlen;  // total number of bytes actually written
   
   wlen = write(fd, data, len);
   if (wlen != len) {
      //printf("Error from write: %d, %d\n", wlen, errno);
      return -wlen;
   }
   return 0;
}

// data is something like: unsigned char data[80];
// returns the number of bytes read.  If there is no data yet, then
// 0 is returned.
int Read(int fd, char *data, int length)
{
   int rdlen;
   rdlen = read(fd, data, length -1);  // sizeof(data) - 1);
   if ((rdlen > 0 ) && (length > 1)) {
      data[rdlen] = 0;  // ensure null terminated if possible
   }
   // If rdlen < 0 then error.  If == 0 then no data yet (time-out).
   return rdlen;
}
