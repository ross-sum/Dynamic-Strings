------------------------------------------------------------------------------
--                                                                          --
--                         GNAT COMPILER COMPONENTS                         --
--                                                                          --
--                G S T R I N G S   O S _ C O N S T A N T S                 --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--          Copyright (C) 2000-2015, Free Software Foundation, Inc.         --
--          Copyright (C) 2020, Hyper Quantum Pty ltd.                      --
--                                                                          --
-- Hyper Quantum took a sub-section of the FSF GNAT.OS_Constants to use  in --
-- its  dStrings units.  This is to avoid a compiler warning, which  is  an --
-- issue when making a program under gps.                                   --
--                                                                          --
-- GNAT is free software;  you can  redistribute it  and/or modify it under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  GNAT is distributed in the hope that it will be useful, but WITH- --
-- OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE.                                     --
--                                                                          --
-- As a special exception under Section 7 of GPL version 3, you are granted --
-- additional permissions described in the GCC Runtime Library Exception,   --
-- version 3.1, as published by the Free Software Foundation.               --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
-- GNAT was originally developed  by the GNAT team at  New York University. --
-- Extensive contributions were provided by Ada Core Technologies Inc.      --
--                                                                          --
------------------------------------------------------------------------------

pragma Style_Checks ("M32766");
--  Allow long lines

--  This package provides target dependent definitions of constant for use
--  by the dStrings serial communication library.

with Interfaces.C;
package OS_Constants is

   pragma Pure;

   ----------------------
   -- Terminal control --
   ----------------------

   TCSANOW                       : constant := 0;           --  Immediate
   TCIFLUSH                      : constant := 0;           --  Flush input
   IXON                          : constant := 1024;        --  Output sw flow control
   CLOCAL                        : constant := 2048;        --  Local
   CRTSCTS                       : constant := 2147483648;  --  Output hw flow control
   CREAD                         : constant := 128;         --  Read
   CS5                           : constant := 2#0000000000#; -- (0 ) 5 data bits
   CS6                           : constant := 2#0000010000#; -- (16) 6 data bits
   CS7                           : constant := 2#0000100000#; -- (32) 7 data bits
   CS8                           : constant := 2#0000110000#; -- (48) 8 data bits
   CSTOPB                        : constant := 2#0001000000#; -- (64) 2 stop bits
   PARENB                        : constant := 2#0100000000#; -- (256) Parity enable
   PARODD                        : constant := 2#1000000000#; -- (512) Parity odd
   B0                            : constant := 0;          --  0 bps
   B50                           : constant := 1;          --  50 bps
   B75                           : constant := 2;          --  75 bps
   B110                          : constant := 3;          --  110 bps
   B134                          : constant := 4;          --  134 bps
   B150                          : constant := 5;          --  150 bps
   B200                          : constant := 6;          --  200 bps
   B300                          : constant := 7;          --  300 bps
   B600                          : constant := 8;          --  600 bps
   B1200                         : constant := 9;          --  1200 bps
   B1800                         : constant := 10;         --  1800 bps
   B2400                         : constant := 11;         --  2400 bps
   B4800                         : constant := 12;         --  4800 bps
   B9600                         : constant := 13;         --  9600 bps
   B19200                        : constant := 14;         --  19200 bps
   B38400                        : constant := 15;         --  38400 bps
   B57600                        : constant := 4097;       --  57600 bps
   B115200                       : constant := 4098;       --  115200 bps
   B230400                       : constant := 4099;       --  230400 bps
   B460800                       : constant := 4100;       --  460800 bps
   B500000                       : constant := 4101;       --  500000 bps
   B576000                       : constant := 4102;       --  576000 bps
   B921600                       : constant := 4103;       --  921600 bps
   B1000000                      : constant := 4104;       --  1000000 bps
   B1152000                      : constant := 4105;       --  1152000 bps
   B1500000                      : constant := 4106;       --  1500000 bps
   B2000000                      : constant := 4107;       --  2000000 bps
   B2500000                      : constant := 4108;       --  2500000 bps
   B3000000                      : constant := 4109;       --  3000000 bps
   B3500000                      : constant := 4110;       --  3500000 bps
   B4000000                      : constant := 4111;       --  4000000 bps
   
end OS_Constants;
