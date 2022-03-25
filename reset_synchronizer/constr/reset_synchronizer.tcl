if {[string match "Vivado*" [version]]} {
    set_property SCOPED_TO_REF Reset_Synchronizer [get_files reset_synchronizer.xdc]
} else {
    error "Reset_Synchronizer entity misses constraint file for your EDA tool"
}
