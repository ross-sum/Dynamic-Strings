
  -- **************************************************************************
  -- *                    STRING (TEXT) INPUT/OUTPUT                          *
  -- **************************************************************************
  --
  -- PACKAGE FUNCTION
  --
  -- Performs I/O for the type "dString" to any file, including Standard Input
  -- and Standard Output.
  --
  -- PROJECT DESCRIPTION
  --
  -- INPUT AND OUTPUT FILES
  --
  -- LINKED PACKAGES
  --
  -- Uses Text_IO, although recompilation of this package and its body may
  -- reconfigure it to use Text2_IO if the aplication program requires it.
  --
  --         ---------------------------------
  -- AUTHOR: | Ross A. Summerfield, BEng     |
  --         ---------------------------------
  --
  -- DATE OF FIRST VERSION :	6th May, 1986
  -- DATE OF LAST REWRITE :	30th March, 2020
  --
  -- VERSION: 1.1.0
  --
  -- LAST REVISION
  --
  --	Date:		  Modification:
  --	31/12/1986 Use Text_IO instead of Text2_IO
  --	3/02/1987  Make all references to file_type IN OUT instead of IN
  --	25/01/1992 Re-key to strings as pass-through size rather than 
  --             generic
  --  30/03/2020 Set up file management so that this package can also
  --             talk to devices (such as USB devices) as if they were
  --             a terminal.
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
  -- This provides the standard style Ada.Wide_Text_IO for ordinary file types.
  -- In this case, the rules and methods for using Ada.Wide_Text_IO apply.
  -- Note that although the mode In_Out_File is generally available, its
  -- use for a regular file will result in Mode_Error being raised.
  --
  -- It also provides the capability to write to devices using the GNAT
  -- Serial Communications package.  In the case of writing to a device,
  -- communications is bidirectional.  There is an additional mode type
  -- of In_Out_File for this purpose.
  --
  -- The Form has the following options:
  --   For character types, there are:
  --     WCEM=8 - UTF 8    (this is the default for device files)
  --     WCEM=h - Hexadecimal
  --     WCEM=e - EUC
  --     WCEM=b - Brackets (this is the default for regular I/O).
  --   arduino - If present, means the device is talking to an Arduino.
  --             Do not specify this for a standard file.
  --   CR      - If present, then use the Carriage Return/Line Feed
  --             combination for device file input/output.
  --   nnnnn   - Baud rate (where "nnnn" is a number representing the
  --             baud rate) for the device.  The default is 9600 Baud.
  -- These options can be strung together, separated by semicolons (;)
  -- for a device.  The standard Ada.Wide_Text_IO rules apply for regular
  -- files.  Essentially that means that only the WCEM= options are
  -- available and all options would be ignored if semicolons were used
  -- in any case.
  --
