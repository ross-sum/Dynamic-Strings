
with dStrings;    use dStrings;
with dStrings.IO; use dStrings.IO;
with Ada.Strings.Wide_Unbounded;
procedure Test_dStrings is
  the_string : text;
  tailed_string : text;
  the_float  : float;
  the_integer : integer;
begin
   Put_Line("Testing strings with numbers for getting floats and integers from string.");
   the_string := Value("1");
   the_integer := Get_Integer_From_String(the_string);
   Put_Line("The integer extracted from '" & the_string & "' is " & Put_Into_String(the_integer) & ".");
   the_float := Get_Float_From_String(the_string);
   Put_Line("The float extracted from '" & the_string & "' is " & Put_Into_String(the_float, 3) & ".");
   the_string := Value("This is a test string that has words and words in it.");
   Put_Line("The string is '" & the_string & "', which has a length of " & Put_Into_String(Length(the_string)) & " characters.");
   Put_Line("Position of 'test' is " & Put_Into_String(Pos(Value("test"), the_string, 1)) & " (11).");
   Put_Line("First position of 'words' is " & Put_Into_String(Pos(Value("words"), the_string, 1)) & " (32).");
   Put_Line("Second position of 'words' (searching from pos 37) is " & Put_Into_String(Pos(Value("words"), the_string, 37)) & " (42).");
   Put_Line("Third position of 'words' (searching from pos 47) is " & Put_Into_String(Pos(Value("words"), the_string, 47)) & " (0).");
   Put_Line("Length(the_string)-(32+5)+1=" & Put_Into_String(Length(the_string)-(32+5)+1) & " (17).");
   tailed_string := Ada.Strings.Wide_Unbounded.Tail(the_string, 17);
   Put_Line("Tail(the_string, 17) is '" & tailed_string & "'.");
   Put_Line("Position of 'words' in the tail is " & Put_Into_String(Pos(Value("words"), tailed_string, 1)) & " (6).");
   Put_Line("Position of 'words' in calc'd tail is " & Put_Into_String(Pos(Value("words"), Ada.Strings.Wide_Unbounded.Tail(the_string,Length(the_string)-37+1),1)) & " (6).");
   Put_Line("Second Position of 'words' should be " & Put_Into_String(Pos(Value("words"), Ada.Strings.Wide_Unbounded.Tail(the_string,Length(the_string)-37+1),1)+37-1) & " (42).");

end Test_dStrings;

