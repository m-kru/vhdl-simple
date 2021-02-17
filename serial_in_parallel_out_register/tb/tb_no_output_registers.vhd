library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library simple;

entity tb_no_output_registers is
end entity;

architecture tb_arch of tb_no_output_registers is

  constant CLK_PERIOD : time := 10 ns;
  signal clk   : std_logic := '0';
  signal reset : std_logic := '0';

  signal din    : std_logic := '0';
  signal dout   : std_logic;
  signal q      : std_logic_vector(3 downto 0);

  constant C_TEST_SEQUENCE : std_logic_vector(3 downto 0) := "0110";
begin

  clk <= not clk after CLK_PERIOD/2;

  DUT : entity simple.serial_in_parallel_out_register
  generic map (
    G_OUTPUT_WIDTH     => 4,
    G_REGISTER_OUTPUTS => false
  )
  port map (
    clk_i => clk,
    rst_i => reset,
    d_i   => din,
    d_o   => dout,
    q_o   => q
  );

  stimuli_generator: process
  begin
    wait for 4 * CLK_PERIOD;

    for i in 3 downto 0 loop
      din <= C_TEST_SEQUENCE(i);
      wait for  CLK_PERIOD;
    end loop;

    reset <= '1';
    wait for  CLK_PERIOD;
    reset <= '0';

    wait for 4 * CLK_PERIOD;
    report "End of testbench. All tests passed." severity note;
    std.env.finish;
  end process;

  response_checker: process
  begin
    wait for 4 * CLK_PERIOD;
    assert q = "0000" report "q should be all 0" severity failure;

    wait for 4 * CLK_PERIOD;
    assert q = C_TEST_SEQUENCE report "q should equal to C_TEST_SEQUENCE" severity failure;

    wait for CLK_PERIOD;
    assert q = "0000" report "q should equal all 0 after reset" severity failure;
  end process;

end;
