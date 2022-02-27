-- SPDX-License-Identifier: MIT
-- https://github.com/m-kru/vhdl-simple
-- Copyright (c) 2020 Michał Kruszewski

library ieee;
  use ieee.std_logic_1164.all;

-- Parallel-In Serial-Out (PISO) register with configurable shift direction.
--
-- If G_LSB_FIRST is set to true then Least Significant Bit (LSB)
-- will appear at the output as the first one.
-- If G_LSB_FIRST is set to false then Most Significant Bit (MSB) will
-- appear at the output as the first one. Width of the output is also
-- configurable, but it must be less than or equal to parallel input width.
entity Parallel_In_Serial_Out_Register is
  generic (
    G_INPUT_WIDTH  : positive;
    G_OUTPUT_WIDTH : positive;
    G_LSB_FIRST    : boolean   := true;
    G_INIT_VALUE   : std_logic := '0';
    G_RESET_VALUE  : std_logic := '0'
  );
  port (
    clk_i      : in   std_logic;
    rst_i      : in   std_logic := '0';
    serial_i   : in   std_logic := '0';
    parallel_i : in   std_logic_vector(G_INPUT_WIDTH - 1 downto 0);
    stb_i      : in   std_logic;
    q_o        : out  std_logic_vector(G_OUTPUT_WIDTH - 1 downto 0) := (others => G_INIT_VALUE)
  );

begin

  assert G_INPUT_WIDTH >= G_OUTPUT_WIDTH
    report "G_OUTPUT_WIDTH (" & integer'image(G_OUTPUT_WIDTH) & ") must be less than or equal to G_INPUT_WIDTH (" & integer'image(G_INPUT_WIDTH) & ")"
    severity failure;

end entity;


architecture rtl of Parallel_In_Serial_Out_Register is

  signal internal_reg : std_logic_vector(G_INPUT_WIDTH - 1 downto 0) := (others => G_INIT_VALUE);

begin

  shift_direction : if G_LSB_FIRST generate

    q_o <= internal_reg(G_OUTPUT_WIDTH - 1 downto 0);

    process(clk_i)
    begin
      if rising_edge(clk_i) then
        if rst_i = '1' then
          internal_reg <= (others => G_RESET_VALUE);
        else
          if stb_i = '1' then
            internal_reg <= parallel_i;
          else
            internal_reg(G_INPUT_WIDTH - 1) <= serial_i;
            internal_reg(G_INPUT_WIDTH - 2 downto 0) <= internal_reg(G_INPUT_WIDTH - 1 downto 1);
          end if;
        end if;
      end if;
    end process;

  else generate

    q_o <= internal_reg(G_INPUT_WIDTH - 1 downto G_INPUT_WIDTH - G_OUTPUT_WIDTH);

    process(clk_i)
    begin
      if rising_edge(clk_i) then
        if rst_i = '1' then
          internal_reg <= (others => G_RESET_VALUE);
        else
          if stb_i = '1' then
            internal_reg <= parallel_i;
          else
            internal_reg(0) <= serial_i;
            internal_reg(G_INPUT_WIDTH - 1 downto 1) <= internal_reg(G_INPUT_WIDTH - 2 downto 0);
          end if;
        end if;
      end if;
    end process;

  end generate shift_direction;

end architecture;
