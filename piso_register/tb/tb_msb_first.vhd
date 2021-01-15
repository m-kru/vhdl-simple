library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library simple;

entity tb_msb_first is
end entity;

architecture tb_arch of tb_msb_first is

  constant CLK_PERIOD : time := 10 ns;
  signal clk   : std_logic := '0';
  signal reset : std_logic := '0';

  constant C_TEST_SEQUENCE : std_logic_vector(3 downto 0) := "1101";
  signal   parallel        : std_logic_vector(3 downto 0) := C_TEST_SEQUENCE;

  signal strobe : std_logic := '0';
  signal q      : std_logic_vector(1 downto 0);

begin

  clk <= not clk after CLK_PERIOD/2;

  piso_register : entity simple.piso_register
  generic map (
    G_WIDTH        => 4,
    G_OUTPUT_WIDTH => 2,
    G_LSB_FIRST    => false,
    G_RESET_VALUE  => '1'
  )
  port map (
    clk_i      => clk,
    rst_i      => reset,
    parallel_i => parallel,
    strobe_i   => strobe,
    q_o        => q
  );

  main: process
  begin
    wait for 4 * CLK_PERIOD;

    strobe <= '1';
    wait for CLK_PERIOD;
    strobe <= '0';

    assert q = "11" report "q should equal 11" severity failure;
    wait for CLK_PERIOD;
    assert q = "10" report "q should equal 10" severity failure;
    wait for CLK_PERIOD;
    assert q = "01" report "q should equal 01" severity failure;
    wait for CLK_PERIOD;
    assert q = "10" report "q should equal 10" severity failure;
    wait for CLK_PERIOD;
    assert q = "00" report "q should equal 00" severity failure;
    wait for CLK_PERIOD;

    strobe <= '1';
    wait for CLK_PERIOD;
    strobe <= '0';

    reset <= '1';
    wait for CLK_PERIOD;
    reset <= '0';

    wait for 4 * CLK_PERIOD;
    std.env.finish;
  end process main;

end;
