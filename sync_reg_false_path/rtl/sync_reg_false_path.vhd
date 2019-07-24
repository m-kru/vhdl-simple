--------------------------------------------------------------------------------
-- vhdl_simple library
-- https://github.com/m-kru/vhdl_simple
--------------------------------------------------------------------------------
--
-- Entity: Clock Domain Crossing (CDC) synchronizer with set false path.
--
-- Description:
--  Setting false path on CDC is not recommmended, as it does not guarantee
--  coherency between signals. However, if you consciously do not care about
--  the latency and coherency, setting false path can be really useful as it
--  loosens the constraints for Place & Route algorithms.
--
--------------------------------------------------------------------------------
-- Copyright (c) 2019 Michal Kruszewski
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

entity sync_reg_false_path is
  generic (
    G_WIDTH      : natural := 0;
    G_INIT_VALUE : std_logic := '0'
  );
  port (
    clk_i : in  std_logic;
    d_i   : in  std_logic_vector(G_WIDTH-1 downto 0);
    q_o   : out std_logic_vector(G_WIDTH-1 downto 0)
  );
end sync_reg_false_path;

-- Disable Quartus warning about unrecognized attributes.
-- altera message_off 10335

architecture rtl of sync_reg_false_path is
  
  signal s_0, s_1 : std_logic_vector(G_WIDTH-1 downto 0) := (others => G_INIT_VALUE);

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

  process(clk_i)
  begin
    if rising_edge(clk_i) then
      s_0 <= d_i;
      s_1 <= s_0;
    end if;
  end process;

  q_o <= s_1;

end rtl;
