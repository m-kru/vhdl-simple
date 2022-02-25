-- SPDX-License-Identifier: MIT
-- https://github.com/m-kru/vhdl-simple
-- Copyright (c) 2020 Michał Kruszewski

library ieee;
  use ieee.std_logic_1164.all;

-- Serial-In Parallel-Out (SIPO) register.
--
-- SIPO register which can be configured to work with or without output
-- register. When G_REGISTER_OUTPUTS is set to false, the stb_i input can
-- be left unconnected.
entity Serial_In_Parallel_Out_Register is
  generic (
    G_OUTPUT_WIDTH     : positive;
    G_INIT_VALUE       : std_logic := '0';
    G_RESET_VALUE      : std_logic := '0';
    G_REGISTER_OUTPUTS : boolean   := true
  );
  port (
    clk_i : in   std_logic;
    rst_i : in   std_logic := '0';
    d_i   : in   std_logic;
    d_o   : out  std_logic;
    q_o   : out  std_logic_vector(G_OUTPUT_WIDTH - 1 downto 0) := (others => G_INIT_VALUE); -- Parallel output
    -- Strobe is used only if G_REGISTER_OUTPUTS is set to true.
    stb_i : in   std_logic := 'U'
  );

end entity;

architecture rtl of Serial_In_Parallel_Out_Register is

  signal q_internal : std_logic_vector(G_OUTPUT_WIDTH - 1 downto 0) := (others => G_INIT_VALUE);
  signal q_output   : std_logic_vector(G_OUTPUT_WIDTH - 1 downto 0) := (others => G_INIT_VALUE);

begin

  d_o <= q_internal(G_OUTPUT_WIDTH - 1);

  shift : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        q_internal <= (others => G_RESET_VALUE);
      else
        for i in 0 to G_OUTPUT_WIDTH - 1 loop
          if i = 0 then
            q_internal(0) <= d_i;
          else
            q_internal(i) <= q_internal(i - 1);
          end if;
        end loop;
      end if;
    end if;
  end process shift;


  register_outputs : if G_REGISTER_OUTPUTS generate

    q_o <= q_output;

    process (clk_i) is
    begin

      if rising_edge(clk_i) then
        if rst_i = '1' then
          q_output <= (others => G_RESET_VALUE);
        elsif stb_i = '1' then
          q_output <= q_internal;
        end if; 
      end if;

    end process;

  else generate

    q_o <= q_internal;

  end generate register_outputs;

end architecture;
