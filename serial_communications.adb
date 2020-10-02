------------------------------------------------------------------------------
--                                                                          --
--                         GNAT COMPILER COMPONENTS                         --
--                                                                          --
--                 S E R I A L _ C O M M U N I C A T I O N S                --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--                    Copyright (C) 2007-2015, AdaCore                      --
--                    Copyright (C) 2020, Hyper Quantum Pty Ltd             --
--                                                                          --
-- This  library  was modelled on  the  GNAT.Serial_Communications  library --
-- Specification.  It is an interface to C library function calls.  It  was --
-- built because the GNAT library was not available on Raspberry Pi.        --
--                                                                          --
-- The licence for this follows that for GNAT, outlined below.              --
--                                                                          --
-- GNAT is free software;  you can  redistribute it  and/or modify it under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  GNAT is distributed in the hope that it will be useful, but WITH- --
-- OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE.                                     --
--                                                                          --
-- As a special exception under Section 7 of GPL version 3, you are granted --
-- additional permissions described in the GCC Runtime Library Exception,   --
-- version 3.1, as published by the Free Software Foundation.               --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
-- GNAT was originally developed  by the GNAT team at  New York University. --
-- Extensive contributions were provided by Ada Core Technologies Inc.      --
--                                                                          --
------------------------------------------------------------------------------

--  This is the Hyper Quantum implementation of this package

with OS_Constants;
with serial_comms_h;          use serial_comms_h;
with Interfaces.C.Strings;    use Interfaces.C.Strings;
-- with Error_Log, String_Conversions;  use String_Conversions;
with Ada.Text_io;
with Ada.Exceptions; --, Ada.Unchecked_Deallocation;

package body Serial_Communications is
   use Interfaces.C;

   package OSC renames OS_Constants;

   use type Interfaces.C.unsigned;

   subtype unsigned is Interfaces.C.unsigned;
   subtype char is Interfaces.C.char;
   subtype unsigned_char is Interfaces.C.unsigned_char;
   
   C_Data_Rate : constant array (Data_Rate) of unsigned :=
                   (B75     => OSC.B75,
                    B110    => OSC.B110,
                    B150    => OSC.B150,
                    B300    => OSC.B300,
                    B600    => OSC.B600,
                    B1200   => OSC.B1200,
                    B2400   => OSC.B2400,
                    B4800   => OSC.B4800,
                    B9600   => OSC.B9600,
                    B19200  => OSC.B19200,
                    B38400  => OSC.B38400,
                    B57600  => OSC.B57600,
                    B115200 => OSC.B115200);

   C_Bits      : constant array (Data_Bits) of unsigned :=
                   (CS7 => OSC.CS7, CS8 => OSC.CS8);

   C_Stop_Bits : constant array (Stop_Bits_Number) of unsigned :=
                   (One => 0, Two => OSC.CSTOPB);

   C_Parity    : constant array (Parity_Check) of C.int :=
                   (None => 0,
                    Odd  => OSC.PARODD,
                    Even => OSC.PARENB);

   Errno : constant integer := 0;  -- FIX THIS! --
   procedure Raise_Error (Message : String; Error : Integer := Errno);
   pragma No_Return (Raise_Error);

