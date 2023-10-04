-----------------------------------------------------------------------
--                                                                   --
--                          U  S T R I N G S                         --
--                                                                   --
--                          $Revision: 1.0 $                         --
--                                                                   --
--  Copyright (C) 1999,2001  Hyper Quantum Pty Ltd.                  --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  package  provides dynamic strings capabilities.   It  was  --
--  written  quite some time ago and oneday I will convert it  over  --
--  to use the supplied Ada.Strings.Unbounded package.  I will also  --
--  convert my programs over at that point.                          --
--                                                                   --
--  Version History:                                                 --
--  $Log$                                                            --
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

with System;  -- for long_integer/long_float
with Ada.Characters.Handling;  use Ada.Characters.Handling;
with Ada.Strings;
-- with Ada.Finalization; use Ada.Finalization;
-- with Ada.Strings.Wide_Unbounded;

package body dStrings is
   use Ada.Strings.Wide_Unbounded;

   -- subtype text is Ada.Strings.Wide_Unbounded.Unbounded_Wide_String;
   -- subtype text is text;

   -- string_overflow_error, string_underflow_error : EXCEPTION;
   -- Empty_String : EXCEPTION;
   -- No_Number    : EXCEPTION;

   zero   : constant wide_character := '0';
   nine   : constant wide_character := '9';
   period : constant wide_character := '.';
   blank  : constant wide_character := ' ';
   minus  : constant wide_character := '-';

   function Value(of_string : in text) return string is
   -- converts a text into a string
   begin
      if Length(of_string) > 0 
      then  -- there is some data in the string
         return To_String(To_Wide_String(of_string));
      else  -- no data in the string, so return the empty string
         return "";
      end if;
   end Value;

   function Value(from : in string)     return text is
   -- converts a string into a text
   begin
      return To_Unbounded_Wide_String(To_Wide_String(from));
   end Value;

   -- function Value(of_string : in text) return wide_string
   -- renames Ada.Strings.Wide_Unbounded.To_Wide_String;
   -- converts a text into a wide_string

   -- function Value_From_Wide(from_wide : in wide_string) return text
   -- renames Ada.Strings.Wide_Unbounded.To_Unbounded_Wide_String;
   -- converts an wide_string into a text

   -- function Length(str : in text) return natural
   -- renames Ada.Strings.Wide_Unbounded.Length;

   function Is_Empty(t : in text) return boolean is
   begin
      return Length(t) = 0;
   end Is_Empty;

   function Element(of_string : in text; at_position : in positive)
   return character is
   begin
      return character'Val(wide_character'Pos(
         Wide_Element(of_string, at_position)));
   end Element;

   -- function Wide_Element(of_string : in text; 
   -- at_position : in positive)
   -- return wide_character
   -- renames Ada.Strings.Wide_Unbounded.Element;
   -- gets the element at the position in the string specified

   function to_text(s: string;    max: positive) return text is
   begin
      return to_text(To_Wide_String(s));
   end to_text;

   function to_text(c: character; max: positive) return text is
      wide_str_char : wide_string(1..1) := 
                         (others=>wide_character'Val(character'Pos(c)));
   begin
      return To_Unbounded_Wide_String(wide_str_char);
   end to_text;

   -- function to_text(from: string               ) return text is
   -- begin
      -- return Value(from);
   -- end to_text;
   -- function to_text(from: character            ) return text is
      -- wide_str_char : wide_string(1..1) := 
      -- (others=>wide_character'Val(character'Pos(from)));
   -- begin
      -- return To_Unbounded_Wide_String(wide_str_char);
   -- end to_text;
   -- function to_text(from_wide: wide_string     ) return text
   -- renames Ada.Strings.Wide_Unbounded.To_Unbounded_Wide_String;

   function to_text(from_wide: wide_character) return text is
      wide_str_char : wide_string(1..1) := (others=>from_wide);
   begin
      return To_Unbounded_Wide_String(wide_str_char);
   end to_text;

   function Pos(pattern, source : in text; 
                starting_at : positive := 1) return integer is
      result : natural;
   begin
      if starting_at = 1 then
         return Index(source, Value(pattern));
      elsif starting_at <= Length(source) then
         result := Index(Ada.Strings.Wide_Unbounded.
                        Tail(source, Length(source)-starting_at+1),
                      Value(pattern));
         if result > 0
         then
            return result + starting_at - 1;
         else
            return 0;
         end if;
      else
         return 0;
      end if;
   end Pos;

   procedure Clear(str : out text) is
   -- Empty the string.  Generally, the procedure should be used
   -- where the string contains data, as this process ensures it
   -- has been properly freed.
   begin
      str := Null_Unbounded_Wide_String;
   end Clear;

   function  Clear return text is
   -- Return an empty string.  This function should only be used
   -- where an empty string is required as a parameter, not to
   -- empty a string.
   begin
      return Null_Unbounded_Wide_String;
   end Clear;

   procedure Delete(target : in out text; start : in positive; 
                    size : in natural) is
   begin
      if size > 0 then
         Ada.Strings.Wide_Unbounded.Delete
            (target, start, start + size - 1);
      -- else the right size anyway
      end if;
   end Delete;

   -- function "&"(str1, str2 : in text) return text
   -- renames Ada.Strings.Wide_Unbounded."&";

   function "&"(src_string : in text; src_char : in character) return text is
   begin
      return Ada.Strings.Wide_Unbounded."&"(src_string, 
         wide_character'Val(character'Pos(src_char)));
   end "&";

   function "&"(src_char : in character; src_string : in text) return text is
   begin
      return Ada.Strings.Wide_Unbounded."&"( 
         wide_character'Val(character'Pos(src_char)), src_string);
   end "&";

   -- byte concatenation into the specified string
   -- function Cat(src_string : in text; src_char : in wide_character) 
   -- return text
   -- renames Ada.Strings.Wide_Unbounded."&";

   -- function Cat(src_char : in wide_character; src_string : in text) 
   -- return text
   -- renames Ada.Strings.Wide_Unbounded."&";

   function As_Text(item : in text) return text is
      -- used to avoid problems where data type is not determinate.
   begin
      return item;
   end As_Text;

   -- string comparison functions
   -- function "=" (str_1, str_2 : in text) return boolean
   -- renames Ada.Strings.Wide_Unbounded."=";

   -- function ">" (str_1, str_2 : in text) return boolean
   -- renames Ada.Strings.Wide_Unbounded.">";

   -- function "<" (str_1, str_2 : in text) return boolean
   -- renames Ada.Strings.Wide_Unbounded."<";

   -- function ">="(str_1, str_2 : in text) return boolean
   -- renames Ada.Strings.Wide_Unbounded.">=";

   -- function "<="(str_1, str_2 : in text) return boolean
   -- renames Ada.Strings.Wide_Unbounded."<=";

   -- string input/output routines
   function Put_Into_String(item : in long_integer) return text is
   
      radix : constant long_integer := 10;
      number_string, unit, blank_str : text;
      strip_number : long_integer;
      negative : boolean;
   begin
      Clear(blank_str);
      if item = 0
      then
         Clear(number_string);
         number_string := "&"(number_string, zero);
      else
         strip_number := item;
       -- initialise the temporary string, number_string
         Clear(number_string);
         if strip_number < 0
         then    -- negative number
            negative := true;
            strip_number := abs(strip_number);
         else
            negative := false;
         end if;
         -- place numbers on the right hand side of the decimal 
         -- point into the temporary string, number_string 
         -- (NB: actually no decimal point)
         while strip_number > 0 loop
            unit := "&"(blank_str,
                        wide_character'Val((strip_number - 
                                            (strip_number / radix) * radix) +
                                           wide_character'Pos(zero)));
            strip_number := strip_number / radix;
            number_string := "&"(unit, number_string);
         end loop;
         if negative
         then
            unit := "&"(blank_str, minus);
            number_string := "&"(unit, number_string);
         end if;
      end if;	-- check for a zero (0)
   -- return the result
      return number_string;
   end Put_Into_String;

   function Put_Into_String(item : in integer)     return text is
   begin
      return Put_Into_String(long_integer(item));
   end Put_Into_String;
   
   function Put_Into_String(item : in long_float;
                            trim_to: integer := -1)  return text is
      radix          : constant long_float := 10.0;
      decimal_places : constant integer    := 4;  -- minimum decimal places
   
      number_string : text;
      strip_number  : long_float;
      power         : integer;
      digit         : long_integer;
   
      function Convert_Number(data : in long_float) return long_integer is
      -- truncates the number
         element : long_integer;
      begin
         element := long_integer(data);
         if long_float(element) > data
         then
            element := long_integer(data) - 1;
         end if;
         return element;
      end Convert_Number;
   
   begin   -- Put Into String
      strip_number := item;
      -- initialise the temporary string, number_string
      Clear(number_string);
      if strip_number < 0.0
      then
         number_string := "&"(number_string, minus);
         strip_number  := abs(strip_number);
      end if;
      -- calculate the numbers to the left of the decimal point
      power := 0;
      while strip_number >= 1.0 loop
         power := power + 1;
         strip_number := strip_number / radix;
      end loop;
      strip_number := abs(item);
      -- place numbers on the left hand side of the decimal point 
      -- into the temporary string, number_string
      if power = 0 then
         number_string := to_text('0',1);
      end if;
      while power > 0 loop
         digit := Convert_Number(strip_number/(radix ** (power - 1)));
         number_string:="&"(number_string,
                           wide_character'Val(wide_character'Pos(zero)+digit));
         if strip_number >= 1.0
         then  -- not dealing with 10's, 100's, or 1000's, etc.
            strip_number := strip_number -
                            long_float(digit) * (radix ** (power - 1));
         end if;
         power := power - 1;
      end loop;
      -- place numbers on the right hand side (down to the value 
      -- of epsilon) into the temporary string, number_string
      number_string := "&"(number_string, period);
      power := 1;
      while (power < system.max_digits and strip_number > 0.0)
      or else power < decimal_places loop
         strip_number  := strip_number * radix;
         digit         := Convert_Number(strip_number);
         number_string := "&"(number_string,
                           wide_character'Val(wide_character'Pos(zero)+digit));
         strip_number  := strip_number - long_float(digit);
         power         := power + 1;
         if trim_to >= 0 and then power > trim_to then
            exit;
         end if;
      end loop;
      -- return the result
      return number_string;
   end Put_Into_String;

   function Put_Into_String(item : in float;
                            trim_to: integer := -1) return text is
   begin
      return Put_Into_String(long_float(item), trim_to);
   end Put_Into_String;

   function Get_Long_Integer_From_String(item : in text) return long_integer is
      radix : constant long_integer := 10;
      data            : long_integer;
      integer_string  : text;
      temp_string     : text;
      negative_number : boolean;
   begin
      integer_string := item;
   -- eliminate leading blanks
      while (Wide_Element(integer_string, 1) = blank) and
            (Length(integer_string) > 0) loop
         Delete(integer_string, 1, 1);
      end loop; -- extract leading blanks
   -- check for empty string error
      if Length(integer_string) = 0
      then
         raise Empty_String;
      end if;
   -- check for negative number
      if Wide_Element(integer_string, 1) = minus
      then
         negative_number := true;
         Delete(integer_string, 1, 1);
      else
         negative_number := false;
      end if;
   -- extract the number from the input string
   -- load the integer into the temporary string
      Clear(temp_string);
      while Length(integer_string) > 0 and then 
            Wide_Element(integer_string, 1) in zero..nine loop
         temp_string := Ada.Strings.Wide_Unbounded.
                          "&"(temp_string, Wide_Element(integer_string, 1));
         Delete(integer_string, 1, 1);
      end loop; -- while a valid numeral
   -- check for valid data
      if Length(temp_string) = 0
      then
         raise No_Number;
      end if;
   -- extract the integer from the temporary string
      data := 0;
      while Length(temp_string) > 0 loop
         data := data * radix + 
            (wide_character'Pos(Wide_Element(temp_string, 1)) -
             wide_character'Pos(Zero));
         Delete(temp_string, 1, 1);
      end loop;
      if negative_number
      then
         data := -data;
      end if;
      return data;
   end Get_Long_Integer_From_String;

   function Get_Integer_From_String (item : in text) return integer is
   begin
      return integer(Get_Long_Integer_From_String(item));
   end Get_Integer_From_String;

   function Get_Long_Float_From_String  (item : in text) 
   return long_float is
      radix           : constant long_float := 10.0;
      data            : long_float;
      divisor         : long_float;
      temp_string, 
      float_string    : text;
      negative_number : boolean;
   begin
      float_string := item;
   -- eliminate leading blanks
      while (Length(float_string) > 0)  and then 
            (Wide_Element(float_string, 1) = blank) loop
         Delete(float_string, 1, 1);
      end loop; -- eliminate leading blanks
   -- check for empty string error
      if Length(float_string) = 0
      then
         raise Empty_String;
      end if;
   -- check for negative number
      if Wide_Element(float_string, 1) = minus
      then
         negative_number := true;
         Delete(float_string, 1, 1);
      else
         negative_number := false;
      end if;
   -- extract the number from the input string
   -- load the number into the temporary string
      Clear(temp_string);
      while (Length(float_string) > 0) and then
            ((Wide_Element(float_string, 1) in zero..nine) or
             (Wide_Element(float_string, 1) = period)) loop
         temp_string := Ada.Strings.Wide_Unbounded.
                           "&"(temp_string, Wide_Element(float_string, 1));
         Delete(float_string, 1, 1);
      end loop; -- get valid number
   -- check for valid data
      if Length(temp_string) = 0
      then
         raise No_Number;
      end if;
   -- extract the number from the temporary string
      data := 0.0;
      while (Length(temp_string) > 0) and then
            (Wide_Element(temp_string, 1) /= period) loop
         data := data * radix +
                 long_float(wide_character'Pos(Wide_Element(temp_string, 1)) -
                            wide_character'Pos(Zero));
         Delete(temp_string, 1, 1);      -- delete the digit
      end loop;
      divisor := 1.0 / radix;
      if Length(temp_string) > 0 and then 
         Wide_Element(temp_string, 1) = period
      then
         Delete(temp_string, 1, 1);    -- delete the period
         while (Length(temp_string) > 0) loop
            data := data + 
                    long_float(wide_character'Pos(Wide_Element(temp_string,1))-
                               wide_character'Pos(Zero)) * divisor;
            divisor := divisor / radix;
            Delete(temp_string, 1, 1);  -- delete the digit
         end loop;
      end if;
      if negative_number
      then
         data := -data;
      end if;
      return data;
   end Get_Long_Float_From_String;

   function Get_float_From_String (item : in text) return float is
   begin
      return float(Get_Long_Float_From_String(item));
   end Get_Float_From_String;

   procedure Delete_Number_From_String(str : in out text) is
   -- delete the number at the start of the string. Will raise an 
   -- Empty_String error, but not a No_Number error
   begin
   -- eliminate leading blanks
      while (Wide_Element(str, 1) = blank) and (Length(str) > 0) loop
         Delete(str, 1, 1);
      end loop; -- extract leading blanks
   -- check for empty string error
      if Length(str) = 0
      then
         raise Empty_String;
      end if;
   -- check for negative number
      if Wide_Element(str, 1) = minus
      then
         Delete(str, 1, 1);
      end if;
   -- extract the number from the input string
      while (Length(str) > 0) and then
      (Wide_Element(str, 1) in zero..nine or Wide_Element(str, 1) = period)
      loop
         Delete(str, 1, 1);
      end loop; -- while a valid numeral
   end Delete_Number_From_String;

   -- other input/addition and alteration functions
   procedure Assign(the_string : in text; to_string : in out text)
   is
   
   -- Used to perform a shallow copy.  Note that the two strings, 
   -- 'the_string' and 'to_string' must be of the same sub-type.
   -- NOW PERFORMS a straight assignment (to_string := the_string).
   begin
      to_string := the_string;
   end Assign;
   procedure set(object : in out text; to_value : in text) is
   begin
      object := to_value;
   end Set;

   procedure set(object : in out text; to_value : in string) is
   begin
      object := 
         To_Unbounded_Wide_String(To_Wide_String(to_value));
   end Set;

   procedure set(object : in out text; to_value : in character) is
   begin
      object := To_Text(To_Wide_Character(to_value));
   end Set;

   procedure set_to_wide(object : in out text; 
   to_value: in wide_string) is
   begin
      object := To_Text(to_value);
   end Set_To_Wide;

   procedure append(tail : in text;     to : in out text) is
   begin
      Ada.Strings.Wide_Unbounded.Append(to, tail);
   end append;

   procedure append(tail : in string;    to : in out text) is
   begin
      Ada.Strings.Wide_Unbounded.Append
         (to, To_Wide_String(tail));
   end append;

   procedure append(tail : in character; to : in out text) is
      tail_str : wide_string(1..1) := 
      (others=>wide_character'Val(character'Pos(tail)));
   begin
      Ada.Strings.Wide_Unbounded.Append(to, tail_str);
   end append;

   procedure append(wide_tail : in wide_character; to : in out text) is
   begin
      Ada.Strings.Wide_Unbounded.Append(to, wide_tail);
   end append;

   procedure append(wide_tail : in wide_string; to : in out text) is
   begin
      Ada.Strings.Wide_Unbounded.Append(to, wide_tail);
   end append;

   procedure amend(object : in out text; 
                   by     : in text;          position : in positive) is
   -- Substitute all characters in object starting at position 
   -- for the length of by with the characters of by.
   begin
      Replace_Slice(object, position, position + Length(by) + 1,
                    To_Wide_String(by));
   end Amend;

   procedure amend(object : in out text; 
   by     : in wide_string;    position : in positive) is
   begin
      Replace_Slice(object, position, position + by'Length + 1,
         by);
   end Amend;

   procedure amend(object : in out text; 
   by     : in wide_character; position : in positive) is
      by_string : wide_string(1..1) := (others=>by);
   begin
      Replace_Slice(object, position, position, by_string);
   end Amend;

   function locate(fragment : text;        within : text) return natural is
      result : natural := 0;
   begin
      result := Index(within, To_Wide_String(fragment));
      return result;
      exception
         when Ada.Strings.Pattern_Error =>
            return 0;  -- pattern clearly doesn't exist
   end Locate;

   function locate(fragment : string;      within : text) return natural is
   begin
      return Index(within, To_Wide_String(fragment));
   end Locate;

   function locate(fragment : character;   within : text) return natural is
      fragment_string : wide_string(1..1) :=  
                         (others=>wide_character'Val(character'Pos(fragment)));
   begin
      return Index(within, fragment_string);
   end Locate;

   function locate(wide_fragment : wide_string; within: text) return natural is
      result : natural := 0;
   begin
      result := Index(within, wide_fragment);
      return result;
      exception
         when Ada.Strings.Pattern_Error =>
            return 0;  -- pattern clearly doesn't exist
   end Locate;

   function Sub_String(from : text; starting_at : positive; 
                       for_characters : natural) return text is
   -- return a string containing the specified section of characters
   -- from the requested source string.
   begin
      if for_characters > 0 and starting_at <= Length(from)
      then
         if (starting_at + for_characters - 1) <= Length(from)
         then
            return To_Unbounded_Wide_String(Slice(from, starting_at, 
                                            starting_at + for_characters - 1));
         else
            return To_Unbounded_Wide_String(Slice(from, starting_at,
                                                  Length(from)));
         end if;
      else
         return Null_Unbounded_Wide_String;
      end if;
   end Sub_String;

   -- Case conversion

-- Case conversion
   type case_type is (upper_case, lower_case);

   procedure Convert_Case(on_object : in out text; with_case : in case_type) is
      from_char,
      last_char,
      to_char    : wide_character;
   begin
      if with_case = upper_case then
         from_char := 'a';
         last_char := 'z';
         to_char   := 'A';
      else
         from_char := 'A';
         last_char := 'Z';
         to_char   := 'a';
      end if;
      for character_number in 1 .. Length(on_object) loop
         if Wide_Element(on_object, character_number) in
            from_char .. last_char
         then
            Replace_Element(on_object, character_number,
                            wide_character'Val(wide_character'Pos(
                                  Wide_Element(on_object, character_number)) -
                                                wide_character'Pos(from_char)+
                                               wide_character'Pos(to_char)));
         end if;
      end loop;
   end Convert_Case;

   procedure Upper_Case(object : in out text) is
   -- Use this when working with a text object
   begin
      if Length(object) > 0 then  -- something to convert
         Convert_Case(object, with_case => upper_case);
      end if;
   end Upper_Case;

   function Upper_Case(object : in text) return text is
   -- Use in equations where original text needs preserving
      temp_string : text;
   begin
      Set(temp_string, object);
      Upper_Case(temp_string);
      return temp_string;
   end Upper_Case;

   procedure Lower_Case(object : in out text) is
   -- Use this when working with a text object
   begin
      if Length(object) > 0 then  -- something to convert
         Convert_Case(object, with_case => lower_case);
      end if;
   end Lower_Case;

   function Lower_Case(object : in text) return text is
   -- Use in equations where original text needs preserving
      temp_string : text;
   begin
      Set(temp_string, object);
      Lower_Case(temp_string);
      return temp_string;
   end Lower_Case;

   function To_UTF8_String(item : in text) return string is
      result : text := Null_Unbounded_Wide_String;
      char : wide_character;
      data : character;
   begin
      for at_position in 1 .. Length(item) loop
         char:= Wide_Element(item, at_position);
         if Wide_Character'Pos(char) < 2#1000_0000# then
            result := result & Character'Val(Wide_Character'Pos(char));
         elsif Wide_Character'Pos(char) < 2#0000_1000_0000_0000# then
            data := Character'Val(2#110_00000# +
               (Wide_Character'Pos(char) / 16#40#));
            result := result & data;
            data := Character'Val(2#10_000000# +
               (Wide_Character'Pos(char) rem 16#40#));
            result := result & data;
         else
            data := Character'Val(2#1110_0000# +
               (Wide_Character'Pos(char) / 16#1000#));
            result := result & data;
            data := Character'Val(2#10_000000# +
               ((Wide_Character'Pos(char) rem 16#1000#)
               / 16#40#));
            result := result & data;
            data := Character'Val(2#10_000000# +
               (Wide_Character'Pos(char) rem 16#40#));
            result := result & data;
         end if;
      end loop;
      return To_String(To_Wide_String(result));
   end To_UTF8_String;

begin
   null;
end dStrings;
