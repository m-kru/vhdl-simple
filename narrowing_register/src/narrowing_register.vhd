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
-- valid bits in the internal register is less than OUTPUT_WIDTH.
--
-- SHIFT_VALUE is the value shifted when the d_i data is not provided.
entity Narrowing_Register is
   generic (
      INPUT_WIDTH  : positive;
      OUTPUT_WIDTH : positive;
      INIT_VALUE   : std_logic := '0';
      RESET_VALUE  : std_logic := '0';
      SHIFT_VALUE  : std_logic := '-'
   );
   port (
      clk_i    : in  std_logic;
      clk_en_i : in  std_logic := '1';
      rst_i    : in  std_logic := '0';
      d_i      : in  std_logic_vector(INPUT_WIDTH - 1 downto 0);
      stb_i    : in  std_logic;
      q_o      : out std_logic_vector(OUTPUT_WIDTH - 1 downto 0) := (others => INIT_VALUE)
   );
begin
   assert OUTPUT_WIDTH < INPUT_WIDTH
      report "OUTPUT_WIDTH (" & integer'image(OUTPUT_WIDTH) & ") must be lower than INPUT_WIDTH (" & integer'image(INPUT_WIDTH) & ")"
      severity failure;
end entity;


architecture rtl of Narrowing_Register is

   attribute dont_touch : string;

   constant C_WIDTH : positive := OUTPUT_WIDTH * (INPUT_WIDTH / OUTPUT_WIDTH + 1);
   constant C_INDEX_DELTA : natural := INPUT_WIDTH - (INPUT_WIDTH / OUTPUT_WIDTH) * OUTPUT_WIDTH;
   constant C_INDEX_MAX : positive := C_WIDTH - INPUT_WIDTH;

   signal reg : std_logic_vector(C_WIDTH - 1 downto 0) := (others => INIT_VALUE);
   signal index : natural range 0 to C_INDEX_MAX;

   -- For some combinations of INPUT_WIDTH and OUTPUT_WIDTH Vivado optimizes out
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
            reg(C_WIDTH - 1 - OUTPUT_WIDTH downto 0) <= reg(C_WIDTH - 1 downto OUTPUT_WIDTH);
            reg(C_WIDTH - 1 downto C_WIDTH - OUTPUT_WIDTH) <= (others => SHIFT_VALUE);

            if stb_i = '1' then
               reg(index + INPUT_WIDTH - 1 downto index) <= d_i;
               if index < C_INDEX_MAX then
                  index <= index + C_INDEX_DELTA;
               else
                  index <= 0;
               end if;
            end if;

            if rst_i = '1' then
               reg <= (others => RESET_VALUE);
               index <= 0;
            end if;
         end if;
      end if;
   end process;


   q_o <= reg(OUTPUT_WIDTH - 1 downto 0);

end architecture;
