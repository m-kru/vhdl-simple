-- SPDX-License-Identifier: MIT
-- https://github.com/m-kru/vhdl-simple
-- Copyright (c) 2021 Michał Kruszewski

library ieee;
   use ieee.std_logic_1164.all;

-- Narrowing_Register is a register for passing data from the domain with
-- primary data width N to the domain with primary data width M < N.
--
-- It is user responsibility to provide d_i and stb_i in proper
-- clock cycles. 'Proper' means one clock cycle before the number of
-- valid bits in the internal register is less than G_OUTPUT_WIDTH.
-- 
-- G_SHIFT_VALUE is the value shifted when the d_i data is not provided.
entity Narrowing_Register is
   generic (
      G_INPUT_WIDTH  : positive;
      G_OUTPUT_WIDTH : positive;
      G_INIT_VALUE   : std_logic := '0';
      G_RESET_VALUE  : std_logic := '0';
      G_SHIFT_VALUE  : std_logic := '-'
   );
   port (
      clk_i    : in  std_logic;
      clk_en_i : in  std_logic := '1';
      rst_i    : in  std_logic := '0';
      d_i      : in  std_logic_vector(G_INPUT_WIDTH - 1 downto 0);
      stb_i    : in  std_logic;
      q_o      : out std_logic_vector(G_OUTPUT_WIDTH - 1 downto 0) := (others => G_INIT_VALUE)
   );
begin
   assert G_OUTPUT_WIDTH < G_INPUT_WIDTH
      report "G_OUTPUT_WIDTH (" & integer'image(G_OUTPUT_WIDTH) & ") must be lower than G_INPUT_WIDTH (" & integer'image(G_INPUT_WIDTH) & ")"
      severity failure;
end entity;


architecture rtl of Narrowing_Register is

   attribute dont_touch : string;

   constant C_WIDTH : positive := G_OUTPUT_WIDTH * (G_INPUT_WIDTH / G_OUTPUT_WIDTH + 1);
   constant C_INDEX_DELTA : natural := G_INPUT_WIDTH - (G_INPUT_WIDTH / G_OUTPUT_WIDTH) * G_OUTPUT_WIDTH;
   constant C_INDEX_MAX : positive := C_WIDTH - G_INPUT_WIDTH;

   signal reg : std_logic_vector(C_WIDTH - 1 downto 0) := (others => G_INIT_VALUE);
   signal index : natural range 0 to C_INDEX_MAX;

   -- For some combinations of G_INPUT_WIDTH and G_OUTPUT_WIDTH Vivado optimizes out
   -- part of the reg register. The smulations work correctly, however the design behaves
   -- in different way.
   -- After hours of debugging I haven't managed to find out why.
   -- Even with '-debug_log' options there is no infomration in the logs.
   attribute dont_touch of reg : signal is "true";

begin

   process (clk_i) is
   begin
      if rising_edge(clk_i) then
         if clk_en_i = '1' then
            reg(C_WIDTH - 1 - G_OUTPUT_WIDTH downto 0) <= reg(C_WIDTH - 1 downto G_OUTPUT_WIDTH);
            reg(C_WIDTH - 1 downto C_WIDTH - G_OUTPUT_WIDTH) <= (others => G_SHIFT_VALUE);

            if stb_i = '1' then
               reg(index + G_INPUT_WIDTH - 1 downto index) <= d_i;
               if index < C_INDEX_MAX then
                  index <= index + C_INDEX_DELTA;
               else
                  index <= 0;
               end if;
            end if;

            if rst_i = '1' then
               reg <= (others => G_RESET_VALUE);
               index <= 0;
            end if;
         end if;
      end if;
   end process;


   q_o <= reg(G_OUTPUT_WIDTH - 1 downto 0);

end architecture;
