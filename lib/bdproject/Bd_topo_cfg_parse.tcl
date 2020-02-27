# Bd_topo_cfg_parse.tcl --
#
# Copyright (c) 1994-2019 Shanghai Baud Data Communication Co., Ltd.

proc TestProject_init_topo_parse_cfg { projectName } {
    $::logger debug "TestProject_init_topo_parse_cfg: $::global_config_files(TOPOLOGY,$projectName)"
    $::configParser load $::global_config_files(TOPOLOGY,$projectName)

    # %start_topotypes_included
    # ......
    # %end_topotypes_included
    set ::global_project_topotypes_included [$::configParser parse "topotypes_included"]
    $::logger debug "   ::global_project_topotypes_included :\
        \[[llength $::global_project_topotypes_included]\] $::global_project_topotypes_included"

    # %start_topomapping_included @TOPOTYPE
    # ......
    # %end_topomapping_included
    array unset ::global_topotypes_mapping_included
    array set ::global_topotypes_mapping_included {}
    foreach { topotype lines } [$::configParser parseAll "topomapping_included"] {
        set ::global_topotypes_mapping_included($topotype) [lindex $lines 0]
    }
    $::logger debug "   ::global_topotypes_mapping_included :\
        \[[array size ::global_topotypes_mapping_included]\]\n[array toString ::global_topotypes_mapping_included]"

    # %start_topomapping_DUT_TESTER_define @MAPPING_NAME
    # ......
    # %end_topomapping_DUT_TESTER_define
    array unset ::global_project_topo_tm_DUT_TESTER_array
    array set ::global_project_topo_tm_DUT_TESTER_array {}
    foreach { mappingName lines } [$::configParser parseAll "topomapping_DUT_TESTER_define"] {
        foreach { DUT device } [join $lines] {
            set ::global_project_topo_tm_DUT_TESTER_array($mappingName,$DUT) $device
        }
    }
    $::logger debug "   ::global_project_topo_tm_DUT_TESTER_array :\
        \[[array size ::global_project_topo_tm_DUT_TESTER_array]\]\n[array toString ::global_project_topo_tm_DUT_TESTER_array]"

    # %start_topomapping_PORT_define @MAPPING_NAME
    # ......
    # %end_topomapping_PORT_define
    array unset ::global_project_topo_tm_PORT_array
    array set ::global_project_topo_tm_PORT_array {}
    foreach { mappingName lines } [$::configParser parseAll "topomapping_PORT_define"] {
        foreach { PORT interface } [join $lines] {
            set ::global_project_topo_tm_PORT_array($mappingName,$PORT) $interface
        }
    }
    $::logger debug "   ::global_project_topo_tm_PORT_array :\
        \[[array size ::global_project_topo_tm_PORT_array]\]\n[array toString ::global_project_topo_tm_PORT_array]"

    # %start_tbed_TESTER_define @DEVICE_NAME
    # ......
    # %end_tbed_TESTER_define
    array unset ::global_project_topo_TESTER_array
    array set ::global_project_topo_TESTER_array {}
    foreach { deviceName lines } [$::configParser parseAll "tbed_TESTER_define"] {
        foreach { attrName attrValue } [join $lines] {
            set ::global_project_topo_TESTER_array($deviceName,$attrName) $attrValue
        }
    }
    $::logger debug "   ::global_project_topo_TESTER_array :\
        \[[array size ::global_project_topo_TESTER_array]\]\n[array toString ::global_project_topo_TESTER_array]"

    # %start_tbed_DUT_define @DEVICE_NAME
    # ......
    # %end_tbed_DUT_define
    array unset ::global_project_topo_DUT_array
    array set ::global_project_topo_DUT_array {}
    foreach { deviceName lines } [$::configParser parseAll "tbed_DUT_define"] {
        foreach { attrName attrValue } [join $lines] {
            set ::global_project_topo_DUT_array($deviceName,$attrName) $attrValue
        }
    }
    $::logger debug "   ::global_project_topo_DUT_array :\
        \[[array size ::global_project_topo_DUT_array]\]\n[array toString ::global_project_topo_DUT_array]"
}
