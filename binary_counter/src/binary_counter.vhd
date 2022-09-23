-- SPDX-License-Identifier: MIT
-- https://github.com/m-kru/vhdl-simple
-- Copyright (c) 2022 Michał Kruszewski

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   use ieee.math_real.ceil;
   use ieee.math_real.log2;

-- Binary_Counter is a synchronous binary counter with configurable width.
--
-- If en_i = '0' the counter keeps counting, however min_o and max_o are stuck to '0'. 
--
-- stb_i reloads internal counter value.
--
-- min_o and max_o are synchronous outputs.
-- Usually such outputs are implemented as combinational logic,
-- however it can increase critical path lengths.
-- Sacrificing one or two flip flops is a price worth to pay.
--
-- down_i - '0' for counting up (default), '1' for counting down.
entity Binary_Counter is
   generic (
      MAX_VALUE   : positive;
      MIN_VALUE   : natural := 0;
      INIT_VALUE  : natural := 0;
      RESET_VALUE : natural := 0;

      MIN_INIT_VALUE  : std_logic := '0';
      MIN_RESET_VALUE : std_logic := '0';

      MAX_INIT_VALUE  : std_logic := '0';
      MAX_RESET_VALUE : std_logic := '0'
   );
   port (
      arstn_i  : in  std_logic := '1';
      clk_en_i : in  std_logic := '1';
      clk_i    : in  std_logic;
      en_i     : in  std_logic := '1';
      rst_i    : in  std_logic := '0';
      d_i      : in  unsigned(integer(ceil(log2(real(MAX_VALUE)))) - 1 downto 0);
      stb_i    : in  std_logic;
      down_i   : in  std_logic := '0';
      q_o      : out unsigned(integer(ceil(log2(real(MAX_VALUE)))) - 1 downto 0) := to_unsigned(INIT_VALUE, integer(ceil(log2(real(MAX_VALUE)))));
      min_o    : out std_logic := MIN_INIT_VALUE;
      max_o    : out std_logic := MAX_INIT_VALUE
   );
end entity;


architecture rtl of Binary_Counter is

   constant WIDTH : positive := integer(ceil(log2(real(MAX_VALUE))));

   signal count : unsigned(WIDTH - 1 downto 0) := to_unsigned(INIT_VALUE, WIDTH);

begin

   -- psl default clock is rising_edge(clk_i);
   -- psl min: assert always min_o |=> not min_o;
   -- psl max: assert always max_o |=> not max_o;
   -- psl rst: assert always rst_i |=> min_o = MIN_RESET_VALUE and max_o = MAX_RESET_VALUE and q_o = RESET_VALUE;

   process (arstn_i, clk_i) is
      procedure reset is
      begin
         count  <= to_unsigned(RESET_VALUE, WIDTH);
         min_o  <= MAX_RESET_VALUE;
         max_o  <= MIN_RESET_VALUE;
      end procedure;
   begin
      if arstn_i = '0' then
         reset;
      elsif rising_edge(clk_i) then
         if clk_en_i = '1' then
            min_o <= '0';
            max_o <= '0';

            if stb_i = '1' then
               count <= d_i;
               if count = MIN_VALUE and down_i = '1' then
                  if en_i = '1' then min_o <= '1'; end if;
               elsif count = MAX_VALUE and down_i = '0' then
                  if en_i = '1' then max_o <= '1'; end if;
               end if;
            elsif (count < MAX_VALUE) and down_i = '0' then
               count <= count + 1;
            elsif (count > MIN_VALUE) and down_i = '1' then
               count <= count - 1;
            end if;

            if (count = MAX_VALUE - 1) and down_i = '0' then
               if en_i = '1' then
                  max_o <= '1';
               end if;
               count <= to_unsigned(MAX_VALUE, WIDTH);
            end if;

            if (count = MIN_VALUE + 1) and down_i = '1' then
               if en_i = '1' then
                  min_o <= '1';
               end if;
               count <= to_unsigned(MIN_VALUE, WIDTH);
            end if;

            if rst_i = '1' then
               reset;
            end if;
         end if;
      end if;
   end process;

   q_o <= count;

end architecture;
