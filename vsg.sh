set -e
vsg -f mux_2x1/rtl/mux_2x1.vhd -c vsg_config.yaml
vsg -f reset_synchronizer/rtl/reset_synchronizer.vhd -c vsg_config.yaml
vsg -f accumulative_bit_array/rtl/accumulative_bit_array.vhd -c vsg_config.yaml
vsg -f saturated_signed_adder/rtl/saturated_signed_adder.vhd -c vsg_config.yaml
vsg -f saturated_unsigned_adder/rtl/saturated_unsigned_adder.vhd -c vsg_config.yaml
