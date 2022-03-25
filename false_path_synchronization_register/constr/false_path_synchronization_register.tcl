if {[string match "Vivado*" [version]]} {
    set_property SCOPED_TO_REF False_Path_Synchronization_Register [get_files False_Path_Synchronization_Register.xdc]
} else {
    error "False_Path_Synchronization_Register entity misses constraint file for your EDA tool"
}
