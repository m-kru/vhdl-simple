-- SPDX-License-Identifier: MIT
-- https://github.com/m-kru/vhdl-simple
-- Copyright (c) 2021 Michał Kruszewski

library ieee;
   use ieee.std_logic_1164.all;

-- Synchronous_Pulse_Catcher can be used to monitor signals and record
-- that there have been any pulses.
--
-- Clearing has higher priority than catching the pulse.
-- This is because the main goal of the Synchronous_Pulse_Catcher is to monitor signals
-- and record that there has been a pulse, not to count the number of pulses.
-- To not miss any pulse a proper clear_mask has to be provided (a mask that
-- clears only these bits of q that are set to '1').
entity Synchronous_Pulse_Catcher is
   generic (
      WIDTH      : positive;
      INIT_VALUE : std_logic := '0';
      REGISTER_OUTPUTS : boolean := true
   );
   port (
      clk_i              : in  std_logic;
      d_i                : in  std_logic_vector(WIDTH - 1 downto 0);
      clear_mask_i       : in  std_logic_vector(WIDTH - 1 downto 0);
      clear_stb_i        : in  std_logic;
      catch_mask_i       : in  std_logic_vector(WIDTH - 1 downto 0) := (others => '1');
      q_mask_i           : in  std_logic_vector(WIDTH - 1 downto 0) := (others => '1');
      q_or_reduce_mask_i : in  std_logic_vector(WIDTH - 1 downto 0) := (others => '1');
      q_o                : out std_logic_vector(WIDTH - 1 downto 0) := (others => INIT_VALUE);
      q_or_reduced_o     : out std_logic := INIT_VALUE
   );
end entity;


architecture rtl of Synchronous_Pulse_Catcher is

   signal q : std_logic_vector(WIDTH - 1 downto 0) := (others => INIT_VALUE);

begin

   process (clk_i) is
   begin
      if rising_edge(clk_i) then
         for i in WIDTH - 1 downto 0 loop
            if d_i(i) = '1' and catch_mask_i(i) = '1' then
               q(i) <= '1';
            end if;
         end loop;

         if clear_stb_i = '1' then
            for i in WIDTH - 1 downto 0 loop
               if clear_mask_i(i) = '1' then
                  q(i) <= '0';
               end if;
            end loop;
         end if;
      end if;
   end process;


   output_registers : if REGISTER_OUTPUTS generate

      process (clk_i) is
      begin
         if rising_edge(clk_i) then
            q_o <= q and q_mask_i;
            q_or_reduced_o <= or(q and q_or_reduce_mask_i);
         end if;
      end process;

   else generate

      q_o <= q and q_mask_i;
      q_or_reduced_o <= or(q and q_or_reduce_mask_i);

   end generate;

end architecture;
