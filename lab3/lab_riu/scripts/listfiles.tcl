# usage:
#
# quartus_sh -t scripts/listfiles.tcl project.qpf
#
# lists SDC and Verilog files in the Quartus project

project_open "[lindex $argv 0]"

set files 0
set nexist 0

foreach_in_collection global [get_all_global_assignments -name *_FILE] {
	set fn [lindex $global 2]
	if {[string equal [lindex $global 1] "SDC_FILE"]} {
		# do nothing
	} elseif {[string equal [lindex $global 1] "VERILOG_FILE"]} {
		# do nothing
	} elseif {[string equal [lindex $global 1] "SYSTEMVERILOG_FILE"]} {
		# do nothing
	} else {
		continue
	}
	puts "$fn"
	incr files
	if { ! [file exists $fn ] } {
		incr nexist
	}
}

puts "$files files, $nexist nonexistant"
puts -nonewline "top-level module: "
foreach_in_collection global [get_all_global_assignments -name TOP_LEVEL_ENTITY] {
	puts [lindex $global 2]
}
