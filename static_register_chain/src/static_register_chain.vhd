-- SPDX-License-Identifier: MIT
-- https://github.com/m-kru/vhdl-simple
-- Copyright (c) 2021 Michał Kruszewski

library ieee;
   use ieee.std_logic_1164.all;

-- Static_Register_Chain is a simple static chain of registers.
--
-- It can be used for multiple purposes such as registering
-- combinatorial signals (LENGTH = 1) or adjusting delays.
--
-- Setting LENGTH to 0 is not possible, as it makes no sense.
entity Static_Register_Chain is
   generic (
      LENGTH      : positive  := 1;
      WIDTH       : positive;
      INIT_VALUE  : std_logic := '0';
      RESET_VALUE : std_logic := '0'
   );
   port (
      clk_i    : in  std_logic;
      clk_en_i : in  std_logic := '1';
      rst_i    : in  std_logic := '0';
      d_i      : in  std_logic_vector(WIDTH - 1 downto 0);
      q_o      : out std_logic_vector(WIDTH - 1 downto 0) := (others => INIT_VALUE)
   );
end entity;

architecture rtl of Static_Register_Chain is

   type t_chain is array (0 to LENGTH - 1) of std_logic_vector(WIDTH - 1 downto 0);

   signal chain : t_chain := (others => (others => INIT_VALUE));

begin

   process (clk_i) is
   begin
      if rising_edge(clk_i) then
         if clk_en_i = '1' then
            for i in 0 to LENGTH - 1 loop
               if i = 0 then
                  chain(0) <= d_i;
               else
                  chain(i) <= chain(i - 1);
               end if;
            end loop;

            if rst_i = '1' then
               for i in 0 to LENGTH - 1 loop
                  chain(i) <= (others => RESET_VALUE);
               end loop;
            end if;
         end if;
      end if;
   end process;

   q_o <= chain(LENGTH - 1);

end architecture;
