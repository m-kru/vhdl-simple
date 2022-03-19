-- SPDX-License-Identifier: MIT
-- https://github.com/m-kru/vhdl-simple
-- Copyright (c) 2021 Michał Kruszewski

library ieee;
   use ieee.std_logic_1164.all;


entity Synchronous_Edge_Detector is
   generic (
      WIDTH : positive;
      INIT_PREVIOUS : std_logic := '0';
      REGISTER_OUTPUTS : boolean := true
   );
   port (
      clk_i     : in  std_logic;
      clk_en_i  : in  std_logic := '1';
      d_i       : in  std_logic_vector(WIDTH - 1 downto 0);
      edge_o    : out std_logic_vector(WIDTH - 1 downto 0);
      rising_o  : out std_logic_vector(WIDTH - 1 downto 0);
      falling_o : out std_logic_vector(WIDTH - 1 downto 0)
   );
end entity;


architecture rtl of Synchronous_Edge_Detector is

   signal previous_data : std_logic_vector(WIDTH - 1 downto 0) := (others => INIT_PREVIOUS);

   signal edge    : std_logic_vector(WIDTH - 1 downto 0);
   signal rising  : std_logic_vector(WIDTH - 1 downto 0);
   signal falling : std_logic_vector(WIDTH - 1 downto 0);

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
      edge    <= (others => '0');
      rising  <= (others => '0');
      falling <= (others => '0');

      for i in d_i'range loop
         if previous_data(i) = '0' and d_i(i) = '1' then
            rising(i) <= '1';
            edge(i)   <= '1';
         end if;

         if previous_data(i) = '1' and d_i(i) = '0' then
            falling(i) <= '1';
            edge(i)    <= '1';
         end if;
      end loop;
   end process;


   output_registers : if REGISTER_OUTPUTS generate

      process (clk_i) is
      begin
         if rising_edge(clk_i) then
            if clk_en_i = '1' then
               edge_o    <= edge;
               rising_o  <= rising;
               falling_o <= falling;
            end if;
         end if;
      end process;

   else generate

      edge_o    <= edge;
      rising_o  <= rising;
      falling_o <= falling;

   end generate;

end architecture;
