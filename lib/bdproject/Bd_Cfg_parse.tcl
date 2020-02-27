# Bd_Cfg_parse.tcl --
#
# Copyright (c) 1994-2019 Shanghai Baud Data Communication Co., Ltd.

proc BD_get_tc_from_module { tcInModuleBuffer } {
    set tcListInModule [lsort -dictionary $::global_tclist_from_tc_in_module]
    if {$tcInModuleBuffer eq "ALL"} {
        return $tcListInModule
    }

    set tcList {}
    foreach line $tcInModuleBuffer {
        if {[llength $tcListInModule] == 0} {
            break
        }
        switch -exact -- [scan $line "%s%s" tcStart tcEnd] {
            2 {
                set startIndex [lsearch -exact $tcListInModule $tcStart]
                if {$startIndex == -1} {
                    set startIndex [lsearch -exact [lsort -dictionary [linsert $tcListInModule 0 $tcStart]] $tcStart]
                }
                set endIndex [lsearch -exact $tcListInModule $tcEnd]
                if {$endIndex == -1} {
                    set endIndex [lsearch -exact [lsort -dictionary [linsert $tcListInModule end $tcEnd]] $tcEnd]
                    incr endIndex -1
                }
                if {$endIndex < $startIndex} {
                    continue
                }
            }
            1 {
                set startIndex [lsearch -exact $tcListInModule $tcStart]
                if {$startIndex == -1} {
                    continue
                }
                set endIndex $startIndex
            }
        }
        eval [concat lappend tcList [lrange $tcListInModule $startIndex $endIndex]]
        set tcListInModule [lreplace $tcListInModule $startIndex $endIndex]
    }

    return $tcList
}

