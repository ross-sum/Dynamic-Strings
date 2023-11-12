   -----------------------------------------------------------------------
--                                                                   --
--                   S T R I N G S _ F U N C T I O N S               --
--                                                                   --
--                            $Revision: 1.2 $                       --
--                                                                   --
--  Copyright (C) 1999,2001, 2021  Hyper Quantum Pty Ltd.            --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This package provides some string manipulation capabilities for  --
--  the strings library.                                             --
--                                                                   --
--  Version History:                                                 --
--  $Log: strings_functions.ads,v $
--  Revision 1.1  2001/04/29 01:16:13  ross
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
with dStrings;  use dStrings;
package Strings_Functions is

   type text_array   is array (positive range <>) of text;
   type string_array is array (positive range <>,
   positive range <>) of wide_character;

   function Left_Trim (the_string : text; 
                       of_character : wide_character := ' ') return text;
      -- Trim characters (usually spaces) from the left hand side
   function Right_Trim (the_string : text; 
                        of_character : wide_character := ' ') return text;
      -- Trim characters (usually spaces) from the right hand side
   function Trim (the_string : text; 
                  of_character : wide_character := ' ') return text;
      -- Trim characters (usually spaces) from both sides of the 
      -- string.
   function Component(of_the_string : in text; 
                      at_position : in positive := 1;
                      separated_by : in wide_character := ';') return text;
      -- Get the component from a string where the components are
      -- separated by the specified character.
   function Count(the_item : in wide_character := ';'; 
                  in_the_string : in text) return natural;
      -- Get the total count of the specified character (i.e. 'the_item') in
      -- the string.
   function Component_Count(of_the_string : in text; 
                            separated_by : in wide_character := ';') 
    return positive;
      -- Return the number of elements, which are separated by the
      -- specified seperator.
   function Assemble(from_strings : in text_array;
                     separated_by : in wide_character := ';') return text;
      -- Create a string that contains all the components in the
      -- array of strings with each component separated by the
      -- specified character.
   function Assemble(from_strings : in string_array;
                     separated_by : in wide_character := ';') return text;
      -- Create a string that contains all the components in the
      -- array of strings with each component separated by the
      -- specified character.
   function Disassemble(from_string : in text;
                        separated_by : in wide_character := ';')
    return text_array;
      -- Create an array that contains all the components in the
      -- text, breaking it apart with each component separated by the
      -- specified character.

end Strings_Functions;