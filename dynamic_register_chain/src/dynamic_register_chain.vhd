-- SPDX-License-Identifier: MIT
-- https://github.com/m-kru/vhdl-simple
-- Copyright (c) 2022 Michał Kruszewski

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   use ieee.math_real.ceil;
   use ieee.math_real.log2;

-- Dynamic_Register_Chain is a simple dynamic chain of registers.
-- Dynamic means that the length of the chain can be configured via port (len_i).
--
-- It can be used for example for dynamic adjustment of delays.
--
-- Setting MAX_LENGTH to 0 is not possible, as it makes no sense.
-- However, when len_i = 0, then q_o mimics d_i immediately (REGISTER_OUTPUTS = false)
-- or after one clock cycle (REGISTER_OUTPUTS = true).
--
-- If REGISTER_OUTPUTS is true, then the q_o is delayed by one extra clock cycle.
-- The longer the chain, the bigger the output multiplexer.
-- Adding register at the output can potentially break the critical path.
entity Dynamic_Register_Chain is
   generic (
      MAX_LENGTH  : positive;
      WIDTH       : positive;
      INIT_VALUE  : std_logic := '0';
      RESET_VALUE : std_logic := '0';
      REGISTER_OUTPUTS : boolean := true
   );
   port (
      clk_i    : in  std_logic;
      clk_en_i : in  std_logic := '1';
      rst_i    : in  std_logic := '0';
      d_i      : in  std_logic_vector(WIDTH - 1 downto 0);
      len_i    : in  unsigned(integer(ceil(log2(real(MAX_LENGTH)))) - 1 downto 0);
      q_o      : out std_logic_vector(WIDTH - 1 downto 0) := (others => INIT_VALUE)
   );
end entity;


architecture rtl of Dynamic_Register_Chain is

   type t_chain is array (0 to MAX_LENGTH - 1) of std_logic_vector(WIDTH - 1 downto 0);

   signal chain : t_chain := (others => (others => INIT_VALUE));

   signal q : std_logic_vector(WIDTH - 1 downto 0) := (others => INIT_VALUE);

begin

   process (clk_i) is
   begin
      if rising_edge(clk_i) then
         if clk_en_i = '1' then
            for i in 0 to MAX_LENGTH - 1 loop
               if i = 0 then
                  chain(0) <= d_i;
               else
                  chain(i) <= chain(i - 1);
               end if;
            end loop;

            if rst_i = '1' then
               for i in 0 to MAX_LENGTH - 1 loop
                  chain(i) <= (others => RESET_VALUE);
               end loop;
            end if;
         end if;
      end if;
   end process;


   multiplexer : process (len_i, d_i, chain) is
   begin
      if len_i = 0 then
         q <= d_i;
      elsif len_i < MAX_LENGTH then
         q <= chain(to_integer(len_i) - 1);
      else
         q <= chain(MAX_LENGTH - 1);
      end if;
   end process;


   output_registers : if REGISTER_OUTPUTS generate

      process (clk_i) is
      begin
         if rising_edge(clk_i) then
            q_o <= q;
         end if;
      end process;

   else generate

      q_o <= q;

   end generate output_registers;

end architecture;