--    ----------
--    -- Name --
--    ----------
-- 
   function Name (Number : Positive; of_type : port_type := usb) 
   return Port_Name is
      N     : constant Natural := Number - 1;
      N_Img : constant String  := Natural'Image (N);
      C_Img : constant String  := Natural'Image (Number);
   begin
      if of_type /= com then
         return Port_Name (dStrings.Value(of_string => prefix_array(of_type)) &
                        N_Img (N_Img'First + 1 .. N_Img'Last));
      else  -- Windows COM port name request
         return Port_Name (dStrings.Value(of_string => prefix_array(of_type)) &
                        C_Img (C_Img'First + 1 .. C_Img'Last));
      end if;
   end Name;

   -----------------
   -- Raise_Error --
   -----------------

   procedure Raise_Error (Message : String; Error : Integer := Errno) is
   begin
      Ada.Text_IO.Put_Line(Message);
      raise Serial_Error;--  with Message
   --         & (if Error /= 0
   --            then " (" & Errno_Message (Err => Error) & ')'
   --            else "");
   end Raise_Error;

   ------------------------------------------
   -- Baud Rate conversion (To_ and From_) --
   ------------------------------------------

   function To_Baud(rate : in natural) return Data_Rate is
      result : Data_Rate := B9600;
   begin
      for cntr in Data_Rate'Range loop
         if Data_Rate_Value(cntr) = rate then
            result := cntr;
            exit;
         end if;
      end loop;
      return result;
   end To_Baud;
   
   function From_Baud(rate : in Data_Rate) return natural is
   begin
      return Data_Rate_Value(rate);
   end From_Baud;

   ----------
   -- Open --
   ----------

   procedure Open(Port : in out Serial_Port; Name : in Port_Name) is
   
      -- procedure Unchecked_Free is
      --   new Ada.Unchecked_Deallocation (string, chars_ptr);
   
      -- C_Name  : constant chars_ptr := New_String(String (Name) & ASCII.NUL);
      C_Name  : chars_ptr := New_String(String (Name) & ASCII.NUL);
      res     : C.int;
      the_port: C.int := 0;
   
   begin
      Res := C_Open(the_port, C_Name);
      Free (C_Name);
   
      if res <= -1 then
         Raise_Error ("open: open failed for file " & String(Name) & ".");
      else
         Port.Num := res;
      end if;
   
      --  By default we are in blocking mode
      -- res := C_set_mincount(fd => Port, mcount => 0);
      -- if res = -1 then
         -- Raise_Error ("open: non-blocking failed");  -- ("open: fcntl failed");
      -- end if;
   end Open;
   
   ---------
   -- Set --
   ---------

   procedure Set
     (Port      : in out Serial_Port;
      Rate      : Data_Rate        := B9600;
      Bits      : Data_Bits        := CS8;
      Stop_Bits : Stop_Bits_Number := One;
      Parity    : Parity_Check     := None;
      Block     : Boolean          := True;
      Local     : Boolean          := True;
      Flow      : Flow_Control     := None;
      Timeout   : Duration         := 10.0) is
      use OSC;
   
      res      : C.int;
      blocking : C.int := 0;
      the_flow : constant C.int := Flow_Control'Pos(Flow);
   
   begin
      if Port.Num = 0 then
         Raise_Error ("set: port not opened", 0);
      end if;
   --       if Local then
   --          Current.c_cflag := Current.c_cflag or CLOCAL;
   --       end if;
   
      res := C_set_interface_attribs (fd       => Port.Num,
                                      speed    => C_Data_Rate(Rate),
                                      databits => C_Bits(Bits),
                                      stopbits => C_Stop_Bits(Stop_Bits),
                                      parity   => C_Parity(Parity),
                                      flow     => the_flow,
                                      local    => Boolean'Pos(Local));
      if res <= -1 then
         Raise_Error ("set: set_interface_attribs failed", -Integer(res));
      end if;
   
      if block then
         blocking := 1;  -- wait for at least 1 character
      end if;
      res:=C_set_blocking_and_timeout(fd     => Port.Num, 
                                      mcount => blocking, 
                                      timeout=> C.int(Natural(Timeout*10)));
      if res <= -1 then
         Raise_Error ("set: set_blocking_and_timeout failed", -Integer(res));
      end if;
   end Set;

   ----------
   -- Read --
   ----------

   procedure Read
     (Port   : in out Serial_Port; Buffer: in out string; Last : out natural)
   is
      in_buffer : chars_ptr := New_String (Buffer);
      len       : constant natural := Buffer'Length;
      res       : C.int;
   
   begin
      if Port.Num = 0 then
         Raise_Error ("read: port not opened", 0);
      end if;
   
      res := C_Read(fd => Port.Num, data => in_buffer, length => int(len));
   
      if res <= -1 or res > int(len) then
         Raise_Error ("read failed", -Integer(res));
      elsif res = 0 then
         Last := 0;
      else
         declare
            result : string := Interfaces.C.Strings.Value(in_buffer);
            str_len: natural:= Natural(res);
         begin
            if result'Last < result'First + str_len - 1 then
               str_len := result'Last - result'First;
            end if;
            Buffer(Buffer'First .. Buffer'First+str_len-1) := 
                                result(result'First .. result'First+str_len-1);
         end;
         Last := buffer'First  + Natural(res);
      end if;
      Free (in_buffer);
   
   end Read;

   -----------
   -- Write --
   -----------

   procedure Write(Port   : in out Serial_Port; Buffer : in string) is
   
      -- out_buffer : constant chars_ptr := New_String (Buffer & ASCII.NUL);
      out_buffer : chars_ptr := New_String (Buffer & ASCII.NUL);
      len        : constant natural := Buffer'Length;
      res        : C.int;
   
   begin
      if Port.Num = 0 then
         Raise_Error ("write: port not opened", 0);
      end if;
   
      res := C_Write(fd => Port.Num, data => out_buffer, len => C.int(len));
      Free (out_buffer);
   
      if res <= -1 then
         Raise_Error ("write failed with length " & C.int'Image(-res));
      end if;
      -- pragma Assert (size_t (Res) = Len);
   end Write;

   -----------
   -- Close --
   -----------

   procedure Close (Port : in out Serial_Port) is
   
      res : C.int;
   
   begin
      if Port.Num /= 0 then
         res := C_Close(fd => Port.Num);
      end if;
      
    exception
       when Constraint_Error =>
          Raise_Error ("Close failed with a Constraint_Error with result." & 
                       C.int'Image(-res), 1);
   end Close;

end Serial_Communications;
