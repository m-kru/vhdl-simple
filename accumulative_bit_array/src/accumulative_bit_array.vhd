-- SPDX-License-Identifier: MIT
-- https://github.com/m-kru/vhdl-simple
-- Copyright (c) 2019 Michał Kruszewski

library ieee;
  use ieee.std_logic_1164.all;

-- Accumulative bit array entity works like an accumulative array of 1 bit accumulative
-- registers.
entity Accumulative_Bit_Array is
  generic (
    WIDTH : positive
  );
  port (
    clk_i   : in  std_logic;
    rst_i   : in  std_logic := '0';
    wr_en_i : in  std_logic := '1';
    d_i     : in  std_logic_vector(WIDTH - 1 downto 0);
    q_o     : out std_logic_vector(WIDTH - 1 downto 0)
  );
end entity;


architecture rtl of Accumulative_Bit_Array is

  signal q_r : std_logic_vector(WIDTH - 1 downto 0);

begin

  q_o <= q_r;

  accumulate : process (clk_i) is
  begin

    if rising_edge(clk_i) then
      if rst_i = '1' then
        q_r   <= (others => '0');
      elsif wr_en_i = '1' then
        for i in 0 to WIDTH - 1 loop
          if q_r(i) = '0' then
            q_r(i) <= d_i(i);
          end if;
        end loop;
      end if;
    end if;

  end process;

end architecture ;
