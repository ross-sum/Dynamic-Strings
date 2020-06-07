  -- **************************************************************************
  -- *                      STRING (TEXT) INPUT/OUTPUT                        *
  -- **************************************************************************
  --
  -- PACKAGE FUNCTION
  --
  -- Performs I/O for the type "text" to any file, including Standard Input
  -- and Standard Output.
  --
  -- PROJECT DESCRIPTION
  --
  -- INPUT AND OUTPUT FILES
  --
  -- LINKED PACKAGES
  --
  -- Uses Wide_Text_IO, although recompilation of this package and its body may
  -- reconfigure it to use Text2_IO if the aplication program requires it.
  --
  --         ---------------------------------
  -- AUTHOR: | Ross A. Summerfield, MEng     |
  --         ---------------------------------
  --
  -- DATE OF FIRST VERSION :	6th May, 1986
  -- DATE OF LAST REWRITE :	30th March, 2020
  --
  -- VERSION: 1.2.2
  --
  -- LAST REVISION
  --
  --	Date:		Modification:
  --	31/12/1986	Use Text_IO instead of Text2_IO
  --	3/02/1987	Make all references to file_type IN OUT instead of IN
  --	3/02/1986	tyte "string" : string(string_range_length)
  --	19/02/1987	Fix up read string from file (Get_Line)
  --	25/01/1992	Re-key to strings for non-generics & using "text"
  --  19/02/2012	Modified for using UTF-8 for 16 bit wide characters.
  --  5/04/2012	Repair to handle form feed (with wide characters).
  --  26/03/2020  Clean-up of comments.
  --  30/03/2020 Set up file management so that this package can also
  --             talk to devices (such as USB devices) as if they were
  --             a terminal.
  --
  --
  --	         -----------------------------
  -- LANGUAGE: | GNAT Ada Ver 4.4          |
  --	         -----------------------------
  --
  -- ENVIRONMENT:
  --
  -- Development Machine    - MacBook Pro
  -- Target Machine	       - Intel Compatible under Linux
  -- Disk Drive System	    - NFS
  -- Operating System	    - Linux 4.9.0 (Debian 6.3.0-18)
  -- Interface              - Nil
  -- Printer                - Samsung CLP-620ND
  --
  -- THE USER MANUAL
  -- See the package specification for Open/Create usage.
  --
