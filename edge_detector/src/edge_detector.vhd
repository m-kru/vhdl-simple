-- SPDX-License-Identifier: MIT
-- https://github.com/m-kru/vhdl-simple
-- Copyright (c) 2021 Michał Kruszewski

library ieee;
   use ieee.std_logic_1164.all;


-- Edge_Detector is a synchronous edge detector.
entity Edge_Detector is
   generic (
      WIDTH : positive;
      INIT_PREVIOUS : std_logic := '0';
      REGISTER_OUTPUTS : boolean := true
   );
   port (
      clk_i     : in  std_logic;
      clk_en_i  : in  std_logic := '1';
      d_i       : in  std_logic_vector(WIDTH - 1 downto 0);
      e_o       : out std_logic_vector(WIDTH - 1 downto 0); -- Edge detected.
      r_o       : out std_logic_vector(WIDTH - 1 downto 0); -- Rising edge detected.
      f_o       : out std_logic_vector(WIDTH - 1 downto 0)  -- Falling edge detected.
   );
end entity;


architecture rtl of Edge_Detector is

   signal previous_data : std_logic_vector(WIDTH - 1 downto 0) := (others => INIT_PREVIOUS);

   signal e : std_logic_vector(WIDTH - 1 downto 0);
   signal r : std_logic_vector(WIDTH - 1 downto 0);
   signal f : std_logic_vector(WIDTH - 1 downto 0);

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
      e <= (others => '0');
      r <= (others => '0');
      f <= (others => '0');

      for i in d_i'range loop
         if previous_data(i) = '0' and d_i(i) = '1' then
            r(i) <= '1';
            e(i) <= '1';
         end if;

         if previous_data(i) = '1' and d_i(i) = '0' then
            f(i) <= '1';
            e(i) <= '1';
         end if;
      end loop;
   end process;


   output_registers : if REGISTER_OUTPUTS generate

      process (clk_i) is
      begin
         if rising_edge(clk_i) then
            if clk_en_i = '1' then
               e_o <= e;
               r_o <= r;
               f_o <= f;
            end if;
         end if;
      end process;

   else generate

      e_o <= e;
      r_o <= r;
      f_o <= f;

   end generate;

end architecture;
