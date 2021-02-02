library ieee;
   use ieee.std_logic_1164.all;

library simple;

entity tb_divisible is
end entity;


architecture test of tb_divisible is

   constant C_INPUT_WIDTH  : positive := 10;
   constant C_OUTPUT_WIDTH : positive := 2;

   constant C_CLK_PERIOD : time := 10 ns;
   signal clk : std_logic := '0';

   signal rst    : std_logic := '0';
   signal strobe : std_logic := '0';

   signal input  : std_logic_vector(C_INPUT_WIDTH - 1 downto 0) := (others => '0');
   signal output : std_logic_vector(C_OUTPUT_WIDTH - 1 downto 0);

begin

   clk <= not clk after C_CLK_PERIOD / 2;


   DUT : entity simple.Narrowing_Register
   generic map (
      G_INPUT_WIDTH  => C_INPUT_WIDTH,
      G_OUTPUT_WIDTH => C_OUTPUT_WIDTH
   )
   port map (
      clk_i    => clk,
      rst_i    => rst,
      input_i  => input,
      strobe_i => strobe,
      output_o => output
   );


   generator : process is
   begin
      wait for C_CLK_PERIOD;
      rst <= '1';

      wait for C_CLK_PERIOD;
      rst <= '0';
      input <= "0111001110";
      strobe <= '1';

      wait for C_CLK_PERIOD;
      strobe <= '0';

      wait for 4 * C_CLK_PERIOD;
      input <= "1011001100";
      strobe <= '1';

      wait for C_CLK_PERIOD;
      strobe <= '0';

      wait for 7 * C_CLK_PERIOD;
   end process;


   checker : process is
   begin
      wait for 3 * C_CLK_PERIOD;
      assert output = "10" report "Expecting 0b10" severity failure;

      wait for C_CLK_PERIOD;
      assert output = "11" report "Expecting 0b11" severity failure;

      wait for C_CLK_PERIOD;
      assert output = "00" report "Expecting 0b00" severity failure;

      wait for C_CLK_PERIOD;
      assert output = "11" report "Expecting 0b11" severity failure;

      wait for C_CLK_PERIOD;
      assert output = "01" report "Expecting 0b01" severity failure;

      -- Second input frame
      wait for C_CLK_PERIOD;
      assert output = "00" report "Expecting 0b00" severity failure;

      wait for C_CLK_PERIOD;
      assert output = "11" report "Expecting 0b00" severity failure;

      wait for C_CLK_PERIOD;
      assert output = "00" report "Expecting 0b00" severity failure;

      wait for C_CLK_PERIOD;
      assert output = "11" report "Expecting 0b11" severity failure;

      wait for C_CLK_PERIOD;
      assert output = "10" report "Expecting 0b10" severity failure;

      wait for C_CLK_PERIOD;
      assert output = "--" report "Expecting 0b--" severity failure;

      wait for C_CLK_PERIOD;
      std.env.finish;
   end process;

end architecture;
