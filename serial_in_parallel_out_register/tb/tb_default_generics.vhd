library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library simple;

entity tb_default_generics is
end entity;

architecture tb_arch of tb_default_generics is

  constant CLK_PERIOD : time := 10 ns;
  signal clk   : std_logic := '0';
  signal reset : std_logic := '0';

  signal din    : std_logic := '0';
  signal dout   : std_logic;
  signal q      : std_logic_vector(7 downto 0);
  signal strobe : std_logic := '0';

  constant C_TEST_SEQUENCE : std_logic_vector(7 downto 0) := "11001010";
begin

  clk <= not clk after CLK_PERIOD/2;

  DUT : entity simple.serial_in_parallel_out_register
  generic map (
     OUTPUT_WIDTH => 8
  )
  port map (
    clk_i => clk,
    rst_i => reset,
    d_i   => din,
    d_o   => dout,
    q_o   => q,
    stb_i => strobe
  );

  stimuli_generator: process
  begin
    wait for 8 * CLK_PERIOD;

    strobe <= '1';
    wait for  CLK_PERIOD;
    strobe <= '0';

    for i in 7 downto 0 loop
      din <= C_TEST_SEQUENCE(i);
      wait for  CLK_PERIOD;
    end loop;

    strobe <= '1';
    wait for  CLK_PERIOD;
    strobe <= '0';

    for i in 7 downto 0 loop
      din <= C_TEST_SEQUENCE(i);
      wait for  CLK_PERIOD;
    end loop;

    strobe <= '1';
    wait for  CLK_PERIOD;
    strobe <= '0';
    reset <= '1';
    wait for  CLK_PERIOD;
    reset <= '0';

    wait for 4 * CLK_PERIOD;
    report "End of testbench. All tests passed." severity note;
    std.env.finish;
  end process;

  response_checker: process
  begin
    wait for 9 * CLK_PERIOD;
    assert q = "00000000" report "q should be all 0" severity failure;

    wait for 9 * CLK_PERIOD;
    assert q = C_TEST_SEQUENCE report "q does not equal C_TEST_SEQUENCE" severity failure;
    wait for 9 * CLK_PERIOD;
    assert q = C_TEST_SEQUENCE report "q should be all 0 after reset" severity failure;
  end process;

end;
