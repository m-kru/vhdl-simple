library ieee;
   use ieee.std_logic_1164.all;

library simple;

entity tb is
end entity;

architecture test of tb is
   constant C_PERIOD : positive := 10;
   constant C_DUTY   : positive := 3;

   constant C_CLK_PERIOD : time := 10 ns;
   signal clk : std_logic := '0';

   signal rst : std_logic := '0';
   signal enable : std_logic := '1';

   signal s_out : std_logic;

   signal ones_count : natural := 0;
begin

   clk <= not clk after C_CLK_PERIOD / 2;


   DUT : entity simple.static_pulse_width_modulator
   generic map (
      G_PERIOD => C_PERIOD,
      G_DUTY   => C_DUTY
   )
   port map (
      clk_i => clk,
      rst_i => rst,
      en_i  => enable,
      q_o   => s_out
   );


   main : process
   begin
      wait for 25 * C_CLK_PERIOD;

      rst <= '1';
      wait for C_CLK_PERIOD;
      rst <= '0';

      wait for C_PERIOD * C_CLK_PERIOD;
      report "End of testbench. All tests passed." severity note;
      std.env.finish;
   end process;


   count_ones : process (clk)
   begin
      if rising_edge(clk) then
         if s_out = '1' then
            ones_count <= ones_count + 1;
         end if;
      end if;
   end process;


   checker : process
   begin
      wait for C_PERIOD * C_CLK_PERIOD;
      assert ones_count = 2 report "After first period number of ones should equal 2" severity failure;
      wait for C_PERIOD * C_CLK_PERIOD;
      assert ones_count = 5 report "After second period number of ones should equal 5" severity failure;
      wait;
   end process;


   checker_reset : process
      variable old_ones_count : natural := 0;
   begin
      wait until rst = '1';
      old_ones_count := ones_count;
      wait for (C_DUTY + 1) * C_CLK_PERIOD;
      assert ones_count = old_ones_count + C_DUTY report "Wrong count of ones after reset" severity failure;
   end process;


end architecture;
