# Bdcom_autotest_topo.pkg.tcl --
#
# Copyright (c) 1994-2019 Shanghai Baud Data Communication Co., Ltd.
package require common
package require json
package require Bdcom_autotest_expect
package provide Bdcom_autotest_topo 1.0

set __DIR__ [file join [file dirname [info script]] "topo"]

source [file join $__DIR__ "BD_TOPOTYPES.tcl"]
source [file join $__DIR__ "BDCOM_TestBed.tcl"]
source [file join $__DIR__ "BDCOM_TOPOLOGY.tcl"]
