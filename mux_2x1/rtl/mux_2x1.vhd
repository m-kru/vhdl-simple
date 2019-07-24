--------------------------------------------------------------------------------
-- vhdl_simple library
-- https://github.com/m-kru/vhdl_simple
--------------------------------------------------------------------------------
--
-- Entity: Asynchronous multiplexer with 2 inputs and 1 output.
--
-- Description:
--  Simple asynchronous multiplexer with 2 inputs, 1 output
--  and parameterized data width.
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

entity mux_2x1 is
  generic (
    G_WIDTH : natural := 0
  );
  port (
    addr_i : in  std_logic;
    in_0_i : in  std_logic_vector(G_WIDTH-1 downto 0);
    in_1_i : in  std_logic_vector(G_WIDTH-1 downto 0);
    out_o  : out std_logic_vector(G_WIDTH-1 downto 0)
  );
end mux_2x1;

architecture rtl of mux_2x1 is

begin

  with addr_i select
    out_o <= in_1_i when '1',
             in_0_i when others;

end rtl;
