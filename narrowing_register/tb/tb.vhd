library ieee;
   use ieee.std_logic_1164.all;

library simple;

entity tb is
end entity;


architecture test of tb is

   constant C_INPUT_WIDTH  : positive := 7;
   constant C_OUTPUT_WIDTH : positive := 3;

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
      stb_i    => strobe,
      output_o => output
   );


   generator : process is
   begin
      wait for C_CLK_PERIOD;
      rst <= '1';

      wait for C_CLK_PERIOD;
      rst <= '0';
      input <= "0000001";
      strobe <= '1';

      wait for C_CLK_PERIOD;
      strobe <= '0';

      wait for C_CLK_PERIOD;
      input <= "0000011";
      strobe <= '1';
      wait for C_CLK_PERIOD;
      strobe <= '0';

      wait for C_CLK_PERIOD;
      input <= "0000111";
      strobe <= '1';
      wait for C_CLK_PERIOD;
      strobe <= '0';

      -- End of cycle wait 1 clock cycle longer.
      wait for 2 * C_CLK_PERIOD;
      input <= "0001111";
      strobe <= '1';
      wait for C_CLK_PERIOD;
      strobe <= '0';

      wait for C_CLK_PERIOD;
      input <= "0011111";
      strobe <= '1';
      wait for C_CLK_PERIOD;
      strobe <= '0';

      wait for 7 * C_CLK_PERIOD;
   end process;


   checker : process is
   begin
      wait for 3 * C_CLK_PERIOD;
      assert output = "001" report "Expecting 0b001" severity failure;

      wait for C_CLK_PERIOD;
      assert output = "000" report "Expecting 0b000" severity failure;

      wait for C_CLK_PERIOD;
      assert output = "110" report "Expecting 0b110" severity failure;

      wait for C_CLK_PERIOD;
      assert output = "000" report "Expecting 0b000" severity failure;

      wait for C_CLK_PERIOD;
      assert output = "100" report "Expecting 0b100" severity failure;

      wait for C_CLK_PERIOD;
      assert output = "011" report "Expecting 0b011" severity failure;

      wait for C_CLK_PERIOD;
      assert output = "000" report "Expecting 0b000" severity failure;

      wait for C_CLK_PERIOD;
      assert output = "111" report "Expecting 0b111" severity failure;

      wait for C_CLK_PERIOD;
      assert output = "001" report "Expecting 0b001" severity failure;

      wait for C_CLK_PERIOD;
      assert output = "110" report "Expecting 0b110" severity failure;

      wait for C_CLK_PERIOD;
      assert output = "111" report "Expecting 0b111" severity failure;

      wait for C_CLK_PERIOD;
      assert output = "-00" report "Expecting 0b-00" severity failure;

      wait for C_CLK_PERIOD;
      assert output = "---" report "Expecting 0b---" severity failure;

      wait for C_CLK_PERIOD;
      std.env.finish;
   end process;

end architecture;
