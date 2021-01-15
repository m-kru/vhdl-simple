library ieee;
   use ieee.std_logic_1164.all;

library simple;

entity tb is
end entity;

architecture test of tb is

   constant C_WIDTH : positive := 2;

   constant C_CLK_PERIOD : time := 10 ns;
   signal clk : std_logic := '0';

   signal addr : std_logic_vector(1 downto 0) := "00";

   signal in_0 : std_logic_vector(C_WIDTH - 1 downto 0) := "00";
   signal in_1 : std_logic_vector(C_WIDTH - 1 downto 0) := "01";
   signal in_2 : std_logic_vector(C_WIDTH - 1 downto 0) := "10";

   signal output : std_logic_vector(C_WIDTH - 1 downto 0);

begin

   clk <= not clk after C_CLK_PERIOD / 2;


   DUT : entity simple.multiplexer
   generic map (
      G_INPUTS => 3,
      G_WIDTH  => C_WIDTH,
      G_REGISTER_OUTPUTS => true
   )
   port map (
      clk_i       => clk,
      addr_i      => addr,
      inputs_i(0) => in_0,
      inputs_i(1) => in_1,
      inputs_i(2) => in_2,
      output_o    => output
   );


   main : process is
   begin
      wait for C_CLK_PERIOD;
      assert output = "00" report "output = 0x" & to_hstring(output) & " expecting 0x0" severity failure;

      addr <= "01";
      wait for C_CLK_PERIOD;
      assert output = "01" report "output = 0x" & to_hstring(output) & " expecting 0x1" severity failure;

      addr <= "10";
      wait for C_CLK_PERIOD;
      assert output = "10" report "output = 0x" & to_hstring(output) & " expecting 0x2" severity failure;

      addr <= "11";
      wait for C_CLK_PERIOD;
      assert output = "--" report "output = 0x" & to_hstring(output) & " expecting 0x2" severity failure;

      wait for C_CLK_PERIOD;
      std.env.finish;
   end process;
end architecture;
