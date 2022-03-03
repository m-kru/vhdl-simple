-- SPDX-License-Identifier: MIT
-- https://github.com/m-kru/vhdl-simple
-- Copyright (c) 2021 Michał Kruszewski

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   use ieee.math_real.ceil;
   use ieee.math_real.log2;

-- MAX_PULSE_WIDTH is the maximum width of the pulse.
-- It implies the width of the width_i port.
entity Dynamic_Pulse_Generator is
   generic (
      MAX_PULSE_WIDTH : positive
   );
   port (
      clk_i    : in  std_logic;
      clk_en_i : in  std_logic := '1';
      width_i  : in  unsigned(integer(ceil(log2(real(MAX_PULSE_WIDTH)))) - 1 downto 0);
      stb_i    : in  std_logic;
      q_o      : out std_logic := '0'
   );
end entity;


architecture rtl of Dynamic_Pulse_Generator is

   signal counter : natural range 0 to (MAX_PULSE_WIDTH - 1) := 0;

begin

   process (clk_i) is
   begin
      if rising_edge(clk_i) then
         if clk_en_i = '1' then
            if counter > 0 then
               q_o <= '1';
               counter <= counter - 1;
            else
               q_o <= '0';
            end if;

            if stb_i = '1' and to_integer(width_i) > 0 then
               q_o <= '1';
               counter <= to_integer(width_i) - 1;
            end if;
         end if;
      end if;
   end process;

end architecture;
