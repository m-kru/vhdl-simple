library ieee;
   use ieee.std_logic_1164.all;

package simple is

   type t_slv_vector is array (natural range <>) of std_logic_vector;
   type t_slv_vector_2d is array (natural range <>) of t_slv_vector;
   type t_slv_vector_3d is array (natural range <>) of t_slv_vector_2d;

end package;
