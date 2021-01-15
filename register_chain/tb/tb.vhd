library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

library simple;

entity tb is
end entity;

architecture test of tb is

   constant C_WIDTH : positive := 8;
   constant C_DELAY : positive := 3;

   constant C_CLK_PERIOD : time := 10 ns;
   signal clk : std_logic := '0';

   signal rst : std_logic := '0';

   signal d : std_logic_vector(C_WIDTH - 1 downto 0) := (others => '0');
   signal q : std_logic_vector(C_WIDTH - 1 downto 0);

begin

   clk <= not clk after C_CLK_PERIOD / 2;


   DUT : entity simple.register_chain
   generic map (
      G_WIDTH  => C_WIDTH,
      G_STAGES => C_DELAY
   )
   port map (
      clk_i => clk,
      rst_i => rst,
      d_i => d,
      q_o => q
   );


   generator : process (clk) is
      variable counter : natural := 0;
   begin
      if rising_edge(clk) then
         counter := counter + 1;
         d <= std_logic_vector(to_unsigned(counter, d'length));
         if counter = 10 then
            rst <= '1';
         elsif counter = 11 then
            rst <= '0';
         end if;
      end if;
   end process;


   main : process is

   begin
      wait for 15 * C_CLK_PERIOD;
      std.env.finish;
   end process;


   checker : process is
      variable counter_d : natural;
      variable counter_q : natural;
   begin
      wait for C_DELAY * C_CLK_PERIOD;

      for i in 0 to 5 loop
         counter_d := to_integer(unsigned(d));
         counter_q := to_integer(unsigned(q));
         assert counter_d  - counter_q = C_DELAY
            report "Wrong delay (" & integer'image(counter_d - counter_q) & ")," & " expected (" & integer'image(C_DELAY) &  ")"
            severity failure;
      end loop;

      wait until rst;
      wait for C_DELAY * C_CLK_PERIOD;
      assert q = "00000000"
         report "Wrong value after reset (0x" & to_hstring(q) & ")" & ", expecting 0x00"
         severity failure;

   end process;

end architecture;
