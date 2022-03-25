-- SPDX-License-Identifier: MIT
-- https://github.com/m-kru/vhdl-simple
-- Copyright (c) 2021 Michał Kruszewski

library ieee;
   use ieee.std_logic_1164.all;

-- static_pulse_width_modulator is a simple PWM (Pulse-Width Modulation) entity
-- with the duty cycle statically configured.
-- 
-- Both PERIOD and DUTY are in clock cycles!
-- This requires some calculation to be done by the user.
-- However it gives better control, because the user decides how to round.
-- Useful when PERIOD and DUTY are relatively small numbers.
--
-- DISABLED_VALUE is the value set to the q_o when module is disabled.
--
-- START_ON_RESET determines whether counting should start on reset
-- (START_ON_RESET = true) or after the rst_i is deasserted
-- (START_ON_RESET = false). RESET_VALUE is used only if
-- START_ON_RESET = false.
entity Static_Pulse_Width_Modulator is
   generic (
      PERIOD             : positive;
      DUTY               : positive;
      INIT_VALUE         : std_logic := '0';
      INIT_COUNTER_VALUE : natural   := 0;
      DISABLED_VALUE     : std_logic := '0';
      START_ON_RESET     : boolean   := true;
      RESET_VALUE        : std_logic := '0'
   );
   port (
      clk_i    : in  std_logic;
      clk_en_i : in  std_logic := '1';
      rst_i    : in  std_logic := '0';
      en_i     : in  std_logic := '1';
      q_o      : out std_logic := INIT_VALUE
   );
begin
   assert DUTY <= PERIOD
      report "DUTY (" & integer'image(DUTY) & ") must be lower than PERIOD (" & integer'image(PERIOD) & ")"
      severity failure;

   assert DUTY /= 0
      report "DUTY = 0 makes no sense"
      severity failure;

   assert INIT_COUNTER_VALUE < PERIOD
      report "INIT_COUNTER_VALUE (" & integer'image(INIT_COUNTER_VALUE) & ") must be lower than PERIOD (" & integer'image(PERIOD) & ")"
      severity failure;
end entity;


architecture behavioral of static_pulse_width_modulator is
begin

   reset_policy : if START_ON_RESET = true generate

      process (clk_i) is
         variable counter : natural range 0 to PERIOD - 1 := INIT_COUNTER_VALUE;
      begin
         if rising_edge(clk_i) then
            if clk_en_i = '1' then
               if rst_i = '1' then
                  counter := 0;
               else
                  if counter = PERIOD - 1  then
                     counter := 0;
                  else
                     counter := counter + 1;
                  end if;
               end if;

               q_o <= '1';

               if counter >= DUTY then
                  q_o <= '0';
               end if;

               if en_i = '0' then
                  q_o <= DISABLED_VALUE;
               end if;
            end if;
         end if;
      end process;

   else generate

      process (clk_i) is
         variable counter : natural range 0 to PERIOD := INIT_COUNTER_VALUE;
      begin
         if rising_edge(clk_i) then
            if clk_en_i = '1' then
               if rst_i = '1' then
                  counter := 0;
               else
                  if counter = PERIOD then
                     counter := 1;
                  else
                     counter := counter + 1;
                  end if;
               end if;

               q_o <= '1';

               if counter = 0 then
                  q_o <= RESET_VALUE;
               elsif counter > DUTY then
                  q_o <= '0';
               end if;

               if en_i = '0' then
                  q_o <= DISABLED_VALUE;
               end if;
            end if;
         end if;
      end process;

   end generate;

end architecture;