-- WITH dStrings;
-- with dStrings.Serial_Comms;
with Strings_Functions;
-- with Ada.Wide_Text_IO;
with Ada.Characters.Latin_1;
with Ada.IO_Exceptions;
package body dStrings.IO is
  -- pragma Elaborate_Body;
   -- use dstrings;
   use dStrings.Serial_Comms;

   -- type file_type is private;
   -- type file_mode is (In_File, Out_File, Append_File, In_Out_File);
   -- private
      -- utf8_indicator : constant dStrings.text := 
      --                                    dStrings.Value(from => "WCEM=8");
      -- is_serial : constant dStrings.Text := dStrings.Value("/dev/tty"); 
   -- type IO_types is (normal_text_io, device_io);
   -- type File_Access is access all Ada.Wide_Text_IO.File_Type;
   -- type file_type is record
   --       text_file : File_Access;
   --       std_file  : Ada.Wide_Text_IO.File_Access;
   --       using_std : boolean := false;
   --       serial_IO : dStrings.Serial_Comms.Serial_Communications_Task_Access;
   --       input_buf : dStrings.Serial_Comms.Buffered_Comms_Input_Access;
   --       output_buf: dStrings.Serial_Comms.Buffered_Comms_Output_Access;
   --       file_name : dStrings.text;
   --       the_mode  : file_mode;
   --       the_form  : dStrings.text;
   --       IO_method : IO_types := normal_text_io;
   --       utf8      : boolean  := true;
   --    end record;
     
   function To_TextIO_FM(fm : in file_mode)
   return Ada.Wide_Text_IO.file_mode is
   begin
      if fm /= In_Out_File then
         return Ada.Wide_Text_IO.file_mode'Val(file_mode'Pos(fm));
      else  -- In_Out_File mode only exists for devices such as USBs or UARTs.
         return Ada.Wide_Text_IO.file_mode'Val(file_mode'Pos(Append_File));
      end if;
   end To_TextIO_FM;
   
   -- File Management
   procedure Create(file: in out file_type; mode: file_mode := out_file;
                    name : string := ""; form : string := "") is
   begin
      file.the_mode  := mode;
      file.file_name := Value(name);
      file.the_form  := Value(form);
      if not Is_Empty(file.file_name) 
      and then Pos(pattern => is_serial, source => file.file_name) > 0
      then  -- requesting access to a serial device.  This is the same as Open.
         Open(file, mode, name, form);
      else  -- assume ordinary file
         file.IO_method := normal_text_io;
         file.text_file := new Ada.Wide_Text_IO.File_Type;
         Ada.Wide_Text_IO.Create(file.text_file.all,
                                 To_TextIO_FM(mode), name, form);
      end if;
   end Create;
   
   procedure Open  (file: in out file_type; mode: file_mode;
                    name : string; form : string := "") is
      use Strings_Functions;
      baud_rate : positive := 9600;
      an_arduino: boolean  := false;
      use_cr    : boolean  := false;
   begin  -- Open
      file.the_mode  := mode;
      file.file_name := Value(name);
      file.the_form  := Value(form);
      if not Is_Empty(file.file_name) 
      and then (Pos(pattern => is_serial, source => file.file_name) > 0 or
                Pos(pattern => is_tty, source => file.file_name) > 0)
      then  -- requesting access to a serial device
         file.IO_method := device_io;
         -- Make sure the mode is not incorrect
         if mode = append_file then
            raise Ada.IO_Exceptions.Mode_Error;
         end if;
         -- Split up the form
         if Component_Count(of_the_string=>file.the_form) > 0 then
            for cntr in 1 .. Component_Count(of_the_string=>file.the_form) loop
               declare
                  the_string : text :=
                     Component(of_the_string=>file.the_form,at_position=>cntr);
               begin
                  if the_string = utf8_indicator then
                     file.utf8  := true;
                  elsif the_string = hex_indicator or 
                        the_string = euc_indicator or
                        the_string = bra_indicator then
                     file.utf8  := false;
                  elsif the_string = Value(from=>"arduino") then
                     an_arduino := true;
                  elsif Pos(to_text('0'),the_string) > 0 or
                        Pos(to_text('7'),the_string) > 0 then -- baud?
                     baud_rate  := Get_Integer_From_String(the_string);
                  elsif the_string = Value(from=>"CR") then
                     use_cr     := true;
                  end if;
               end;
            end loop;
         end if;
         -- Actually do an open
         file.input_buf := new Buffered_Comms_Input;
         file.output_buf:= new Buffered_Comms_Output;
         file.serial_IO := new Serial_Communications_Task;
         file.serial_IO.all.Start_Communications(for_device=> name, 
                                           with_baud_rate  => baud_rate,
                                           is_arduino      => an_arduino,
                                           use_carriage_ret=> use_cr,
                                           at_buffered_in  => file.input_buf,
                                           and_buffered_out=> file.output_buf);
      else  -- assume ordinary file
         file.IO_method := normal_text_io;
         file.text_file := new Ada.Wide_Text_IO.File_Type;
         Ada.Wide_Text_IO.Open(file.text_file.all,
                               To_TextIO_FM(mode), name, form);
      end if;
   end Open;
   
   procedure Close (file : in out file_type) is
   begin
      if file.IO_method = device_io then
         file.serial_IO.all.Shut_Down;
         abort file.serial_IO.all;   --  Ensure it is dead.
      elsif not file.using_std then  -- can't close standard files
         Ada.Wide_Text_IO.Close(file.text_file.all);
            -- DO WE NEED TO FREE file.text_file?  IF SO, HOW?
      end if;
   end Close;
   
   procedure Delete(file : in out file_type) is
   begin
      if file.IO_method = device_io then
         null;  -- You can't delete a file.  But you can close it.
         file.serial_IO.all.Shut_Down;
      elsif not file.using_std then  -- cant delete standard files
         Ada.Wide_Text_IO.Delete(file.text_file.all);
      end if;
   end Delete;
   
   procedure Reset (file : in out file_type; mode : file_mode) is
   begin
      file.the_mode := mode;
      if file.IO_method = device_io then
         -- Make sure the mode is not incorrect
         if mode = append_file then
            raise Ada.IO_Exceptions.Mode_Error;
         end if;
         file.serial_IO.all.Reset;
      elsif not file.using_std then  -- can't reset standard (I/O) files
         Ada.Wide_Text_IO.Reset(file.text_file.all, To_TextIO_FM(mode));
      end if;
   end Reset;
   
   procedure Reset (file : in out file_type) is
   begin
      if file.IO_method = device_io then
         file.serial_IO.all.Reset;
      elsif not file.using_std then  -- can't reset standard (I/O) files
         Ada.Wide_Text_IO.Reset(file.text_file.all);
      end if;
   end Reset;
   
   function Is_Open(file : file_type) return boolean is
   begin
      return Ada.Wide_Text_IO.Is_Open(file.text_file.all);
   end Is_Open;

   function Mode(file : file_type) return file_mode is
   begin
      return file.the_mode;
   end Mode;
   
   function Name(file : file_type) return string is
   begin
      return Value(file.file_name);
   end Name;
   
   function Form(file : file_type) return string is
   begin
      return Value(file.the_form);
   end Form;
   
   -- Control of deault input, output and error files
   procedure Set_Input (file : in file_type) is
   begin
      the_current_input := file;
      if file.IO_method /= device_io then
         if file.using_std then
            Ada.Wide_Text_IO.Set_Input(file.std_file.all);
         else
            Ada.Wide_Text_IO.Set_Input(file.text_file.all);
         end if;
      end if;
   end Set_Input;
   
   procedure Set_Output(file : in file_type) is
   begin
      the_current_output := file;
      if file.IO_method /= device_io then
         if file.using_std then
            Ada.Wide_Text_IO.Set_Output(file.std_file.all);
         else
            Ada.Wide_Text_IO.Set_Output(file.text_file.all);
         end if;
      end if;
   end Set_Output;
   
   procedure Set_Error (file : in file_type) is
   begin
      if file.IO_method = device_io then
         null;  -- no such thing!  So do nothing.
      else
         if file.using_std then
            Ada.Wide_Text_IO.Set_Error(file.std_file.all);
         else
            Ada.Wide_Text_IO.Set_Error(file.text_file.all);
         end if;
      end if;
   end Set_Error;
   
   function Standard_Input  return file_type is
      result : file_type;
   begin
      result.std_file  := Ada.Wide_Text_IO.Standard_Input;
      result.file_name := Value("Standard_Input");
      result.the_mode  := in_file;
      result.using_std := true;
      return result;
   end Standard_Input;
   
   function Standard_Output return file_type is
      result : file_type;
   begin
      result.std_file  := Ada.Wide_Text_IO.Standard_Output;
      result.file_name := Value("Standard_Output");
      result.the_mode  := out_file;
      result.using_std := true;
      return result;
   end Standard_Output;
   
   function Standard_Error  return file_type is
      result : file_type;
   begin
      result.std_file  := Ada.Wide_Text_IO.Standard_Error;
      result.file_name := Value("Standard_Error");
      result.the_mode  := out_file;
      result.using_std := true;
      return result;
   end Standard_Error;
   
   function Current_Input   return file_type is
   begin
      return the_current_input;
   end Current_Input;
   
   function Current_Output  return file_type is
   begin
      return the_current_output;
   end Current_Output;
   
   function Current_Error   return file_type is
   begin
      return Standard_Error;  -- should be true
   end Current_Error;
   
   -- Buffer control
   procedure Flush (file : in file_type) is
   begin
      if file.IO_method = device_io then
         null;  -- NOT YET IMPLEMENTED.  SHOULD WE IMPLEMENT IT?
      else
         if file.using_std then
            Ada.Wide_Text_IO.Flush(file.std_file.all);
         else
            Ada.Wide_Text_IO.Flush(file.text_file.all);
         end if;
      end if;
   end Flush;
   
   procedure Flush is
   begin
      Flush(the_current_input);
   end Flush;

   -- text I/O
   procedure Get_UTF8_Char(file : in File_Type;
                           char : out wide_character) is
     -- Read from the input, in UTF-8 format, a wide_character.
      data      : character;
   begin
      if file.IO_method = device_io then  -- Serial device for I/O
         if file.the_mode = out_file then
            raise Ada.IO_Exceptions.Mode_Error;
         end if;  -- in_file and in_out_file are okay
         if not file.utf8 then  -- treat character as raw data
            file.input_buf.all.Read(char);
            return;
         else
            file.input_buf.all.Read(data);
         end if;
         if Character'Pos(data) < 128 then
         -- character 1 byte length
            char := Wide_Character'Val(Character'Pos(data));
         elsif Character'Pos(data) >= 2#1100000# and
         Character'Pos(data) <  2#1110000# then
            char := Wide_Character'Val(
               (Character'Pos(data) REM 2#00100000#) * 16#40#);
            file.input_buf.all.Read(data);
            char := Wide_Character'Val(Wide_Character'Pos(char) +
               (Character'Pos(data) REM 2#01000000#));
         else  -- assume just 3 byte, not a 4 byte
            char := Wide_Character'Val(
               (Character'Pos(data) REM 2#00010000#)*16#1000#);
            file.input_buf.all.Read(data);
            char := Wide_Character'Val(Wide_Character'Pos(char) +
               ((Character'Pos(data) REM 2#01000000#) * 16#40#));
            file.input_buf.all.Read(data);
            char := Wide_Character'Val(Wide_Character'Pos(char) +
               (Character'Pos(data) REM 2#01000000#));
         end if;
      else  -- standard file using Wide_Text_IO
         if file.using_std then
            Ada.Wide_Text_IO.Get(file.std_file.all, char);
         else
            Ada.Wide_Text_IO.Get(file.text_file.all, char);
         end if;
      end if;
   end Get_UTF8_Char;
   
   procedure Get(file : in File_Type; item : out wide_character) is
   begin
      if file.IO_method = device_io then  -- check for end of line
         while not file.input_buf.all.There_Is_Input loop
            delay 0.100;  -- wait a small amount of time.
         end loop;
         if (file.input_buf.all.Next_Is_Line_Feed or
          file.input_buf.all.Next_Is_Form_Feed) then -- error
            raise Ada.IO_Exceptions.End_Error;
         end if;
      end if;
      Get_UTF8_Char(file, item);
   end Get;
   
   procedure Get(item : out wide_character) is
   begin
      Get(the_current_input, item);
   end Get;

   procedure Get_Line(item : out dstrings.text) is
   begin
      Get_Line(the_current_input, item);
   end Get_Line;

   procedure Get_Line(file : in File_Type;
                      item: out dstrings.text) is
      data : wide_character;
   begin
      Clear(item);
      while not End_Of_Line(file) loop
         Get(file, data);
         Append(wide_tail => data, to => item);
      end loop;
      Skip_Line(file);
   end Get_Line;

   procedure Put_UTF8_Char(file : in File_Type;
                           char : in wide_character) is
     -- Convert the input, in wide_character format, to UTF-8 output
      data : character;
   begin
      if file.IO_method = device_io then
         if file.the_mode /= out_file and file.the_mode /= in_out_file then
            raise Ada.IO_Exceptions.Mode_Error;
         end if;
         if not file.utf8 then -- write as a wide character
            file.output_buf.all.Write(char);
         -- otherwise process as UTF8
         elsif Wide_Character'Pos(char) < 2#1000_0000# then
            data := Character'Val(Wide_Character'Pos(char));
            file.output_buf.all.Write(data);
         elsif Wide_Character'Pos(char) < 2#0000_1000_0000_0000# then
            data := Character'Val(2#110_00000# +
               (Wide_Character'Pos(char) / 16#40#));
            file.output_buf.all.Write(data);
            data := Character'Val(2#10_000000# +
               (Wide_Character'Pos(char) REM 16#40#));
            file.output_buf.all.Write(data);
         else
            data := Character'Val(2#1110_0000# +
               (Wide_Character'Pos(char) / 16#1000#));
            file.output_buf.all.Write(data);
            data := Character'Val(2#10_000000# +
               ((Wide_Character'Pos(char) REM 16#1000#)
               / 16#40#));
            file.output_buf.all.Write(data);
            data := Character'Val(2#10_000000# +
               (Wide_Character'Pos(char) REM 16#40#));
            file.output_buf.all.Write(data);
         end if;
      else
         if file.using_std then
            Ada.Wide_Text_IO.Put(file.std_file.all, char);
         else
            Ada.Wide_Text_IO.Put(file.text_file.all, char);
         end if;
      end if;
   end Put_UTF8_Char;
   
   procedure Put(file : in File_type; item : in wide_character) is
   begin
      Put_UTF8_Char(file, item);
   end Put;

   procedure Put(item : in wide_character) is
   begin
      Put(the_current_output, item);
   end Put;

   procedure Put(item : in dstrings.text) is
   begin
      Put(the_current_output, item);
   end Put;

   procedure Put(file : in File_Type;
   item : in dstrings.text) is
   begin
      for counter in 1..Length(item) loop
         Put_UTF8_Char(file, Wide_Element(item, counter));
      end loop;
   end Put;

   procedure Put(item : in wide_string) is
   begin
      Put(the_current_output, item);
   end Put;
   
   procedure Put(file : in file_type; 
                 item : in wide_string) is
   begin
      for counter in item'Range loop
         Put_UTF8_Char(file, item(counter));
      end loop;
   end Put;

   procedure Put_Line(item : in dstrings.text) is
   begin
      Put_Line(the_current_output, item);
   end Put_Line;

   procedure Put_Line(file : in File_Type;
   item : in dstrings.text) is
   begin
      Put(file, item);
      New_Line(file);
   end Put_Line;
   
   procedure Put_Line(item : in wide_string) is
   begin
      Put_Line(the_current_output, item);
   end Put_Line;
   
   procedure Put_Line(file : in file_type; 
                      item : in wide_string) is
   begin
      Put(file, item);
      New_Line(file);
   end Put_Line;
   
   -- Page management
   procedure New_Line (File : File_Type; Spacing : Positive_Count := 1) is
   begin
      if file.IO_method = device_io then
         for cntr in 1..Spacing loop
            file.output_buf.all.Line_Feed;
         end loop;
      else
         if file.using_std then
            Ada.Wide_Text_IO.New_Line(file.std_file.all, spacing);
         else
            Ada.Wide_Text_IO.New_Line(file.text_file.all, spacing);
         end if;
      end if;
   end New_Line;
   
   procedure New_Line (Spacing : Positive_Count := 1) is
   begin
      New_Line(the_current_output, spacing);
   end New_Line;

   procedure Skip_Line (File : File_Type; Spacing : Positive_Count := 1) is
      data : character;
   begin
      if file.IO_method = device_io then
         for line_count in 1 .. spacing loop
            -- get to the next line feed character
            while not file.input_buf.all.There_Is_Input loop
               delay 0.100;  -- wait a small amount of time for a character.
            end loop;
            while not file.input_buf.all.Next_Is_Line_Feed loop
               -- skip past non-line feed characters (eat them)
               file.input_buf.all.Read(the_character=> data);
               while not file.input_buf.all.There_Is_Input loop
                  delay 0.100;  -- wait a small amount of time for a character.
               end loop;
            end loop;
            -- then get past the line feed character (eat it)
            file.input_buf.all.Read(the_character=> data);
         end loop;
      else
         if file.using_std then
            Ada.Wide_Text_IO.Skip_Line(file.std_file.all, spacing);
         else
            Ada.Wide_Text_IO.Skip_Line(file.text_file.all, spacing);
         end if;
      end if;
   end Skip_Line;
   
   procedure Skip_Line (Spacing : Positive_Count := 1) is
   begin
      Skip_Line(the_current_input, spacing);
   end Skip_Line;

   function End_Of_Line (File : File_Type) return Boolean is
   begin
      if file.IO_method = device_io then
         declare
            is_end_of_line : boolean;
         begin
            file.input_buf.all.End_Of_Line(is_true => is_end_of_line);
            return is_end_of_line;
         end;
         -- while not file.input_buf.all.There_Is_Input loop
         --    delay 0.100;  -- wait a small amount of time for character.
         -- end loop;
         -- return file.input_buf.all.Next_Is_Line_Feed;
      else
         if file.using_std then
            return Ada.Wide_Text_IO.End_Of_Line(file.std_file.all);
         else
            return Ada.Wide_Text_IO.End_Of_Line(file.text_file.all);
         end if;
      end if;
   end End_Of_Line;
   
   function End_Of_Line return Boolean is
   begin
      return End_Of_Line(the_current_output);
   end End_Of_Line;

   procedure New_Page (File : File_Type) is
   begin
      if file.IO_method = device_io then
         file.output_buf.all.Form_Feed;
      else
         if file.using_std then
            Ada.Wide_Text_IO.New_Page(file.std_file.all);
         else
            Ada.Wide_Text_IO.New_Page(file.text_file.all);
         end if;
      end if;
   end New_Page;
   
   procedure New_Page is
   begin
      New_Page(the_current_output);
   end New_Page;

   procedure Skip_Page (File : File_Type) is
      data : character;
   begin
      if file.IO_method = device_io then
         -- get to the next form feed character
         while not file.input_buf.all.There_Is_Input loop
            delay 0.100;  -- wait a small amount of time for character.
         end loop;
         while not file.input_buf.all.Next_Is_Form_Feed loop
            -- skip past non-form feed character (eat it)
            file.input_buf.all.Read(the_character=> data);
            while not file.input_buf.all.There_Is_Input loop
               delay 0.100;  -- wait a small amount of time for character.
            end loop;
         end loop;
         -- then get past the form feed character (eat it)
         file.input_buf.all.Read(the_character=> data);
      else
         if file.using_std then
            Ada.Wide_Text_IO.Skip_Page(file.std_file.all);
         else
            Ada.Wide_Text_IO.Skip_Page(file.text_file.all);
         end if;
      end if;
   end Skip_Page;
   
   procedure Skip_Page is
   begin
      Skip_Page(the_current_input);
   end Skip_Page;

   function End_Of_Page (File : File_Type) return Boolean is
   begin
      if file.IO_method = device_io then
         declare
            is_end_of_page : boolean;
         begin
            file.input_buf.all.End_Of_Page(is_true => is_end_of_page);
            return is_end_of_page;
         end;
         -- while not file.input_buf.all.There_Is_Input loop
         --    delay 0.100;  -- wait a small amount of time for character.
         -- end loop;
         -- return file.input_buf.all.Next_Is_Form_Feed;
      else
         if file.using_std then
            return Ada.Wide_Text_IO.End_Of_Page(file.std_file.all);
         else
            return Ada.Wide_Text_IO.End_Of_Page(file.text_file.all);
         end if;
      end if;
   end End_Of_Page;
   
   function End_Of_Page return Boolean is
   begin
      return End_Of_Page(the_current_input);
   end End_Of_Page;

   function End_Of_File (File : File_Type) return Boolean is
   begin
      if file.IO_method = device_io then
         null;  -- probably no such thing for a serial device
         return false;
      else
         if file.using_std then
            return Ada.Wide_Text_IO.End_Of_File(file.std_file.all);
         else
            return Ada.Wide_Text_IO.End_Of_File(file.text_file.all);
         end if;
      end if;
   end End_Of_File;
   
   function End_Of_File return Boolean is
   begin
      return End_Of_File(the_current_input);
   end End_Of_File;
   
begin
   -- initialise current input and current output
   the_current_input.std_file   := Ada.Wide_text_IO.Current_Input;
   the_current_input.the_mode   := in_file;
   the_current_input.using_std  := true;
   the_current_input.file_name  := Value("Standard_Input");   -- probably
   the_current_output.std_file  := Ada.Wide_text_IO.Current_Output;
   the_current_output.the_mode  := out_file;
   the_current_output.using_std := true;
   the_current_output.file_name := Value("Standard_Output");  -- probably
   
end dStrings.IO;
