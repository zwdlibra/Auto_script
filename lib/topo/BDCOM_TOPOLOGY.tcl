# BDCOM_TOPOLOGY.tcl --
#
# Copyright (c) 1994-2019 Shanghai Baud Data Communication Co., Ltd.

namespace eval Bd_topo {
    variable cfg_handle
    array set cfg_handle {}

    variable intf
    array set intf {}

    variable mac
    array set mac {}
}

proc Bd_topo::Bd_topo_activate_topo { topotype } {
    variable cfg_handle
    variable intf
    variable mac

    array unset cfg_handle
    array set cfg_handle [array get ${topotype}::cfg_handle]

    array unset intf
    array set intf [array get ${topotype}::intf]

    array unset mac
    array set mac [array get ${topotype}::mac]
}

proc Bd_topo::Bd_topo_mapping_init { topotype } {
    if {![namespace exists $topotype]} {
        namespace eval $topotype {}
    }

    scan $::global_topotypes_mapping_included($topotype) "%s%s" dutMappingName portMappingName
    dict for { dut portList } [dict get $::BD_TOPOTYPES $topotype] {
        switch -glob -- $dut {
            "DUT*" {
                Bd_topo_set_dut $topotype $dut $dutMappingName
                foreach port $portList {
                    Bd_topo_set_port $topotype $port $portMappingName
                }
            }
            "TESTER1" {
                foreach port $portList {
                    Bd_topo_set_tester_port $topotype $port $portMappingName
                }
            }
        }
    }

    Bd_topo_show_all_topo_vars $topotype
}

proc Bd_topo::Bd_topo_set_dut { topotype dut mappingName } {
    set deviceName $::global_project_topo_tm_DUT_TESTER_array($mappingName,$dut)
    set ${topotype}::cfg_handle($dut) [Bd_tbed_get_handle $deviceName]
    set ${topotype}::mac($dut) [Bd_tbed_get_basemac $deviceName]
    set ${topotype}::tbed_bytm_array($dut) $deviceName
}

proc Bd_topo::Bd_topo_set_port { topotype port mappingName } {
    set interface $::global_project_topo_tm_PORT_array($mappingName,$port)
    scan [split $interface ","] "%s%s" deviceName ifindex
    set ${topotype}::intf($port) [Bd_tbed_get_intf_name $deviceName $ifindex]
    set ${topotype}::mac($port) [Bd_tbed_get_intf_mac $deviceName $ifindex]
    set ${topotype}::tbed_bytm_array($port) $interface
}

proc Bd_topo::Bd_topo_set_tester_port { topotype port mappingName } {
    set interface $::global_project_topo_tm_PORT_array($mappingName,$port)
    scan [split $interface ","] "%s%s" deviceName ifindex
    set ${topotype}::cfg_handle($port) [Bd_tbed_get_tester_port_handle $deviceName $ifindex]
    set ${topotype}::intf($port) [Bd_tbed_get_tester_intf_name $deviceName $ifindex]
    set ${topotype}::tbed_bytm_array($port) $interface
}

proc Bd_topo::Bd_topo_show_all_topo_vars { topotype } {
    $::logger debug "::Bd_topo {
[array toString ${topotype}::cfg_handle]\n
[array toString ${topotype}::intf]\n
[array toString ${topotype}::mac]\n
[array toString ${topotype}::tbed_bytm_array]
}"
}

proc Bd_topo::Bd_topo_topomapping_release_handle { topotype } {
    foreach dut [array names ${topotype}::tbed_bytm_array "DUT*"] {
        Bd_tbed_release_handle ${topotype}::tbed_bytm_array($dut)
    }
}
