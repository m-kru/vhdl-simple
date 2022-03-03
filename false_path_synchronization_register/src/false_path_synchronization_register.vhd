-- SPDX-License-Identifier: MIT
-- https://github.com/m-kru/vhdl-simple
-- Copyright (c) 2019 Michał Kruszewski

library ieee;
   use ieee.std_logic_1164.all;

-- False_Path_Synchronization_Register is the Clock Domain Crossing (CDC)
-- synchronizer with set false path.
--
-- Setting false path on CDC is not recommmended, as it does not guarantee
-- coherency between signals. However, if you consciously do not care about
-- the latency and coherency, setting false path can be really useful as it
-- loosens the constraints for Place & Route algorithms.
entity False_Path_Synchronization_Register is
  generic (
    WIDTH      : positive;
    INIT_VALUE : std_logic := '0'
  );
  port (
    clk_i : in  std_logic;
    d_i   : in  std_logic_vector(WIDTH-1 downto 0);
    q_o   : out std_logic_vector(WIDTH-1 downto 0)
  );
end entity;

-- Disable Quartus warning about unrecognized attributes.
-- altera message_off 10335

architecture rtl of False_Path_Synchronization_Register is
  
  signal s_0, s_1 : std_logic_vector(WIDTH-1 downto 0) := (others => INIT_VALUE);

  -- Define all attributes even the ones that imply from the async_reg.
  -- To be compatible with older EDA tools.
  attribute shreg_extract : string;
  attribute shreg_extract of s_0 : signal is "no";
  attribute shreg_extract of s_1 : signal is "no";

  attribute keep : string;
  attribute keep of s_0 : signal is "true";
  attribute keep of s_1 : signal is "true";

  attribute async_reg : string;
  attribute async_reg of s_0 : signal is "true";
  attribute async_reg of s_1 : signal is "true";

begin

  sync : process(clk_i) is
  begin
    if rising_edge(clk_i) then
      s_0 <= d_i;
      s_1 <= s_0;
    end if;
  end process sync;

  q_o <= s_1;

end architecture;
