-- SPDX-License-Identifier: MIT
-- https://github.com/m-kru/vhdl-simple
-- Copyright (c) 2018 Adrian Byszuk <adrian.byszuk@gmail.com>

library ieee;
   use ieee.std_logic_1164.all;

-- Reset synchronizer is a standard reset synchroniser.
-- It follows typical and recommended
-- "asynchronous assertion -> synchronous deassertion" practice.
-- Can be used to drive both synchronous and asynchronous FFs.
-- Will assert reset even without active clock signal.
-- Needs two clock cycles to deassert reset.
-- This circuit guarantess zero metastability problems.
entity Reset_Synchronizer is
  generic (
    INPUT_POSITIVE  : boolean := true; -- TRUE for positive polarity
    OUTPUT_POSITIVE : boolean := true
  );
  port (
    clk_i : in std_logic;
    rst_i : in std_logic;
    rst_o : out std_logic
  );
end entity;

architecture rtl of Reset_Synchronizer is

  attribute dont_touch : string;

  signal rst_ff1, rst_ff2, rst_in_p : std_logic := '0';
  attribute dont_touch of rst_ff1 : signal is "true";
  attribute dont_touch of rst_ff2 : signal is "true";

begin

  -- vsg_off concurrent_007
  rst_in_p <= rst_i when INPUT_POSITIVE else not(rst_i);
  rst_o <= rst_ff2 when OUTPUT_POSITIVE else not(rst_ff2);
  -- vsg_on

  sync: process(clk_i, rst_in_p) is
  begin
    if rst_in_p = '1' then -- asynchronous reset (active high)
      rst_ff1 <= '1';
      rst_ff2 <= '1';
    elsif rising_edge(clk_i) then
      -- metastability can happen only at rst_ff
      -- rst_out_p will always de-assert clean
      rst_ff1 <= '0';
      rst_ff2 <= rst_ff1;
    end if;
  end process sync;

end architecture;
