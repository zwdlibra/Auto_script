# TestProjects_root.tcl --
#
# Copyright (c) 1994-2019 Shanghai Baud Data Communication Co., Ltd.

proc TestCase_results_output { testCaseName moduleName projectName } {
    $::logger info "::global_result($projectName,$moduleName,$testCaseName) = $::global_result($projectName,$moduleName,$testCaseName)"
}

proc TestModule_results_output { moduleName projectName } {
    parray ::global_result "$projectName,$moduleName,*"
}

proc TestProject_init { projectName } {
    TestProject_init_topo_parse_cfg $projectName
    TestProject_init_parse_cfg $projectName
}

proc TestProject_results_output { projectName } {
    parray ::global_result "$projectName,*"
}

proc TestProject_root { projectName } {
    set ::global_current_project_name $projectName

    $::logger info "TestProject \"$projectName\" start running ..."
    set start [clock seconds]

    TestProject_init $projectName
    TestTopotypes_init
    TestProject_start $projectName
    TestTopotypes_cleanup
    TestProject_results_output $projectName

    set end [clock seconds]
    $::logger info "TestProject \"$projectName\" run completed in [timespan [expr $end - $start]]"
}

proc TestProject_start { projectName } {
    switch -exact -- $::opt(--order) {
        "IN_ORDER"      { set projectModuleIncluded $::global_project_module_included }
        "REVERSE_ORDER" { set projectModuleIncluded [lreverse $::global_project_module_included] }
        "OUT_OF_ORDER"  { set projectModuleIncluded [lshuffle $::global_project_module_included] }
    }
    if {\
        ($::opt(--project) eq $projectName) &&\
        ([lsearch -exact $projectModuleIncluded $::opt(--module)] != -1)\
    } {
        Topo_TestModule_root $::opt(--module) $::opt(--project)
    } else {
        foreach moduleName $projectModuleIncluded {
            if {[lsearch -exact $::opt(--ignore_list) "$projectName/$moduleName"] != -1} {
                continue
            }
            Topo_TestModule_root $moduleName $projectName
        }
    }
}

proc TestProjects_init {} {
    TestProjects_init_parse_cfg
}

proc TestProjects_results_output {} {
    parray ::global_result
}

proc TestProjects_root {} {
    TestProjects_init
    TestProjects_start
    TestProjects_results_output
}

proc TestProjects_set_global_result { testCaseResult projectName moduleName testCaseName } {
    set ::global_result($projectName,$moduleName,$testCaseName) $testCaseResult
}

proc TestProjects_start {} {
    set projectsProjectIncluded $::global_projects_project_included
    if {[lsearch -exact $projectsProjectIncluded $::opt(--project)] != -1} {
        TestProject_root $::opt(--project)
    } else {
        foreach projectName $projectsProjectIncluded {
            if {[lsearch -exact $::opt(--ignore_list) $projectName] != -1} {
                continue
            }
            TestProject_root $projectName
        }
    }
}
