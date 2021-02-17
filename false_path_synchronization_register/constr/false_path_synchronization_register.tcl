if {[string match "Vivado*" [version]]} {
    set_property SCOPED_TO_REF false_path_synchronization_register [get_files false_path_synchronization_register.xdc]
} else {
    error "false_path_synchronization_register entity misses constraint file for your EDA tool"
}
