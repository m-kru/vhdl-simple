-- SPDX-License-Identifier: MIT
-- https://github.com/m-kru/vhdl-simple
-- Copyright (c) 2021 Michał Kruszewski

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   use ieee.math_real.ceil;
   use ieee.math_real.log2;

library types;
   use types.types.all;

-- Multiplexer is a generic multiplexer.
--
-- G_OVERRANGE_POLICY defines what should be set to the output_o when number of inputs
-- is not a power of 2. Available policies are 'first', 'last', 'value'.
-- If 'value' is choosen, then output_o <= (others => G_OVERRANGE_VALUE).
-- The default policy is ...
-- Setting G_OVERRANGE_POLICY to 'value' and G_OVERRANGE_VALUE to '0' or '1' results
-- with a greater resource utilization.
-- Setting G_OVERRANGE_POLICY to 'first' or 'last' _probably_ does not increase the
-- resource utilization. Although, it has been tested only with Vivado 2020.1
-- and default synthesis settings.
entity Multiplexer is
   generic (
      G_INPUTS : positive;
      G_WIDTH  : positive;
      G_REGISTER_OUTPUTS : boolean   := true;
      G_OVERRANGE_POLICY : string    := "value"; -- last, first or value
      G_OVERRANGE_VALUE  : std_logic := '-'
   );
   port (
      clk_i    : in  std_logic := '-';
      addr_i   : in  std_logic_vector(integer(ceil(log2(real(G_INPUTS)))) - 1 downto 0);
      inputs_i : in  slv_vector(G_INPUTS - 1 downto 0)(G_WIDTH - 1 downto 0);
      output_o : out std_logic_vector(G_WIDTH - 1 downto 0)
   );
begin
   assert G_REGISTER_OUTPUTS = false or clk_i /= '-' report "clk_i port not mapped to any signal" severity failure;

   assert G_OVERRANGE_POLICY = "first" or G_OVERRANGE_POLICY = "last" or G_OVERRANGE_POLICY = "value"
      report "Wrong G_OVERRANGE_POLICY, available policies: 'first', 'last' and 'value'."
      severity failure;
end entity;


architecture rtl of Multiplexer is

   signal output : std_logic_vector(G_WIDTH - 1 downto 0);

begin

   overrange_policy : if G_OVERRANGE_POLICY = "first" generate

      process (all) is
         variable addr : natural;
      begin
         addr := to_integer(unsigned(addr_i));
         if addr > G_INPUTS - 1 then
            output <= inputs_i(0);
         else
            output <= inputs_i(addr);
         end if;
      end process;

   elsif G_OVERRANGE_POLICY = "last" generate

      process (all) is
         variable addr : natural;
      begin
         addr := to_integer(unsigned(addr_i));
         if addr > G_INPUTS - 1 then
            output <= inputs_i(G_INPUTS - 1);
         else
            output <= inputs_i(addr);
         end if;
      end process;

   else generate

      process (all) is
         variable addr : natural;
      begin
         addr := to_integer(unsigned(addr_i));
         if addr > G_INPUTS - 1 then
            output <= (others => G_OVERRANGE_VALUE);
         else
            output <= inputs_i(addr);
         end if;
      end process;
   end generate;


  register_outputs : if G_REGISTER_OUTPUTS generate

    sync_outputs : process (clk_i) is
    begin

      if rising_edge(clk_i) then
        output_o <= output;
      end if;

    end process sync_outputs;

  else generate

    output_o <= output;

  end generate register_outputs;

end architecture;
