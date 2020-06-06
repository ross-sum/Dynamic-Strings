-----------------------------------------------------------------------
--                                                                   --
--             D S T R I N G S   S E R I A L   C O M M S             --
--                                                                   --
--                      P a c k a g e   B o d y                      --
--                                                                   --
--                          $Revision: 1.0 $                         --
--                                                                   --
--  Copyright (C) 2020  Hyper Quantum Pty Ltd.                       --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  private library, dStrings (dynamic  String  Input/Output)  --
--  Serial  Comms, provides a buffered input to a specified  serial  --
--  device  (file name specified in the /dev directory as a  tty...  --
--  device)  with a real time response to incoming characters.   It  --
--  allows for, but does not expect, simultaneous input and  output  --
--  requests,  dealing  with them sequentially.  This is  a  safety  --
--  mechanism  to ensure that the serial pipe is  treated as  being  --
--  half-duplex  (not  actually the case, but it  is  likely  that,  --
--  apart  from  some  local  buffering,  the  other  end  is  only  --
--  transmitting  or receiving at any one point in time, not  doing  --
--  both).                                                           --
--                                                                   --
--  Version History:                                                 --
--  $Log$
--                                                                   --
--  dStrings's Serial Comms is free software; you can  redistribute  --
--  it  and/or  modify  it under terms of the  GNU  General  Public  --
--  Licence  as published by the Free Software  Foundation;  either  --
--  version 2, or (at your option) any later version.  Serial Comms  --
--  is  distributed in hope that it will be useful, but WITHOUT  ANY --
--  WARRANTY; without even the implied warranty of  MERCHANTABILITY  --
--  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public  --
--  Licence for  more details.  You should have received a copy  of  --
--  the GNU  General Public Licence distributed with Serial  Comms.  --
--  If not, write to the Free Software Foundation, 59 Temple Place-  --
--  Suite 330, Boston, MA 02111-1307, USA.                           --
--                                                                   --
-----------------------------------------------------------------------

