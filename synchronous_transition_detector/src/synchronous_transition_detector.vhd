-- SPDX-License-Identifier: MIT
-- https://github.com/m-kru/vhdl-simple
-- Copyright (c) 2021 Michał Kruszewski

library ieee;
   use ieee.std_logic_1164.all;


entity synchronous_transition_detector is
   generic (
      WIDTH : positive;
      INIT_PREVIOUS : std_logic := '0';
      REGISTER_OUTPUTS : boolean := true
   );
   port (
      clk_i         : in  std_logic;
      clk_en_i      : in  std_logic := '1';
      d_i           : in  std_logic_vector(WIDTH - 1 downto 0);
      transition_o  : out std_logic_vector(WIDTH - 1 downto 0);
      zero_to_one_o : out std_logic_vector(WIDTH - 1 downto 0);
      one_to_zero_o : out std_logic_vector(WIDTH - 1 downto 0)
   );
end entity;


architecture rtl of synchronous_transition_detector is

   signal previous_data : std_logic_vector(WIDTH - 1 downto 0) := (others => INIT_PREVIOUS);

   signal transition  : std_logic_vector(WIDTH - 1 downto 0);
   signal zero_to_one : std_logic_vector(WIDTH - 1 downto 0);
   signal one_to_zero : std_logic_vector(WIDTH - 1 downto 0);

begin

   latch : process (clk_i) is
   begin
      if rising_edge(clk_i) then
         if clk_en_i = '1' then
            previous_data <= d_i;
         end if;
      end if;
   end process;


   detector : process (all) is
   begin
      transition  <= (others => '0');
      zero_to_one <= (others => '0');
      one_to_zero <= (others => '0');

      for i in d_i'range loop
         if previous_data(i) = '0' and d_i(i) = '1' then
            zero_to_one(i) <= '1';
            transition(i) <= '1';
         end if;

         if previous_data(i) = '1' and d_i(i) = '0' then
            one_to_zero(i) <= '1';
            transition(i) <= '1';
         end if;
      end loop;
   end process;


   output_registers : if REGISTER_OUTPUTS generate

      process (clk_i) is
      begin
         if rising_edge(clk_i) then
            if clk_en_i = '1' then
               transition_o  <= transition;
               zero_to_one_o <= zero_to_one;
               one_to_zero_o <= one_to_zero;
            end if;
         end if;
      end process;

   else generate

      transition_o  <= transition;
      zero_to_one_o <= zero_to_one;
      one_to_zero_o <= one_to_zero;

   end generate;

end architecture;
