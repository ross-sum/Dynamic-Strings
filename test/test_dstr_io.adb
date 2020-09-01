   -- This test requires:
   --   1.  a text file at /tmp/my_input.txt in UTF8 format.
   --       From this, it generates /tmp/my_output.txt.
   --   2.  an Arduino loaded with test_arduino_output.ino
   --       (located at /home/public/pro/ada/ligh_switches/test/test_arduino_output/
   --        and hard linked to ./obj_amd64/
   --
with Error_Log;
with dStrings;  use dStrings;
with dStrings.IO;   use dStrings.IO;
procedure Test_dStr_IO is

   procedure Test_StandardIO (input_file, output_file : file_type) is
      my_input : text;
   begin
      if input_file = Standard_Input then
         Put_Line(output_file, Value("This is a standard test to standard_output."));
         Put_Line(output_file, Value("Type in some data:"));
      else
         Put_Line(output_file, Value("This is a standard test to a file."));
         Put_Line(output_file, Value("Input some data from a file:"));
      end if;
      Get_Line(input_file,  my_input);
      Put_Line(output_file, "You wrote '" & my_input & "'.");
      New_Line(output_file);
   end Test_StandardIO;

   procedure Test_a_device (device_name : string) is
      my_input   : text;
      my_request : constant text := Value("S[1]");
      my_device  : file_type;
      char_in    : wide_character;
      loop_cntr  : natural := 20_000;  -- number of times to transmit/receive
   begin
      Put_line("Plug in the device at " & Value(device_name) & " and press enter");
      Get_line(my_input);
      Open(my_device,  In_Out_file,  device_name, "WCEM=8;57600;arduino");
      Put_Line("Opened input and output to " & Value(device_name));
      -- get the initial send from the device.
      -- Put_Line(my_device, my_request);  -- only do if talking to light_switches.ino
      while not End_Of_Line(my_device) loop
         Get (my_device, char_in);
         Put(char_in);
      end loop;
      New_Line;
      Skip_Line(my_device);
      while loop_cntr > 0 loop  -- perform a soak test
         Put_Line(my_device, my_request);
         Put_line("sent the request '" & my_request & "'.");
         Get_Line(my_device,  my_input);
         Put_Line("For input: " & my_request & ", got: '" & my_input & "'.");
         loop_cntr := loop_cntr -1;
      end loop;
      Close(my_device);
   end Test_a_device;
   
   my_input : text;
   my_out_file : file_type;
   my_in_file  : file_type;
begin
   Error_Log.Set_Log_File_Name("/tmp/test_dstr_io.log");
   Error_Log.Set_Debug_Level(to => 9);
   -- Initial test of Current_Output (which is the initial setting)
   Put_Line(Value("This is a standard test to the screen."));
   Put_Line(Value("Type in some data:"));
   Get_Line(my_input);
   Put_Line("You wrote '" & my_input & "'.");
   New_Line;
   -- Specific standard tests, initial with standard input and output
   Test_StandardIO(Standard_Input, Standard_Output);
   -- Then a standard test with an actual file.
   -- We need a file at /tmp/my_input.txt that contains a line of text
   -- for this test.
   Open(my_in_file, In_file, "/tmp/my_input.txt", "WCEM=8");
   begin
      Create(my_out_file, name => "/tmp/my_output.txt", form => "WCEM=8");
      exception
         when others =>
            Open(my_out_file, Append_file, "/tmp/my_output.txt", "WCEM=8");
   end;
   Test_StandardIO(my_in_file, my_out_file);
   Close (my_out_file);
   Close (my_in_file);
   
   -- device test.  Requires a serial device to be plugged in.
   -- It should be at /dev/ttyUSB0
   Test_a_device("/dev/ttyACM0");
   
   Put_Line(Value("Done."));
   
   New_Line;
   
end Test_dStr_IO;