with Ada.Characters.Latin_1;
with Ada.IO_Exceptions;
-- with Error_Log, String_Conversions;  use String_Conversions;
package body dStrings.Serial_Comms is

   package CS renames Serial_Communications;
   
   line_feed_char    : constant wide_character := 
                  wide_character'Val(character'Pos(Ada.Characters.Latin_1.LF));
   form_feed_char    : constant wide_character := 
                  wide_character'Val(character'Pos(Ada.Characters.Latin_1.FF));
   carriage_ret_char : constant wide_character := 
                  wide_character'Val(character'Pos(Ada.Characters.Latin_1.CR));
      
   task body Serial_Communications_Task is
       -- This task sets up all serial communications.  However, it only
       -- does serial output and, for serial input, sets up a task to do
       -- that.
      serial_port   : Stream_Access;
      finish_up     : boolean := false;
      output_buffer : Buffered_Comms_Output_Access;
      input_task    : Serial_Read_Task_Access;
      baud_rate     : positive;
   begin
      accept Start_Communications(for_device : in string; 
                             with_baud_rate  : in positive := 9600;
                             is_arduino      : in boolean := false;
                             use_carriage_ret: in boolean := false;
                             at_buffered_in  : in Buffered_Comms_Input_Access;
                             and_buffered_out: in Buffered_Comms_Output_Access)
      do
         output_buffer  := and_buffered_out;
         output_buffer.all.Set_Using_Carriage_Return(to => use_carriage_ret);
         baud_rate      := with_baud_rate;
         declare
            portname : CS.Port_Name := CS.Port_name(for_device);
         begin
            CS.Open(serial_port, portname);
            CS.Set(Port      => serial_port, 
                   Rate      => CS.To_Baud(rate => with_baud_rate), 
                   Bits      => CS.CS8,
                   Stop_Bits => CS.One, 
                   Parity    => CS.None);
            exception
               when Serial_Error =>
                  raise Ada.IO_Exceptions.Name_Error;
         end;
         if is_arduino then  -- initialise connection.
            declare
               char_in : string(1..2); -- character;
               char_out: string(1..1);
               len     : natural := 0;
            begin
               delay 4.0;  -- wait for Arduino to be ready
               while len = 0 loop
                  CS.Read (serial_port, char_in, len); -- get initiation
                  if len = 0 then delay 0.01; end if;  -- wait if not ready
               end loop;
               char_out(1) := char_in(1);
               CS.Write(serial_port, char_out); -- put initiation
            -- Wait until we have got all the dots and closing line feed.
               loop
                  CS.Read (serial_port, char_in, len);
                  exit when len > 0 and then 
                     char_in(1) = Ada.Characters.Latin_1.LF;
                  if len = 0 then delay 0.01; end if;  -- wait if not ready
               end loop;         
            end; -- Initiate Arduino Connection
         end if;
         input_task := new Serial_Read_Task;
         input_task.all.Start_Reading(for_buffered_input => at_buffered_in,
                                      at_comms_device    => serial_port,
                                      use_carriage_return=> use_carriage_ret);
      end Start_Communications;
      while not finish_up loop
         select
            accept Shut_Down do
               abort input_task.all;  -- unceremoneously shut it down
               CS.Close(serial_port);
               finish_up := true;
            end Shut_Down;
            accept Reset do
               -- apparently Set performs a channel reset operation.
               CS.Set(Port      => serial_port, 
                      Rate      => CS.To_Baud(rate => baud_rate),
                      Bits      => CS.CS8,
                      Stop_Bits => CS.One, 
                      Parity    => CS.None);               
            end Reset;
         else  -- check for output to go to the serial port
            while not finish_up and output_buffer.all.There_Is_Input loop
               if output_buffer.all.Next_Is_Wide then
                  declare
                     char_out : wide_character;
                     char_string : string(1..2);
                  begin
                     output_buffer.all.Read(the_wide_character => char_out);
                     char_string(1) := 
                        Character'Val(Wide_Character'Pos(char_out)/16#100#);
                     char_string(2) := 
                        Character'Val(Wide_Character'Pos(char_out) REM 16#100#);
                     CS.Write(serial_port, char_string);
                  end;
               else
                  declare
                     char_out : string(1..1);
                  begin
                     output_buffer.all.Read(the_character => char_out(1));
                     CS.Write(serial_port, char_out);
                  end;
               end if;
            end loop;
         end select;
      end loop;
   end Serial_Communications_Task;
   
   task body Serial_Read_Task is
       -- This task does the serial input.  It is subservient to to the main
       -- Serial_Communications_Task as it is waiting on serial input from
       -- the serial device, and relies on the main task to terminate it,
       -- potentially part way through waiting.
      input_buffer : Buffered_Comms_Input_Access;
      serial_port  : Stream_Access;
      using_cr     : boolean;
   begin
      accept Start_Reading(for_buffered_input : in Buffered_Comms_Input_Access;
                           at_comms_device    : in Stream_Access;
                           use_carriage_return: in boolean := false) do
         input_buffer := for_buffered_input;
         serial_port  := at_comms_device;
         using_cr     := use_carriage_return;
      end Start_Reading;
      loop  -- check for input from the serial port
         declare
            char_in : string(1..2);  -- assume all input is character based
            len     : natural :=0;
         begin
            while len = 0 loop
               CS.Read (serial_port, char_in, len);
               if len = 0 then delay 0.010; end if;  -- wait a bit
            end loop;
            if using_cr or else char_in(1) /= Ada.Characters.Latin_1.CR then
               input_buffer.all.Write(char_in(1));
            end if;  -- write if using CR or otherwise it isn't CR
         end;
         delay 0.010;  -- wait a bit to give everything else a break
      end loop;
   end Serial_Read_Task;
   
   protected body Buffered_Comms_Input is
   
      entry Read(the_character: out character) when count > 0 is
      begin
         if Wide_Character'Pos(buffer(out_pointer)) <= 2#1000_0000# then
            the_character := 
                     Character'Val(Wide_Character'Pos(buffer(out_pointer)));
         else  -- just return the lower portion of the wide_character
            the_character := Character'Val(
                     Wide_Character'Pos(buffer(out_pointer)) rem 2#1000_0000#);
         end if;
         out_pointer      := out_pointer + 1;
         count            := count - 1;
      end Read;
      
      entry Read(the_wide_character: out wide_character) when count > 0 is
      begin
         the_wide_character := buffer(out_pointer);
         out_pointer        := out_pointer + 1;
         count              := count - 1;
      end Read;
      
      function There_Is_Input return boolean is
      begin
         return count > 0;
      end There_Is_Input;
      
      function Next_Is_Line_Feed return boolean is
      begin
         if count > 0 then
            return buffer(out_pointer) = line_feed_char;
         else
            return false;  -- not accurate, but probable
         end if;
      end Next_Is_Line_Feed;
      
      function Next_Is_Form_Feed return boolean is
      begin
         if count > 0 then
            return buffer(out_pointer) = form_feed_char;
         else
            return false;  -- not accurate, but probable
         end if;
      end Next_Is_Form_Feed;
      
      function Next_Is_Wide return boolean is  -- true if > 8 bits
      begin
         return Wide_Character'Pos(buffer(out_pointer)) > 2#1111_1111#;
      end Next_Is_Wide;
      
      entry End_Of_Line(is_true : out boolean) when count > 0 is
      begin
         is_true := buffer(out_pointer) = line_feed_char;
      end End_Of_Line;
          
      entry End_Of_Page(is_true : out boolean) when count > 0 is
      begin
         is_true := buffer(out_pointer) = form_feed_char;
      end End_Of_Page;
      
      entry Write(the_character: in character) when count< buffer_size is
      begin
         buffer(in_pointer):= wide_character'Val(character'Pos(the_character));
         in_pointer        := in_pointer + 1;
         count             := count + 1;
      end Write;
      
      entry Write(the_wide_character: in wide_character) when count<buffer_size
      is
      begin
         buffer(in_pointer) := the_wide_character;
         in_pointer         := in_pointer + 1;
         count              := count + 1;
      end Write;
      
      -- private
      --   buffer : the_buffer;
      --   in_pointer, out_pointer : index := 0;
      --   count  : natural range 0..buffer_size := 0;
   end Buffered_Comms_Input;
   
   protected body Buffered_Comms_Output is
   
      entry Read(the_character: out character) when count > 0 is
      begin
         if Wide_Character'Pos(buffer(out_pointer)) <= 2#1000_0000# then
            the_character := 
                     Character'Val(Wide_Character'Pos(buffer(out_pointer)));
         else  -- just return the lower portion of the wide_character
            the_character := Character'Val(
                     Wide_Character'Pos(buffer(out_pointer)) rem 2#1000_0000#);
         end if;
         out_pointer      := out_pointer + 1;
         count            := count - 1;
      end Read;
   
      entry Read(the_wide_character: out wide_character) when count > 0 is
      begin
         the_wide_character := buffer(out_pointer);
         out_pointer        := out_pointer + 1;
         count              := count - 1;
      end Read;
      
      entry Write(the_character: in character) when count< buffer_size is
      begin
         buffer(in_pointer):= wide_character'Val(character'Pos(the_character));
         in_pointer        := in_pointer + 1;
         count             := count + 1;
      end Write;
      
      entry Write(the_wide_character: in wide_character) when count<buffer_size
      is
      begin
         buffer(in_pointer) := the_wide_character;
         in_pointer         := in_pointer + 1;
         count              := count + 1;
      end Write;
      
      function There_Is_Input return boolean is
      begin
         return count > 0;
      end There_Is_Input;
      
      function Next_Is_Wide return boolean is  -- true if > 8 bits
      begin
         return Wide_Character'Pos(buffer(out_pointer)) > 2#1000_0000#;
      end Next_Is_Wide;
      
      entry Line_Feed when count < buffer_size is
      begin
         if use_cariage_return then  -- output a CR-LF sequence, not just LF.
            buffer(in_pointer) := carriage_ret_char;
            in_pointer         := in_pointer + 1;
            count              := count + 1;
         end if;
         buffer(in_pointer) := line_feed_char;
         in_pointer         := in_pointer + 1;
         count              := count + 1;
      end Line_Feed;
      
      entry Form_Feed when count < buffer_size is
      begin
         buffer(in_pointer) := form_feed_char;
         in_pointer         := in_pointer + 1;
         count              := count + 1;
      end Form_Feed;
      
      procedure Set_Using_Carriage_Return(to : boolean) is
      begin
         use_cariage_return := to;
      end Set_Using_Carriage_Return;
      
      -- private
      --   buffer : the_buffer;
      --   in_pointer, out_pointer : index := 0;
      --   count  : natural range 0..buffer_size := 0;
      --   use_cariage_return : boolean := false;
   end Buffered_Comms_Output;

begin  -- dStrings.Serial_Comms
   null;
end dStrings.Serial_Comms;
