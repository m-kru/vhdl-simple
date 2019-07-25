if {[string match "Vivado*" [version]]} {
    set_property SCOPED_TO_REF sync_reg_false_path [get_files sync_reg_false_path.xdc]
} else {
    error "sync_reg_false_path entity misses constraint file for your EDA tool"
}
