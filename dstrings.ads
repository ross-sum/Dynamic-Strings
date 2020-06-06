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
   -- with Ada.Finalization; use Ada.Finalization;
with Ada.Strings;                use Ada.Strings;
with Ada.Strings.Wide_Unbounded;
with Ada.Strings.Wide_Maps;

package dStrings is

-- TYPE long_float IS DIGITS system.max_digits;
-- TYPE long_integer IS RANGE system.min_int .. system.max_int;
   subtype text is Ada.Strings.Wide_Unbounded.Unbounded_Wide_String;
   subtype ttext is text;

   string_overflow_error, string_underflow_error : EXCEPTION;
   Empty_String : EXCEPTION;
   No_Number    : EXCEPTION;


   function Value(of_string : in text) return string;
   -- converts a text into a string
   function Value(from : in string)     return text;
   -- converts a string into a text
   function Value(of_string : in text) return wide_string
   renames Ada.Strings.Wide_Unbounded.To_Wide_String;
   -- converts a text into a wide_string
   function Value_From_Wide(from_wide : in wide_string) return text
   renames Ada.Strings.Wide_Unbounded.To_Unbounded_Wide_String;
   -- converts an wide_string into a text

   function Length(str : in text) return natural
   renames Ada.Strings.Wide_Unbounded.Length;
   function Is_Empty(t : in text) return boolean;
   function Element(of_string : in text; at_position : in positive)
   return character;
   function Wide_Element(of_string : in text; 
   at_position : in positive)
   return wide_character
   renames Ada.Strings.Wide_Unbounded.Element;
   -- gets the element at the position in the string specified

   -- use type Ada.Strings.Direction;
   subtype Direction is Ada.Strings.Direction;

   function Index(source : in text;
   pattern : in wide_string;
   going   : in Direction := Forward;
   mapping : in Ada.Strings.Wide_Maps.Wide_Character_Mapping :=
   Ada.Strings.Wide_Maps.Identity) return natural
   renames Ada.Strings.Wide_Unbounded.Index;

   function to_text(s: string;    max: positive) return text;
   function to_text(c: character; max: positive) return text;
   -- function to_text(from: string               ) return text;
   -- function to_text(from: character            ) return text;
   function to_text(from_wide: wide_string     ) return text
   renames Ada.Strings.Wide_Unbounded.To_Unbounded_Wide_String;
   function to_text(from_wide: wide_character  ) return text;
   function To_String(from : text) return wide_string
   renames Ada.Strings.Wide_Unbounded.To_Wide_String;

   function Pos(pattern, source : in text; 
   starting_at : positive := 1) return integer;
   procedure Clear(str : out text);
   -- Empty the string.  Generally, the procedure should be used
   -- where the string contains data, as this process ensures it
   -- has been properly freed.
   function  Clear return text;
   -- Return an empty string.  This function should only be used
   -- where an empty string is required as a parameter, not to
   -- empty a string.
   procedure Delete(target : in out text; start : in positive; 
   size : in natural);

   function "&"(str1, str2 : in text) return text
   renames Ada.Strings.Wide_Unbounded."&";
   -- function "&"(src_string : in text; src_char : in character) 
   -- return text;
   -- function "&"(src_char : in character; src_string : in text) 
   -- return text;
   function "&"(src_char : in wide_character; src_string : in text) 
   return text
   renames Ada.Strings.Wide_Unbounded."&";
   function "&"(src_string : in text; src_char : in wide_character) 
   return text
   renames Ada.Strings.Wide_Unbounded."&";
   function "&"(src_text : in text; src_str : in wide_string) 
   return text
   renames Ada.Strings.Wide_Unbounded."&";
   function "&"(src_str : in wide_string; src_text : in text) 
   return text
   renames Ada.Strings.Wide_Unbounded."&";
   function As_Text(item : in text) return text;
   	   -- used to avoid problems where data type is not determinate.
pragma Inline(As_Text);

   -- byte concatenation into the specified string
   function Cat(src_string : in text; src_char : in wide_character) 
   return text
   renames Ada.Strings.Wide_Unbounded."&";
   function Cat(src_char : in wide_character; src_string : in text) 
   return text
   renames Ada.Strings.Wide_Unbounded."&";

   -- string comparison functions
   function "=" (str_1, str_2 : in text) return boolean
   renames Ada.Strings.Wide_Unbounded."=";
   function ">" (str_1, str_2 : in text) return boolean
   renames Ada.Strings.Wide_Unbounded.">";
   function "<" (str_1, str_2 : in text) return boolean
   renames Ada.Strings.Wide_Unbounded."<";
   function ">="(str_1, str_2 : in text) return boolean
   renames Ada.Strings.Wide_Unbounded.">=";
   function "<="(str_1, str_2 : in text) return boolean
   renames Ada.Strings.Wide_Unbounded."<=";

  -- string input/output routines
   function Put_Into_String(item : in long_integer) return text;
   function Put_Into_String(item : in integer)      return text;
   function Put_Into_String(item : in long_float)   return text;
   function Put_Into_String(item : in float)        return text;

   function Get_Long_Integer_From_String(item : in text) 
   return long_integer;
   function Get_Integer_From_String     (item : in text) 
   return integer;
   function Get_Long_Float_From_String  (item : in text) 
   return long_float;
   function Get_float_From_String       (item : in text) 
   return float;

   procedure Delete_Number_From_String(str : in out text);
   -- delete the number at the start of the string. Will raise an 
   -- Empty_String error, but not a No_Number error

   -- other input/addition and alteration functions
   procedure Assign(the_string : in text; to_string : in out text);
   -- Used to perform a shallow copy.  Note that the two strings, 
   -- 'the_string' and 'to_string' must be of the same sub-type.
   -- NOW PERFORMS a straight assignment (to_string := the_string).

   procedure set(object : in out text; to_value : in text);
   procedure set(object : in out text; to_value : in string);
   procedure set(object : in out text; to_value : in character);
   procedure set_to_wide(object : in out text; 
   to_value: in wide_string);

   procedure append(tail : in text;     to : in out text);
   procedure append(tail : in string;    to : in out text);
   procedure append(tail : in character; to : in out text);
   procedure append(wide_tail : in wide_character; 
   to : in out text);
   procedure append(wide_tail : in wide_string; to : in out text);

   procedure amend(object : in out text; 
   by     : in text;          position : in positive);
   -- Substitute all characters in object starting at position 
   -- for the length of by with the characters of by.
   procedure amend(object : in out text; 
   by     : in wide_string;    position : in positive);
   procedure amend(object : in out text; 
   by     : in wide_character; position : in positive);

   function locate(fragment : text;        within : text) 
   return natural;
   function locate(fragment : string;      within : text) 
   return natural;
   function locate(fragment : character;   within : text) 
   return natural;
   function locate(wide_fragment : wide_string; within : text) 
   return natural;

   function Sub_String(from : text; starting_at : positive; 
   for_characters : natural) return text;
   -- return a string containing the specified section of characters
   -- from the requested source string.

   -- Case conversion
   procedure Upper_Case(object : in out text);
   -- Use this when working with a text object
   function Upper_Case(object : in text) return text;
   -- Use in equations where original text needs preserving
   procedure Lower_Case(object : in out text);
   -- Use this when working with a text object
   function Lower_Case(object : in text) return text;
   -- Use in equations where original text needs preserving

   function To_UTF8_String(item : in text) return string;

end dStrings;