-- with dStrings;
with Ada.Wide_Text_IO;
with Ada.IO_Exceptions;
with dStrings.Serial_Comms;  -- affects our private type
package dStrings.IO is
   pragma Elaborate_Body;
    --USE dstrings;
    
   Name_Error  : exception renames Ada.IO_Exceptions.Name_Error;
   Use_Error   : exception renames Ada.IO_Exceptions.Use_Error;
   Mode_Error  : exception renames Ada.IO_Exceptions.Mode_Error;
   End_Error   : exception renames Ada.IO_Exceptions.End_Error;
   Status_Error: exception renames Ada.IO_Exceptions.Status_Error;
   
   type file_type is private;
   type file_mode is (In_File, Out_File, Append_File, In_Out_File);
   subtype Positive_Count is Ada.Wide_Text_IO.Positive_Count;
   
   -- File Management
   procedure Create(file: in out file_type; mode: file_mode := out_file;
                    name : string := ""; form : string := "");
   procedure Open  (file: in out file_type; mode: file_mode;
                    name : string; form : string := "");
   procedure Close (file : in out file_type);
   procedure Delete(file : in out file_type);
   procedure Reset (file : in out file_type; mode : file_mode);
   procedure Reset (file : in out file_type);
   function Is_Open(file : file_type) return boolean;
   procedure Apply_Exclusive_Lock(to_file : in out file_type);
     -- not yet implemented
   procedure Release_Exclusive_Lock(on_file : in out file_type);
     -- not yet implemented
   
   function Mode(file : file_type) return file_mode;
   function Name(file : file_type) return string;
   function Form(file : file_type) return string;
   
   -- Control of deault input, output and error files
   procedure Set_Input (file : in file_type);
   procedure Set_Output(file : in file_type);
   procedure Set_Error (file : in file_type);
   
   function Standard_Input  return file_type;
   function Standard_Output return file_type;
   function Standard_Error  return file_type;
   
   function Current_Input   return file_type;
   function Current_Output  return file_type;
   function Current_Error   return file_type;
   
   -- Buffer control
   procedure Flush (file : in file_type);
   procedure Flush;
   
   -- (wide) character I/O
   procedure Get(file : in File_Type; item : out wide_character);
   procedure Get(item : out wide_character);
   procedure Put(file : in File_type; item : in wide_character);
   procedure Put(item : in wide_character);
   
    -- text I/O
   procedure Get_Line(item : out dstrings.text);
   procedure Get_Line(file : in file_type; 
                      item : out dstrings.text);
   procedure Put(item : in dstrings.text);
   procedure Put(file : in file_type; 
                 item : in dstrings.text);
   procedure Put(item : in wide_string);
   procedure Put(file : in file_type; 
                 item : in wide_string);
   procedure Put_Line(item : in dstrings.text);
   procedure Put_Line(file : in file_type; 
                      item : in dstrings.text);
   procedure Put_Line(item : in wide_string);
   procedure Put_Line(file : in file_type; 
                      item : in wide_string);
   
   -- Page management
   procedure New_Line (File : File_Type; Spacing : Positive_Count := 1);
   procedure New_Line (Spacing : Positive_Count := 1);

   procedure Skip_Line (File : File_Type; Spacing : Positive_Count := 1);
   procedure Skip_Line (Spacing : Positive_Count := 1);

   function End_Of_Line (File : File_Type) return Boolean;
   function End_Of_Line return Boolean;

   procedure New_Page (File : File_Type);
   procedure New_Page;

   procedure Skip_Page (File : File_Type);
   procedure Skip_Page;

   function End_Of_Page (File : File_Type) return Boolean;
   function End_Of_Page return Boolean;

   function End_Of_File (File : File_Type) return Boolean;
   function End_Of_File return Boolean;

   private
   
   utf8_indicator : constant dStrings.text := dStrings.Value(from => "WCEM=8");
   hex_indicator  : constant dStrings.text := dStrings.Value(from => "WCEM=h");
   euc_indicator  : constant dStrings.text := dStrings.Value(from => "WCEM=e");
   bra_indicator  : constant dStrings.text := dStrings.Value(from => "WCEM=b");

   is_tty : constant dStrings.Text := dStrings.Value("/dev/tty"); 
   is_serial : constant dStrings.Text := dStrings.Value("/dev/serial/"); 
   
   type IO_types is (normal_text_io, device_io);
   type File_Access is access all Ada.Wide_Text_IO.File_Type;

   type file_type is record
         text_file : File_Access;
         std_file  : Ada.Wide_Text_IO.File_Access;
         using_std : boolean := false;
         serial_IO : dStrings.Serial_Comms.Serial_Communications_Task_Access;
         input_buf : dStrings.Serial_Comms.Buffered_Comms_Input_Access;
         output_buf: dStrings.Serial_Comms.Buffered_Comms_Output_Access;
         file_name : dStrings.text := dStrings.Value("");
         the_mode  : file_mode;
         the_form  : dStrings.text := dStrings.Value("");
         IO_method : IO_types := normal_text_io;
         utf8      : boolean  := true;
      end record;
      
   the_current_input  : file_type;
   the_current_output : file_type;
  
end dStrings.IO;
