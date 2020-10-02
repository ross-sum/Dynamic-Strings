   -- This test requires:
   --   1.  a text file at /tmp/my_input.txt in UTF8 format.
   --       From this, it generates /tmp/my_output.txt.
   --   2.  an Arduino loaded with test_arduino_output.ino
   --       (located at /home/public/pro/ada/ligh_switches/test/test_arduino_output/
   --       and hard linked to ./obj_amd64/.
   --   3.  An executable is generated using "make test_dstr_io" and outputs
   --       the executable at either ./obj_amd64/ or ./obj_pi/ based on Makefile.
   --
with Error_Log;
with dStrings;  use dStrings;
with dStrings.IO;   use dStrings.IO;
with Serial_Communications;
with Ada.Characters.Latin_1;
procedure Test_dStr_IO is
   package CS renames Serial_Communications;
   
   function To_Wide_String(str : in string) return wide_string is
      result : wide_string(str'First..str'Last);
   begin
      for i in str'First..str'Last loop
         result(i) := Wide_Character'Val(Character'Pos(str(i)));
      end loop;
      return result;
   end To_Wide_String;

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

   procedure Test_Using_Serial (device_name : string) is
      loop_cntr  : natural := 20_000;  -- number of times to transmit/receive
      retry_delay_counts: constant natural := 12;
      my_input   : text;
      my_request : constant string := "S[2]" & Ada.Characters.Latin_1.LF;
      serial_port : CS.Serial_Port;
      portname : CS.Port_Name := CS.Port_name(device_name);
      char_in  : string(1..2); -- character;
      char_out : string(1..1);
      len      : natural := 0;
      delay_ctr: natural := 0;
      initiate : string(1..1) := (1..1 => Ada.Characters.Latin_1.LF);
      using_cr : boolean := false;
   begin
      Put("Plug in the device at " & Value(device_name) & " and press enter >");
      Get_line(my_input);
      CS.Open(serial_port, portname);
      CS.Set(Port      => serial_port, 
                   Rate      => CS.To_Baud(rate => 57600), 
                   Bits      => CS.CS8,
                   Stop_Bits => CS.One, 
                   Parity    => CS.None);
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
         delay_ctr := delay_ctr + 1;
         if delay_ctr >= retry_delay_counts then -- initiation failed?
            delay_ctr := 0;  -- resend initiation (LF this time)
            CS.Write(serial_port, initiate);
         end if;
         if len = 0 then delay 0.01; end if;  -- wait if not ready
      end loop; 
      delay 2.0;  -- wait for Arduino to flag it is ready
      
      -- Do the test
      Put("About to run soak test for Serial_Ccommunications. " & 
               "Run pmap and then Press enter when ready >"); --Flush;
      Get_line(my_input); New_Line;
      while loop_cntr > 0 loop  -- perform a soak test
         for i in my_request'First .. my_request'Last loop
            char_out(1) := my_request(i);
            CS.Write(serial_port, char_out);
         end loop;
         -- Put_line("sent the request '" & Value(my_request) & "'.");
         Clear(my_input);
         char_in(1) := ' ';
         while char_in(1) /= Ada.Characters.Latin_1.LF loop
            len := 0;
            while len = 0 loop
               CS.Read (serial_port, char_in, len);
               if len = 0 then delay 0.010; end if;  -- wait a bit
            end loop;
            if using_cr or else (char_in(1) /= Ada.Characters.Latin_1.CR
            and char_in(1) /= Ada.Characters.Latin_1.LF) then
               my_input := my_input & to_text(char_in(1),1);
            end if;  -- write if using CR or otherwise it isn't CR
         end loop;
         Put("For input: " & To_Wide_String(my_request(my_request'First .. my_request'Last-1)) & ", got: '");
         Put(my_input); Put_Line("'.");
         loop_cntr := loop_cntr - 1;
      end loop;         
      Put("Run completed. Run pmap and then Press enter when ready >"); --Flush;
      Get_line(my_input);
   
      CS.Close(serial_port);
   end Test_Using_Serial;

   procedure Test_a_device (device_name : string) is
      my_input   : text;
      my_request : constant text := Value("S[2]");
      my_device  : file_type;
      char_in    : wide_character;
      loop_cntr  : natural := 20_000;  -- number of times to transmit/receive
   begin
      Put_line("Plug in the device at " & Value(device_name) & " and press enter >");
      Get_line(my_input);
      Open(my_device,  In_Out_file,  device_name, "WCEM=8;57600;arduino");
      Put_Line("Opened input and output to " & Value(device_name));
      -- get the initial send from the device.
      Put_Line(my_device, my_request);  -- only do if talking to light_switches.ino
      while not End_Of_Line(my_device) loop
         Get (my_device, char_in);
         Put(char_in);
      end loop;
      New_Line;
      Skip_Line(my_device);
      Put_Line("About to run soak test. Run pmap and then Press enter when ready >");
      Get_line(my_input);
      while loop_cntr > 0 loop  -- perform a soak test
         Put_Line(my_device, my_request);
         Put_line("sent the request '" & my_request & "'.");
         Get_Line(my_device,  my_input);
         Put_Line("For input: " & my_request & ", got: '" & my_input & "'.");
         loop_cntr := loop_cntr - 1;
      end loop;
   
      Put_Line("Run completed. Run pmap and then Press enter when ready >");
      Get_line(my_input);
   
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
   
   -- device test using raw serial communications
   Test_Using_Serial("/dev/serial/by-id/usb-1a86_USB_Serial-if00-port0");
   -- device test.  Requires a serial device to be plugged in.
   -- It should be at /dev/ttyUSB0
   -- Test_a_device("/dev/ttyACM0");
   Test_a_device("/dev/serial/by-id/usb-1a86_USB_Serial-if00-port0");
   
   Put_Line(Value("Done."));
   
   New_Line;
   
end Test_dStr_IO;
