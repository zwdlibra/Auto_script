# TestProjects_root_topo.tcl --
#
# Copyright (c) 1994-2019 Shanghai Baud Data Communication Co., Ltd.

proc TestTopotypes_cleanup {} {
    foreach topotype $::global_project_topotypes_included {
        Bd_topo::Bd_topo_topomapping_release_handle $topotype
    }
}

proc TestTopotypes_init {} {
    foreach topotype $::global_project_topotypes_included {
        Bd_topo::Bd_topo_mapping_init $topotype
        $::logger info "TestTopo \"$topotype\" initialized"
    }
}

proc Topo_TestCase_init { testCaseName moduleName projectName } {
    TestCase_init_parse_cfg $testCaseName $moduleName
    Bd_topo::Bd_topo_activate_topo $::global_testcase_topo_required
    Replace_variable_inarray ::global_tc_checkpoint_cmd_array
    Replace_variable_inarray ::global_tc_checkpoint_expected_array
}

proc Topo_TestCase_root { testCaseName moduleName projectName } {
    set ::global_current_tc_name $testCaseName

    $::logger info "TestCase \"$projectName/$moduleName/$testCaseName\" start running ..."
    set start [clock seconds]

    Topo_TestCase_init $testCaseName $moduleName $projectName
    Topo_TestCase_start $testCaseName $moduleName $projectName
    TestCase_results_output $testCaseName $moduleName $projectName

    set end [clock seconds]
    $::logger info "TestCase \"$projectName/$moduleName/$testCaseName\" run completed in [timespan [expr $end - $start]]"
}

proc Topo_TestCase_start { testCaseName moduleName projectName } {
    if {[catch {
        $::logger info "======${::global_module_proc_prefix}_${testCaseName}_config_dut======"
        eval [concat ${::global_module_proc_prefix}_${testCaseName}_config_dut]

        $::logger info "======${::global_module_proc_prefix}_${testCaseName}======"
        set ret [eval [concat ${::global_module_proc_prefix}_${testCaseName}]]

        $::logger info "======${::global_module_proc_prefix}_${testCaseName}_cleanconfig_dut======"
        eval [concat ${::global_module_proc_prefix}_${testCaseName}_cleanconfig_dut]
    } errMsg]} {
        if {[Topo_TestCase_start_OnError $errMsg]} {
            error $errMsg $::errorInfo
        }
        $::logger error "$errMsg\nCall procedure-- :\n$::errorInfo\n"
        TestProjects_set_global_result -1 $projectName $moduleName $testCaseName
    } else {
        TestProjects_set_global_result $ret $projectName $moduleName $testCaseName
    }
}

proc Topo_TestCase_start_OnError { message } {
    return 1
}

proc Topo_TestModule_init { moduleName projectName } {
    package require $moduleName
    TestModule_init_parse_cfg $moduleName
    TestModule_init_parse_module_project_cfg $moduleName $projectName
}

proc Topo_TestModule_root { moduleName projectName } {
    set ::global_current_module_name $moduleName

    $::logger info "TestModule \"$projectName/$moduleName\" start running ..."
    set start [clock seconds]

    Topo_TestModule_init $moduleName $projectName
    Topo_TestModule_start $moduleName $projectName
    TestModule_results_output $moduleName $projectName

    set end [clock seconds]
    $::logger info "TestModule \"$projectName/$moduleName\" run completed in [timespan [expr $end - $start]]"
}

proc Topo_TestModule_start { moduleName projectName } {
    switch -exact -- $::opt(--order) {
        "IN_ORDER"      { set moduleTcIncluded $::global_module_tc_included }
        "REVERSE_ORDER" { set moduleTcIncluded [lreverse $::global_module_tc_included] }
        "OUT_OF_ORDER"  { set moduleTcIncluded [lshuffle $::global_module_tc_included] }
    }
    if {\
        ($::opt(--project) eq $projectName) &&\
        ($::opt(--module) eq $moduleName) &&\
        ([lsearch -exact $moduleTcIncluded $::opt(--testcase)] != -1)\
    } {
        Topo_TestCase_root $::opt(--testcase) $::opt(--module) $::opt(--project)
    } else {
        foreach testCaseName $moduleTcIncluded {
            if {[lsearch -exact $::opt(--ignore_list) "$projectName/$moduleName/$testCaseName"] != -1} {
                continue
            }
            Topo_TestCase_root $testCaseName $moduleName $projectName
        }
    }
}
