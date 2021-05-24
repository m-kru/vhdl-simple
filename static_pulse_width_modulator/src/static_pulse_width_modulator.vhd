-- SPDX-License-Identifier: MIT
-- https://github.com/m-kru/vhdl_simple
-- Copyright (c) 2021 Michał Kruszewski

library ieee;
   use ieee.std_logic_1164.all;

-- static_pulse_width_modulator is a simple PWM (Pulse-Width Modulation) entity
-- with the duty cycle statically configured.
-- 
-- Both G_PERIOD and G_DUTY are in clock cycles!
-- This requires some calculation to be done by the user.
-- However it gives better control, because the user decides how to round.
-- Useful when G_PERIOD and G_DUTY are relatively small numbers.
--
-- G_DISABLED_VALUE is the value set to the q_o when module is disabled.
--
-- G_START_ON_RESET determines whether counting should start on reset
-- (G_START_ON_RESET = true) or after the rst_i is deasserted
-- (G_START_ON_RESET = false). G_RESET_VALUE is used only if
-- G_START_ON_RESET = false.
entity static_pulse_width_modulator is
   generic (
      G_PERIOD             : positive;
      G_DUTY               : positive;
      G_INIT_VALUE         : std_logic := '0';
      G_INIT_COUNTER_VALUE : natural   := 0;
      G_DISABLED_VALUE     : std_logic := '0';
      G_START_ON_RESET     : boolean   := true;
      G_RESET_VALUE        : std_logic := '0'
   );
   port (
      clk_i    : in  std_logic;
      clk_en_i : in  std_logic := '1';
      rst_i    : in  std_logic := '0';
      en_i     : in  std_logic := '1';
      q_o      : out std_logic := G_INIT_VALUE
   );
begin
   assert G_DUTY <= G_PERIOD
      report "G_DUTY (" & integer'image(G_DUTY) & ") must be lower than G_PERIOD (" & integer'image(G_PERIOD) & ")"
      severity failure;

   assert G_DUTY /= 0
      report "G_DUTY = 0 makes no sense"
      severity failure;

   assert G_INIT_COUNTER_VALUE < G_PERIOD
      report "G_INIT_COUNTER_VALUE (" & integer'image(G_INIT_COUNTER_VALUE) & ") must be lower than G_PERIOD (" & integer'image(G_PERIOD) & ")"
      severity failure;
end entity;

architecture behavioral of static_pulse_width_modulator is
begin

   reset_policy : if G_START_ON_RESET = true generate

      process (clk_i) is
         variable counter : natural range 0 to G_PERIOD - 1 := G_INIT_COUNTER_VALUE;
      begin
         if rising_edge(clk_i) then
            if clk_en_i = '1' then
               if rst_i = '1' then
                  counter := 0;
               else
                  if counter = G_PERIOD - 1  then
                     counter := 0;
                  else
                     counter := counter + 1;
                  end if;
               end if;

               q_o <= '1';

               if counter >= G_DUTY then
                  q_o <= '0';
               end if;

               if en_i = '0' then
                  q_o <= G_DISABLED_VALUE;
               end if;
            end if;
         end if;
      end process;

   else generate

      process (clk_i) is
         variable counter : natural range 0 to G_PERIOD := G_INIT_COUNTER_VALUE;
      begin
         if rising_edge(clk_i) then
            if clk_en_i = '1' then
               if rst_i = '1' then
                  counter := 0;
               else
                  if counter = G_PERIOD then
                     counter := 1;
                  else
                     counter := counter + 1;
                  end if;
               end if;

               q_o <= '1';

               if counter = 0 then
                  q_o <= G_RESET_VALUE;
               elsif counter > G_DUTY then
                  q_o <= '0';
               end if;

               if en_i = '0' then
                  q_o <= G_DISABLED_VALUE;
               end if;
            end if;
         end if;
      end process;

   end generate;

end architecture;
