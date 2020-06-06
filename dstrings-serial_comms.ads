-----------------------------------------------------------------------
--                                                                   --
--          D S T R I N G S . I O   S E R I A L   C O M M S          --
--                                                                   --
--             P a c k a g e    S p e c i f i c a t i o n            --
--                                                                   --
--                          $Revision: 1.0 $                         --
--                                                                   --
--  Copyright (C) 2020  Hyper Quantum Pty Ltd.                       --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This private library, dStrings.IO (dynamic String Input/Output)  --
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
--  dStrings.IO's Serial Comms is free software; you can redistribute--
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

with Serial_Communications;

package dStrings.Serial_Comms is

   Serial_Error : exception renames Serial_Communications.Serial_Error;
   
   buffer_size: constant := 80;
   type index is mod buffer_size;
   type the_buffer is array (index) of wide_character;
   
   protected type Buffered_Comms_Input is
       -- input coming from the serial device
      entry Read(the_character: out character);
      entry Read(the_wide_character: out wide_character);
      function There_Is_Input return boolean;
      function Next_Is_Line_Feed return boolean;
      function Next_Is_Form_Feed return boolean;
      function Next_Is_Wide return boolean;  -- true if > 8 bits
      entry End_Of_Line(is_true : out boolean);
      entry End_Of_Page(is_true : out boolean);
      entry Write(the_character: in character);
      entry Write(the_wide_character: in wide_character);
   private
      buffer : the_buffer;
      in_pointer, out_pointer : index := 0;
      count  : natural range 0..buffer_size := 0;
   end Buffered_Comms_Input;
   
   protected type Buffered_Comms_Output is
       -- output going to the serial device
      entry Read(the_character: out character);
      entry Read(the_wide_character: out wide_character);
      entry Write(the_character: in character);
      entry Write(the_wide_character: in wide_character);
      function There_Is_Input return boolean;
      function Next_Is_Wide return boolean;  -- true if > 8 bits
      entry Line_Feed;
      entry Form_Feed;
      procedure Set_Using_Carriage_Return(to : boolean);
   private
      buffer : the_buffer;
      in_pointer, out_pointer : index := 0;
      count  : natural range 0..buffer_size := 0;
      use_cariage_return : boolean := false;
   end Buffered_Comms_Output;
    
   type Buffered_Comms_Input_Access       is access Buffered_Comms_Input;
   type Buffered_Comms_Output_Access      is access Buffered_Comms_Output;
    
   task type Serial_Communications_Task is
       -- This task sets up all serial communications.  However, it only
       -- does serial output and, for serial input, sets up a task to do
       -- that.
      entry Start_Communications(for_device   : in string; 
                              with_baud_rate  : in positive := 9600;
                              is_arduino      : in boolean := false;
                              use_carriage_ret: in boolean := false;
                              at_buffered_in  : in Buffered_Comms_Input_Access;
                              and_buffered_out: in Buffered_Comms_Output_Access);
      entry Reset;
      entry Shut_Down;
   end Serial_Communications_Task;
   
   type Serial_Communications_Task_Access is access Serial_Communications_Task;
   
   private

   subtype Stream_Access is Serial_Communications.Serial_Port;
   
   task type Serial_Read_Task is
       -- This task does the serial input.  It is subservient to to the main
       -- Serial_Communications_Task as it is waiting on serial input from
       -- the serial device, and relies on the main task to terminate it,
       -- potentially part way through waiting.
      entry Start_Reading(for_buffered_input : in Buffered_Comms_Input_Access;
                          at_comms_device    : in Stream_Access;
                           use_carriage_return: in boolean := false);
   end Serial_Read_Task;
   
   type Serial_Read_Task_Access is access Serial_Read_Task;

end dStrings.Serial_Comms;
