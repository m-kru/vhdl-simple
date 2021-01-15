--------------------------------------------------------------------------------
-- vhdl_simple library
-- https://github.com/m-kru/vhdl_simple
--------------------------------------------------------------------------------
--
-- Entity: Serial-In Parallel-Out (SIPO) register.
--
-- Description:
--  SIPO register which can be configured to work with or without output
--  register. When G_REGISTER_OUTPUTS is set to false, the strobe_i input can
--  be left unconnected.
--
--------------------------------------------------------------------------------
-- Copyright (c) 2020 Michal Kruszewski
--------------------------------------------------------------------------------
-- MIT License
--------------------------------------------------------------------------------
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;

entity sipo_register is
  generic (
    G_WIDTH            : positive  := 8;
    G_INIT_VALUE       : std_logic := 'U';
    G_RESET_VALUE      : std_logic := '0';
    G_REGISTER_OUTPUTS : boolean   := true
  );
  port (
    clk_i    : in   std_logic;
    rst_i    : in   std_logic := '0';
    d_i      : in   std_logic;
    d_o      : out  std_logic;
    q_o      : out  std_logic_vector(G_WIDTH - 1 downto 0); -- Parallel output
    -- Strobe is used only if G_REGISTER_OUTPUTS is set to true.
    strobe_i : in   std_logic := 'U'
  );

end entity sipo_register;

architecture rtl of sipo_register is

  signal q_internal : std_logic_vector(G_WIDTH - 1 downto 0) := (others => G_INIT_VALUE);
  signal q_output   : std_logic_vector(G_WIDTH - 1 downto 0) := (others => G_INIT_VALUE);

begin

  d_o <= q_internal(G_WIDTH - 1);

  shift : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        q_internal <= (others => G_RESET_VALUE);
      else
        for i in 0 to G_WIDTH - 1 loop
          if i = 0 then
            q_internal(0) <= d_i;
          else
            q_internal(i) <= q_internal(i - 1);
          end if;
        end loop;
      end if;
    end if;
  end process shift;


  register_outputs : if G_REGISTER_OUTPUTS generate

    q_o <= q_output;

    process (clk_i) is
    begin

      if rising_edge(clk_i) then
        if rst_i = '1' then
          q_output <= (others => G_RESET_VALUE);
        elsif strobe_i = '1' then
          q_output <= q_internal;
        end if; 
      end if;

    end process;

  else generate

    q_o <= q_internal;

  end generate register_outputs;

end architecture rtl;
