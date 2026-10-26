# Run from Vivado Tcl Console after opening Implemented Design.
# The maximum fan-out attribute is a synthesis hint, not a measured result.
report_high_fanout_nets -max_nets 20 -file fanout_after.rpt
report_timing_summary -file timing_after.rpt
