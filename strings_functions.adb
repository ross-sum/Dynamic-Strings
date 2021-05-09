-----------------------------------------------------------------------
--                                                                   --
--                   S T R I N G S _ F U N C T I O N S               --
--                                                                   --
--                                B o d y                            --
--                                                                   --
--                            $Revision: 1.2 $                       --
--                                                                   --
--  Copyright (C) 1999,2001,2021  Hyper Quantum Pty Ltd.             --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This package provides some string manipulation capabilities for  --
--  the strings library.                                             --
--                                                                   --
--  Version History:                                                 --
--  $Log: strings_functions.adb,v $
--  Revision 1.1  2001/04/29 01:17:08  ross
--  Initial revision
--  Revision 1.2  2021/02/28 20:48:00  ross
--  Added in the reverse of Assemble (Disassemble).
--                                                                   --
--  This  library is free software; you can redistribute it  and/or  --
--  modify it under terms of the GNU Lesser General  Public Licence  --
--  as  published by the Free Software Foundation;  either  version  --
--  2.1 of the licence, or (at your option) any later version.       --
--  This library is distributed in hope that it will be useful, but  --
--  WITHOUT  ANY  WARRANTY; without even the  implied  warranty  of  --
--  MERCHANTABILITY  or FITNESS FOR A PARTICULAR PURPOSE.  See  the  --
--  GNU Lesser General Public Licence for more details.              --
--  You  should  have  received a copy of the  GNU  Lesser  General  --
--  Public  Licence along with this library.  If not, write to  the  --
--  Free Software Foundation, 59 Temple Place -  Suite 330, Boston,  -- 
--  MA 02111-1307, USA.                                              --
--                                                                   --
-----------------------------------------------------------------------
with Ada.Characters.Latin_1;
with Ada.Characters.Handling;
-- with Ada.Text_IO;

package body Strings_Functions is

   CR : constant wide_character := 
   Ada.Characters.Handling.To_Wide_Character(Ada.Characters.Latin_1.CR);
   LF : constant wide_character := 
   Ada.Characters.Handling.To_Wide_Character(Ada.Characters.Latin_1.LF);

   function Left_Trim (the_string : text; 
   of_character : wide_character := ' ') return text is
      -- Trim characters (usually spaces) from the left hand side
      character_number : natural range 0..Length(the_string)+1:=1;
      first_character  : wide_character := ' ';
      working_string   : text := the_string;
   begin
      if Length(working_string) > 0 and of_character = LF then
         first_character := Wide_Element(working_string, 1);
         if wide_character'Pos(first_character) = wide_character'Pos(LF) 
         then
            Delete(working_string, 1, 1);
            return Left_Trim(working_string, of_character);
         else
            return working_string;
         end if;
      elsif Length(working_string)>0 and of_character = CR then
         if Length(working_string) > 1 then
            first_character := Wide_Element(working_string, 2);
         end if;
         if Wide_Element(working_string, 1) = CR then
            if first_character = LF then  -- trim line feed with it
               Delete(working_string, 1, 2);
            else  -- ^M on its own - remove it
               Delete(working_string, 1, 1);
            end if;  -- else just ^M, not CR-LF sequence
            return Left_Trim(working_string, of_character);
         else
            return working_string;
         end if;
      elsif Length(working_string) > 0 then
         while character_number < Length(working_string) and 
         then Wide_Element(the_string,character_number) = 
         of_character loop
            character_number := character_number + 1;
         end loop;
         Delete(working_string, 1, character_number - 1);
         return working_string;
      else  -- empty string
         return working_string;
      end if;
   end Left_Trim;

   function Right_Trim (the_string : text; 
   of_character : wide_character := ' ') return text is 
      -- Trim characters (usually spaces) from the right hand side
      character_number : natural range 0 .. Length(the_string) := 
      Length(the_string);
   begin
      if Length(the_string) > 0 then
         while character_number > 0 and then
         Wide_Element(the_string,character_number) = of_character 
         loop
            character_number := character_number - 1;
         end loop;
         return Sub_String(the_string, 1, character_number);
      else  -- empty string
         return the_string;
      end if;
   end Right_Trim;

   function Trim (the_string : text; 
   of_character : wide_character := ' ') return text is
      -- Trim characters (usually spaces) from both sides of the 
      -- string.
   begin
      return Left_Trim(Right_Trim(the_string, of_character),
         of_character);
   end Trim;

   function Component(of_the_string : in text; 
   at_position : in positive := 1;
   separated_by : in wide_character := ';') return text is
      use Ada.Characters.Handling;
      -- Get the component from a string where the components are
      -- separated by the specified character.
      the_result   : text:= of_the_string;
      the_separator: text:= To_Text(separated_by);
   begin
      for current_item in 1 .. at_position - 1 loop
         if Length(the_result) > 0 then
            if Pos(the_separator, the_result) > 0 then
               Delete(the_result,1,Pos(the_separator,the_result));
            else  -- delete to the end
               Clear(the_result);
            end if;
         end if;
      end loop;
      if Length(the_result) > 0 and then
      Pos(the_separator, the_result) > 0 then
         Delete(the_result, Pos(the_separator, the_result), 
            Length(the_result)-Pos(the_separator, the_result)+1);
      end if;
      return the_result;
   end Component;

   function Component_Count(of_the_string : in text; 
   separated_by : in wide_character := ';') return positive is
   -- Return the number of elements, which are separated by the
   -- specified seperator.
      the_number : positive := 1;
   begin
      for item in 1..Length(of_the_string) loop
         if Wide_Element(of_the_string, at_position => item) =
         separated_by then
            the_number := the_number + 1;
         end if;
      end loop;
      return the_number;
   end Component_Count;

   -- type text_array is array (positive range <>) of ttext;
   function Assemble(from_strings : in text_array;
   separated_by : in wide_character := ';')return text is 
      -- Create a string that contains all the components in the
      -- array of strings with each component separated by the
      -- specified character.
      -- type string_array is array (positive range <>) of string;
      the_result : text;
   begin
      for item in from_strings'Range loop
         if item > 1 then
            Append(separated_by, to => the_result);
         end if;
         Append(from_strings(item), to => the_result);
      end loop;
      return the_result;
   end Assemble;

   function Assemble(from_strings : in string_array;
   separated_by : in wide_character := ';')return text is
      -- Create a string that contains all the components in the
      -- array of strings with each component separated by the
      -- specified character.
      the_result : text;
   begin
      for item in from_strings'Range loop
         if item > 1 then
            Append(separated_by, to => the_result);
         end if;
         for cntr in from_strings'Range(2) loop
            Append(from_strings(item, cntr), to => the_result);
         end loop;
      end loop;
      return the_result;
   end Assemble;

   function Disassemble(from_string : in text;
   separated_by : in wide_character := ';')return text_array is
      -- Create an array that contains all the components in the
      -- text, breaking it apart with each component separated by the
      -- specified character.
      num_rows   : constant natural := 
                             Component_Count(of_the_string => from_string, 
                                             separated_by  => separated_by);
      the_result : text_array(1..num_rows);
   begin
      for item in 1 .. num_rows loop
         the_result(item) := Component(of_the_string => from_string, 
                                     at_position => item,
                                     separated_by => separated_by);
      end loop;
      return the_result;
   end Disassemble;

begin
   null;
end Strings_Functions;