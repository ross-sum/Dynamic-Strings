pragma Ada_2005;
pragma Style_Checks (Off);

with Interfaces.C; use Interfaces.C;
with Interfaces.C.Strings;

package serial_comms_h is

   function C_set_interface_attribs
     (fd       : int;
      speed    : unsigned;
      databits : unsigned;
      stopbits : unsigned;
      parity   : int;
      flow     : int;
      local    : int) return int;  -- ./serial_comms.h:10
   pragma Import (C, C_set_interface_attribs, "set_interface_attribs");

  -- Set Blocking
  -- should_block = 0 for non-blocking, VMIN time (i.e. minimum number of
  --   characters to wait for) for blocking. For time-out, this is fixed at
  --   0.5 seconds.
  --   int set_blocking (int fd, int should_block);
  --   Alternative, maybe better, version, where mcount == should_block.  

   function C_set_mincount (fd : int; mcount : int) return int;  -- ./serial_comms.h:18
   pragma Import (C, C_set_mincount, "set_mincount");

  -- The following sets both the blocking and time-out values  
   function C_set_blocking_and_timeout
     (fd : int;
      mcount : int;
      timeout : int) return int;  -- ./serial_comms.h:20
   pragma Import (C, C_set_blocking_and_timeout, "set_blocking_and_timeout");

  -- Open the file, where port name is defined as something like:
  --    char *portname = "/dev/ttyUSB0";  

   function C_Open (fd : int; portname : Interfaces.C.Strings.chars_ptr) return int;  -- ./serial_comms.h:24
   pragma Import (C, C_Open, "Open");

  -- Close the file  
   function C_Close (fd : int) return int;  -- ./serial_comms.h:27
   pragma Import (C, C_Close, "Close");

  -- Write the buffer, data out the device. len is the number of
  --   valid characters in the buffer to write.  

   function C_Write
     (fd : int;
      data : Interfaces.C.Strings.chars_ptr;
      len : int) return int;  -- ./serial_comms.h:31
   pragma Import (C, C_Write, "Write");

  -- data is something like: unsigned char data[80];
  -- returns the number of bytes read.  If there is no data yet, then
  -- 0 is returned.
   function C_Read (fd : int; data : Interfaces.C.Strings.chars_ptr; 
                    length : int) return int;  -- ./serial_comms.h:36
   pragma Import (C, C_Read, "Read");
   
   -- Assuming the error has just occurred, turns the error number into
   -- a string and returns it in 'data'.
   procedure C_Errno_Message(err : int; 
                             data : in out Interfaces.C.Strings.chars_ptr;
                              len  : out int);
   pragma Import (C, C_Errno_Message, "Errno_Message");

end serial_comms_h;
