-- SPDX-License-Identifier: MIT
-- https://github.com/m-kru/vhdl_simple
-- Copyright (c) 2021 Michał Kruszewski

library ieee;
   use ieee.std_logic_1164.all;

-- register_chain is a simple chain of registers.
--
-- It can be used for multiple purposes such as registering
-- combinatorial signals (G_STAGES = 1) or adjusting delays.
--
-- Setting G_STAGES to 0 is not possible.
entity register_chain is
   generic (
      G_STAGES      : positive  := 1;
      G_WIDTH       : positive  := 1;
      G_INIT_VALUE  : std_logic := '0';
      G_RESET_VALUE : std_logic := '0'
   );
   port (
      clk_i    : in  std_logic;
      clk_en_i : in  std_logic := '1';
      rst_i    : in  std_logic := '0';
      d_i      : in  std_logic_vector(G_WIDTH - 1 downto 0);
      q_o      : out std_logic_vector(G_WIDTH - 1 downto 0) := (others => G_INIT_VALUE)
   );
end entity;

architecture rtl of register_chain is

   type t_chain is array (0 to G_STAGES - 1) of std_logic_vector(G_WIDTH - 1 downto 0);

   signal chain : t_chain := (others => (others => G_INIT_VALUE));

begin

   process (clk_i) is
   begin
      if rising_edge(clk_i) and clk_en_i = '1' then
         for i in 0 to G_STAGES - 1 loop
            if i = 0 then
               chain(0) <= d_i;
            else
               chain(i) <= chain(i - 1);
            end if;
         end loop;

         if rst_i = '1' then
            for i in 0 to G_STAGES - 1 loop
               chain(i) <= (others => G_RESET_VALUE);
            end loop;
         end if;
      end if;
   end process;

   q_o <= chain(G_STAGES - 1);

end architecture;
