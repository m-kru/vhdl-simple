library ieee;
   use ieee.std_logic_1164.all;

library simple;

entity tb is
end entity;

architecture test of tb is

   constant C_CLK_PERIOD : time := 10 ns;
   signal clk : std_logic := '0';

   signal data : std_logic;

   signal transition  : std_logic;
   signal zero_to_one : std_logic;
   signal one_to_zero : std_logic;

begin

   clk <= not clk after C_CLK_PERIOD / 2;


   DUT : entity simple.synchronous_transition_detector
   generic map (
      WIDTH => 1
   )
   port map (
      clk_i            => clk,
      d_i(0)           => data,
      transition_o(0)  => transition,
      zero_to_one_o(0) => zero_to_one,
      one_to_zero_o(0) => one_to_zero
   );


   main : process is
   begin
      wait for C_CLK_PERIOD;
      data <= '0';
      wait for 3 * C_CLK_PERIOD;
      data <= '1';
      wait for C_CLK_PERIOD;
      assert transition = '1' report "Transition not detected" severity failure;
      assert zero_to_one = '1' report "0 -> 1 not detected" severity failure;

      data <= '0';
      wait for C_CLK_PERIOD;
      assert transition = '1' report "Transition not detected" severity failure;
      assert one_to_zero = '1' report "1 -> 0 not detected" severity failure;

      wait for 3 * C_CLK_PERIOD;
      data <= '1';
      wait for C_CLK_PERIOD;
      assert transition = '1' report "Transition not detected" severity failure;
      assert zero_to_one = '1' report "0 -> 1 not detected" severity failure;


      wait for C_CLK_PERIOD;
      std.env.finish;
   end process;

end architecture;
