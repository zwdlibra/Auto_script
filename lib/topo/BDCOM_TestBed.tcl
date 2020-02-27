# BDCOM_TestBed.tcl --
#
# Copyright (c) 1994-2019 Shanghai Baud Data Communication Co., Ltd.

namespace eval Bd_topo {
    variable spawn_id_array
    array set spawn_id_array {}
}

proc Bd_topo::Bd_tbed_get_basemac { deviceName } {
    variable spawn_id_array

    if {![info exists ::global_project_topo_DUT_array($deviceName,basemac)]} {
        set ::global_project_topo_DUT_array($deviceName,basemac) [::Bd_expect_get_basemac\
                                                                    $spawn_id_array($deviceName)\
                                                                    $::global_project_topo_DUT_array($deviceName,type)]
    }
    return $::global_project_topo_DUT_array($deviceName,basemac)
}

proc Bd_topo::Bd_tbed_get_handle { deviceName } {
    variable spawn_id_array

    if {![info exists spawn_id_array($deviceName)]} {
        set spawn_id_array($deviceName) [::Bd_expect_login\
                                            $::global_project_topo_DUT_array($deviceName,cfg_ipaddr)\
                                            $::global_project_topo_DUT_array($deviceName,cfg_port)\
                                            $::global_project_topo_DUT_array($deviceName,username)\
                                            $::global_project_topo_DUT_array($deviceName,password)]
    }
    return $spawn_id_array($deviceName)
}

proc Bd_topo::Bd_tbed_get_intf_mac { deviceName ifindex } {
    variable spawn_id_array

    switch -exact -- [string totitle $::global_project_topo_DUT_array($deviceName,type)] {
        "Router" {
            if {![info exists ::global_project_topo_DUT_array($deviceName,${ifindex}_mac)]} {
                set ::global_project_topo_DUT_array($deviceName,${ifindex}_mac) [::Bd_expect_get_intf_mac\
                                                                                    $spawn_id_array($deviceName)\
                                                                                    $::global_project_topo_DUT_array($deviceName,$ifindex)]
            }
            return $::global_project_topo_DUT_array($deviceName,${ifindex}_mac)
        }
        "Switch" {
            if {[string match -nocase "VLAN*" $::global_project_topo_DUT_array($deviceName,$ifindex)]} {
                return $::global_project_topo_DUT_array($deviceName,basemac)
            } else {
                return ""
            }
        }
        default {
            return ""
        }
    }
}

proc Bd_topo::Bd_tbed_get_intf_name { deviceName ifindex } {
    return $::global_project_topo_DUT_array($deviceName,$ifindex)
}

proc Bd_topo::Bd_tbed_get_tester_intf_name { deviceName ifindex } {
    return "//$::global_project_topo_TESTER_array($deviceName,cfg_ipaddr)/$::global_project_topo_TESTER_array($deviceName,$ifindex)"
}

proc Bd_topo::Bd_tbed_get_tester_port_handle { deviceName ifindex } {
    return ""
}

proc Bd_topo::Bd_tbed_release_handle { deviceName } {
    variable spawn_id_array

    if {![info exists spawn_id_array($deviceName)]} {
        return
    }
    ::Bd_expect_logout $spawn_id_array($deviceName)
    unset spawn_id_array($deviceName)
}
