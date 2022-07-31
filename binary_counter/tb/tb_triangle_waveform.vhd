library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   use ieee.math_real.ceil;
   use ieee.math_real.log2;

library simple;


entity tb_binary_counter_triangle_waveform is
end entity;


architecture test of tb_binary_counter_triangle_waveform is

   constant C_MIN_VALUE : positive := 5;
   constant C_MAX_VALUE : positive := 11;
   constant C_WIDTH : positive := integer(ceil(log2(real(C_MAX_VALUE))));

   constant C_CLK_PERIOD : time := 10 ns;
   signal clk : std_logic := '0';

   signal d, q : unsigned(C_WIDTH - 1 downto 0);
   signal q_prev : unsigned(C_WIDTH - 1 downto 0) := to_unsigned(C_MIN_VALUE - 1, C_WIDTH);
   signal stb, down  : std_logic := '0';
   signal min, max : std_logic;
   signal prev_min, prev_max : std_logic;

begin

   clk <= not clk after C_CLK_PERIOD / 2;


   DUT : entity simple.Binary_Counter
   generic map (
      COUNTER_MAX_VALUE  => C_MAX_VALUE,
      COUNTER_MIN_VALUE  => C_MIN_VALUE,
      COUNTER_INIT_VALUE => C_MIN_VALUE
   )
   port map (
      clk_i  => clk,
      d_i    => d,
      stb_i  => stb,
      down_i => down,
      q_o    => q,
      min_o  => min,
      max_o  => max
   );


   down_switcher : process (clk) is
   begin
      if prev_max = '0' and max = '1' then
         down <= '1';
      elsif prev_min = '0'and min = '1' then
         down <= '0';
      end if;
      if rising_edge(clk) then
         prev_min <= min;
         prev_max <= max;
      end if;
   end process;


   main : process is
   begin
      wait for 30 * C_CLK_PERIOD;
      std.env.finish;
   end process;


   counter_bounds_guard : process (clk) is
   begin
      if rising_edge(clk) then
         assert (C_MIN_VALUE <= q) and (q <= C_MAX_VALUE)
            report "q value (" & to_string(to_integer(q)) & ") out of bounds"
            severity failure;
      end if;
   end process;


   counter_step_guard : process (clk) is
   begin
      if rising_edge(clk) then
         q_prev <= q;
         assert (q = q_prev - 1) or (q = q_prev + 1)
            report "q step invalid, previous value " & to_string(to_integer(q_prev))& ", current value" & to_string(to_integer(q))
            severity failure;
      end if;
   end process;

end architecture;
