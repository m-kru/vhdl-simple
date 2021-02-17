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

  constant C_TEST_SEQUENCE : std_logic_vector(7 downto 0) := "11001010";
  signal   parallel        : std_logic_vector(7 downto 0) := C_TEST_SEQUENCE;

  signal strobe : std_logic := '0';
  signal q      : std_logic_vector(0 downto 0);

begin

  clk <= not clk after CLK_PERIOD/2;

  DUT : entity simple.parallel_in_serial_out_register
  generic map (
     G_INPUT_WIDTH  => 8,
     G_OUTPUT_WIDTH => 1
  )
  port map (
    clk_i      => clk,
    rst_i      => reset,
    parallel_i => parallel,
    stb_i      => strobe,
    q_o        => q
  );

  main: process
  begin
    wait for 4 * CLK_PERIOD;

    strobe <= '1';
    wait for CLK_PERIOD;
    strobe <= '0';

    assert q = "0" report "q should equal 0" severity failure;
    wait for CLK_PERIOD;
    assert q = "1" report "q should equal 1" severity failure;
    wait for CLK_PERIOD;
    assert q = "0" report "q should equal 0" severity failure;
    wait for CLK_PERIOD;
    assert q = "1" report "q should equal 1" severity failure;
    wait for CLK_PERIOD;
    assert q = "0" report "q should equal 0" severity failure;
    wait for CLK_PERIOD;
    assert q = "0" report "q should equal 0" severity failure;
    wait for CLK_PERIOD;
    assert q = "1" report "q should equal 1" severity failure;
    wait for CLK_PERIOD;
    assert q = "1" report "q should equal 1" severity failure;
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
