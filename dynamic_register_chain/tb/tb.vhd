library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   use ieee.math_real.ceil;
   use ieee.math_real.log2;

library simple;

entity tb is
end entity;

architecture test of tb is

   constant WIDTH : positive := 1;
   constant MAX_LENGTH : positive := 5;

   constant CLK_PERIOD : time := 10 ns;
   signal clk : std_logic := '0';

   signal rst : std_logic := '0';

   signal d : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
   constant LENGTH_WIDTH : positive := integer(ceil(log2(real(MAX_LENGTH))));
   signal len : unsigned(LENGTH_WIDTH - 1 downto 0) := (others => '0');
   signal q, q_prev : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');

begin

   clk <= not clk after CLK_PERIOD / 2;


   DUT : entity simple.Dynamic_Register_Chain
   generic map (
      WIDTH      => WIDTH,
      MAX_LENGTH => MAX_LENGTH,
      REGISTER_OUTPUTS => false
   )
   port map (
      clk_i => clk,
      rst_i => rst,
      d_i   => d,
      len_i => len,
      q_o   => q
   );


   main : process is

      procedure check(delay : natural) is
      begin
         len <= to_unsigned(delay, LENGTH_WIDTH);
         d(0) <= '1';
         wait for 1 ns;

         if delay = 0 then
            assert q = "1" report "expecting '1'" severity failure;
            wait for CLK_PERIOD;
            d(0) <= '0';
         else
            wait for CLK_PERIOD;
            d(0) <= '0';
            wait for (delay - 1) * CLK_PERIOD;
            assert q = "1" report "expecting '1'" severity failure;
         end if;

         wait for CLK_PERIOD - 1 ns;
      end procedure;

   begin
      wait for 3 * CLK_PERIOD;

      for i in 0 to MAX_LENGTH loop
         check(i);
         wait for MAX_LENGTH * CLK_PERIOD;
      end loop;

      wait for 5 * CLK_PERIOD;
      std.env.finish;
   end process;


   pulse_width_checker : process (clk) is
   begin
      if rising_edge(clk) then
         q_prev <= q;
         assert q_prev = "0" or (q_prev = "1" and q = "0")
            report "q asserted for more than one clock cycle"
            severity failure;
      end if;
   end process;

end architecture;
