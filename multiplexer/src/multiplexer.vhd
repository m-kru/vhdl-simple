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
-- OVERRANGE_POLICY defines what should be set to the output_o when number of inputs
-- is not a power of 2. Available policies are 'first', 'last', 'value'.
-- If 'value' is choosen, then output_o <= (others => OVERRANGE_VALUE).
-- The default policy is ...
-- Setting OVERRANGE_POLICY to 'value' and OVERRANGE_VALUE to '0' or '1' results
-- with a greater resource utilization.
-- Setting OVERRANGE_POLICY to 'first' or 'last' _probably_ does not increase the
-- resource utilization. Although, it has been tested only with Vivado 2020.1
-- and default synthesis settings.
entity Multiplexer is
   generic (
      INPUTS : positive;
      WIDTH  : positive;
      REGISTER_OUTPUTS : boolean   := true;
      OVERRANGE_POLICY : string    := "value"; -- last, first or value
      OVERRANGE_VALUE  : std_logic := '-'
   );
   port (
      clk_i    : in  std_logic := '-';
      addr_i   : in  std_logic_vector(integer(ceil(log2(real(INPUTS)))) - 1 downto 0);
      inputs_i : in  slv_vector(INPUTS - 1 downto 0)(WIDTH - 1 downto 0);
      output_o : out std_logic_vector(WIDTH - 1 downto 0)
   );
begin
   assert REGISTER_OUTPUTS = false or clk_i /= '-' report "clk_i port not mapped to any signal" severity failure;

   assert OVERRANGE_POLICY = "first" or OVERRANGE_POLICY = "last" or OVERRANGE_POLICY = "value"
      report "Wrong OVERRANGE_POLICY, available policies: 'first', 'last' and 'value'."
      severity failure;
end entity;


architecture rtl of Multiplexer is

   signal output : std_logic_vector(WIDTH - 1 downto 0);

begin

   policy : if OVERRANGE_POLICY = "first" generate

      process (all) is
         variable addr : natural;
      begin
         addr := to_integer(unsigned(addr_i));
         if addr > INPUTS - 1 then
            output <= inputs_i(0);
         else
            output <= inputs_i(addr);
         end if;
      end process;

   elsif OVERRANGE_POLICY = "last" generate

      process (all) is
         variable addr : natural;
      begin
         addr := to_integer(unsigned(addr_i));
         if addr > INPUTS - 1 then
            output <= inputs_i(INPUTS - 1);
         else
            output <= inputs_i(addr);
         end if;
      end process;

   else generate

      process (all) is
         variable addr : natural;
      begin
         addr := to_integer(unsigned(addr_i));
         if addr > INPUTS - 1 then
            output <= (others => OVERRANGE_VALUE);
         else
            output <= inputs_i(addr);
         end if;
      end process;
   end generate;


  output_registers : if REGISTER_OUTPUTS generate

    sync_outputs : process (clk_i) is
    begin

      if rising_edge(clk_i) then
        output_o <= output;
      end if;

    end process sync_outputs;

  else generate

    output_o <= output;

  end generate output_registers;

end architecture;
