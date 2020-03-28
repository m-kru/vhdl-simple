--------------------------------------------------------------------------------
-- vhdl_simple library
-- https://github.com/m-kru/vhdl_simple
--------------------------------------------------------------------------------
--
-- Entity: Asynchronous multiplexer with 8 inputs and 1 output.
--
-- Description:
--  Simple asynchronous multiplexer with 8 inputs, 1 output
--  and parameterized data width.
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

entity mux_8x1 is
  generic (
    G_WIDTH : positive := 1
  );
  port (
    addr_i : in    std_logic_vector(2 downto 0);
    in_0_i : in    std_logic_vector(G_WIDTH - 1 downto 0) := (others => 'X');
    in_1_i : in    std_logic_vector(G_WIDTH - 1 downto 0) := (others => 'X');
    in_2_i : in    std_logic_vector(G_WIDTH - 1 downto 0) := (others => 'X');
    in_3_i : in    std_logic_vector(G_WIDTH - 1 downto 0) := (others => 'X');
    in_4_i : in    std_logic_vector(G_WIDTH - 1 downto 0) := (others => 'X');
    in_5_i : in    std_logic_vector(G_WIDTH - 1 downto 0) := (others => 'X');
    in_6_i : in    std_logic_vector(G_WIDTH - 1 downto 0) := (others => 'X');
    in_7_i : in    std_logic_vector(G_WIDTH - 1 downto 0) := (others => 'X');
    out_o  : out   std_logic_vector(G_WIDTH - 1 downto 0)
  );
end entity mux_8x1;

architecture rtl of mux_8x1 is

begin

  with addr_i select
  out_o <= in_1_i when "001",
           in_2_i when "010",
           in_3_i when "011",
           in_4_i when "100",
           in_5_i when "101",
           in_6_i when "110",
           in_7_i when "111",
           in_0_i when others;

end architecture rtl;
