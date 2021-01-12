-- SPDX-License-Identifier: MIT
-- https://github.com/m-kru/vhdl_simple
-- Copyright (c) 2021 Michał Kruszewski

library ieee;
   use ieee.std_logic_1164.all;

-- delay_register simply delays the data in clock cycles.
--
-- Setting G_DELAY to 0 is not possible.
entity delay_register is
   generic (
      G_DELAY       : positive  := 1;
      G_WIDTH       : positive  := 32;
      G_INIT_VALUE  : std_logic := 'U';
      G_RESET_VALUE : std_logic := '0'
   );
   port (
      clk_i    : in  std_logic;
      rst_i    : in  std_logic := '0';
      enable_i : in  std_logic := '1';
      d_i      : in  std_logic_vector(G_WIDTH - 1 downto 0);
      q_o      : out std_logic_vector(G_WIDTH - 1 downto 0)
   );
end entity;

architecture rtl of delay_register is

   type t_delay_chain is array (0 to G_DELAY - 1) of std_logic_vector(G_WIDTH - 1 downto 0);

   signal delay_chain : t_delay_chain := (others => (others => G_INIT_VALUE));

begin

   process (clk_i) is
   begin
      if rising_edge(clk_i) then
         if enable_i = '1' then
            for i in 0 to G_DELAY - 1 loop
               if i = 0 then
                  delay_chain(0) <= d_i;
               else
                  delay_chain(i) <= delay_chain(i - 1);
               end if;
            end loop;

            if rst_i = '1' then
               for i in 0 to G_DELAY - 1 loop
                  delay_chain(i) <= (others => G_RESET_VALUE);
               end loop;
            end if;
         end if;
      end if;
   end process;

   q_o <= delay_chain(G_DELAY - 1);

end architecture;
