if {[string match "Vivado*" [version]]} {
    set_property SCOPED_TO_REF reset_synchronizer [get_files reset_synchronizer.xdc]
} else {
    error "reset_synchronizer entity misses constraint file for your EDA tool"
}