proc Replace_variable { varName } {
    upvar 1 $varName lines

    for {set i 0} {$i < [llength $lines]} {incr i} {
        set line [lindex $lines $i]
        regsub -all {%(?=\w+\([\w,]+\))} $line "\$::Bd_topo::" line
        while {\
            [regexp {\$(\w+)(?=(?!\()\W|$)} $line match varName] ||\
            [regexp {\$\{(\w+)\}} $line match varName]\
        } {
            regsub -all [regesc $match] $line "\$::global_tc_var($varName)" line
        }
        lset lines $i [subst $line]
    }

    return $lines
}

proc Replace_variable_inarray { arrayName } {
    upvar 1 $arrayName array

    foreach { name value } [array get array] {
        Replace_variable value
        set array($name) $value
    }
}

proc TestCase_init_parse_cfg { testCaseName moduleName } {
    $::logger debug "TestCase_init_parse_cfg: $::global_config_files(TESTCASE,$moduleName,$testCaseName)"
    $::configParser load $::global_config_files(TESTCASE,$moduleName,$testCaseName)

    # %start_testcase_topo_required @TESTCASE_NAME
    # ......
    # %end_testcase_topo_required
    set ::global_testcase_topo_required [lindex [$::configParser parse "testcase_topo_required" $testCaseName] 0]
    $::logger debug "   ::global_testcase_topo_required = $::global_testcase_topo_required"

    # %start_checkpoint_cmd @TESTCASE_NAME @NAME
    # ......
    # %end_checkpoint_cmd
    array unset ::global_tc_checkpoint_cmd_array
    array set ::global_tc_checkpoint_cmd_array [$::configParser parseAll "checkpoint_cmd" $testCaseName]
    $::logger debug "   ::global_tc_checkpoint_cmd_array :\
        \[[array size ::global_tc_checkpoint_cmd_array]\]\n[array toString ::global_tc_checkpoint_cmd_array]"

    # %start_checkpoint_expected @TESTCASE_NAME @NAME
    # ......
    # %end_checkpoint_expected
    array unset ::global_tc_checkpoint_expected_array
    array set ::global_tc_checkpoint_expected_array [$::configParser parseAll "checkpoint_expected" $testCaseName]
    $::logger debug "   ::global_tc_checkpoint_expected_array :\
        \[[array size ::global_tc_checkpoint_expected_array]\]\n[array toString ::global_tc_checkpoint_expected_array]"

    # %start_define @TESTCASE_NAME
    # ......
    # %end_define
    array unset ::global_tc_var
    array set testCaseVar [join [$::configParser parse "define" $testCaseName]]
    array set ::global_tc_var [array merge ::global_module_var testCaseVar]
    $::logger debug "   ::global_tc_var :\
        \[[array size ::global_tc_var]\]\n[array toString ::global_tc_var]"
}

proc TestModule_init_parse_cfg { moduleName } {
    $::logger debug "TestModule_init_parse_cfg: $::global_config_files(MODULE,$moduleName)"
    $::configParser load $::global_config_files(MODULE,$moduleName)

    # %start_testcase_in_module
    # ......
    # %end_testcase_in_module
    set ::global_tclist_from_tc_in_module {}
    foreach line [$::configParser parse "testcase_in_module"] {
        scan $line "%s%s" testCaseName testCaseConfigFileName
        if {![info exists ::global_config_files(TESTCASE,$moduleName,$testCaseName)]} {
            set ::global_config_files(TESTCASE,$moduleName,$testCaseName) [file normalize [file join $::MODULE_DIR($moduleName) $testCaseConfigFileName]]
        }
        lappend ::global_tclist_from_tc_in_module $testCaseName
    }
    $::logger debug "   ::global_tclist_from_tc_in_module :\
        \[[llength $::global_tclist_from_tc_in_module]\] $::global_tclist_from_tc_in_module"

    # %start_define
    # ......
    # %end_define
    array unset ::global_module_var
    array set moduleVar [join [$::configParser parse "define"]]
    array set ::global_module_var [array merge ::global_project_var moduleVar]
    $::logger debug "   ::global_module_var :\
        \[[array size ::global_module_var]\]\n[array toString ::global_module_var]"

    # %start_module_proc_prefix
    # ......
    # %end_module_proc_prefix
    set ::global_module_proc_prefix [lindex [$::configParser parse "module_proc_prefix"] 0]
    $::logger debug "   ::global_module_proc_prefix = $::global_module_proc_prefix"
}

proc TestModule_init_parse_module_project_cfg { moduleName projectName } {
    $::logger debug "TestModule_init_parse_module_project_cfg: $::global_config_files(MODULE_PROJECT,$projectName,$moduleName)"
    $::configParser load $::global_config_files(MODULE_PROJECT,$projectName,$moduleName)

    # %start_testcase_included @PROJECT_NAME
    # ......
    # %end_testcase_included
    set ::global_module_tc_included [BD_get_tc_from_module [$::configParser parse "testcase_included" $projectName]]
    $::logger debug "   ::global_module_tc_included :\
        \[[llength $::global_module_tc_included]\] $::global_module_tc_included"

    # %start_define @PROJECT_NAME
    # ......
    # %end_define
    array set moduleProjectVar [join [$::configParser parse "define" $projectName]]
    array set ::global_module_var [array merge ::global_module_var moduleProjectVar]
    $::logger debug "   ::global_module_var :\
        \[[array size ::global_module_var]\]\n[array toString ::global_module_var]"
}

proc TestProject_init_parse_cfg { projectName } {
    $::logger debug "TestProject_init_parse_cfg: $::global_config_files(PROJECT,$projectName)"
    $::configParser load $::global_config_files(PROJECT,$projectName)

    # %start_module_included
    # ......
    # %end_module_included
    set ::global_project_module_included {}
    foreach line [$::configParser parse "module_included"] {
        scan $line "%s%s%s" moduleName moduleConfigFileName moduleProjectConfigFileName
        if {![info exists ::global_config_files(MODULE,$moduleName)]} {
            set ::global_config_files(MODULE,$moduleName) [file normalize [file join $::MODULE_DIR($moduleName) $moduleConfigFileName]]
        }
        set ::global_config_files(MODULE_PROJECT,$projectName,$moduleName) [file normalize [file join $::PROJECT_DIR $moduleProjectConfigFileName]]
        lappend ::global_project_module_included $moduleName
    }
    $::logger debug "   ::global_project_module_included :\
        \[[llength $::global_project_module_included]\] $::global_project_module_included"

    # %start_define
    # ......
    # %end_define
    array unset ::global_project_var
    array set ::global_project_var [join [$::configParser parse "define"]]
    $::logger debug "   ::global_project_var :\
        \[[array size ::global_project_var]\]\n[array toString ::global_project_var]"
}

proc TestProjects_init_parse_cfg {} {
    $::logger debug "TestProjects_init_parse_cfg: $::global_config_files(ROOT)"
    $::configParser load $::global_config_files(ROOT)

    # %start_testprojects_include
    # ......
    # %end_testprojects_include
    foreach line [$::configParser parse "testprojects_include"] {
        scan $line "%s%s%s" projectName projectConfigFileName topologyFileName
        set ::global_config_files(PROJECT,$projectName) [file normalize [file join $::PROJECT_DIR $projectConfigFileName]]
        set ::global_config_files(TOPOLOGY,$projectName) [file normalize [file join $::TOPOLOGY_DIR $topologyFileName]]
        lappend ::global_projects_project_included $projectName
    }
    $::logger debug "   ::global_projects_project_included :\
        \[[llength $::global_projects_project_included]\] $::global_projects_project_included"
}
