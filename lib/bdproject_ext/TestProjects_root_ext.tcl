# TestProjects_root_ext.tcl --
#
# Copyright (c) 1994-2019 Shanghai Baud Data Communication Co., Ltd.

proc TestProject_start { projectName } {
    array set moduleProcPrefix {}
    array set moduleTcIncluded {}
    array set moduleVar {}

    foreach moduleName $::global_project_module_included {
        if {[lsearch -exact $::opt(--ignore_list) "$projectName/$moduleName"] != -1} {
            continue
        }
        Topo_TestModule_init $moduleName $projectName
        set moduleProcPrefix($moduleName) $::global_module_proc_prefix
        foreach testCaseName $::global_module_tc_included {
            if {[lsearch -exact $::opt(--ignore_list) "$projectName/$moduleName/$testCaseName"] != -1} {
                continue
            }
            lappend moduleTcIncluded($moduleName) $testCaseName
        }
        set moduleVar($moduleName) [array get ::global_module_var]
    }

    while {[array size moduleTcIncluded] > 0} {
        expr srand([clock seconds])
        set i [expr int(rand() * [llength [array names moduleTcIncluded]])]
        set moduleName [lindex [array names moduleTcIncluded] $i]
        set ::global_current_module_name $moduleName
        set j [expr int(rand() * [llength $moduleTcIncluded($moduleName)])]
        set testCaseName [lindex $moduleTcIncluded($moduleName) $j]
        set ::global_current_tc_name $testCaseName

        set ::global_module_proc_prefix $moduleProcPrefix($moduleName)

        array unset ::global_module_var
        array set ::global_module_var $moduleVar($moduleName)

        Topo_TestCase_root $testCaseName $moduleName $projectName

        set moduleTcIncluded($moduleName) [lreplace $moduleTcIncluded($moduleName) $j $j]
        if {[llength $moduleTcIncluded($moduleName)] == 0} {
            unset moduleTcIncluded($moduleName)
        }
    }
}
