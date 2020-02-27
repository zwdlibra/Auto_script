# Bdcom_autotest_bdproject.pkg.tcl --
#
# Copyright (c) 1994-2019 Shanghai Baud Data Communication Co., Ltd.
package require common
package require util
package require Bdcom_autotest_topo
package provide Bdcom_autotest_bdproject 1.0

set __DIR__ [file join [file dirname [info script]] "bdproject"]

source [file join $__DIR__ "Bd_Cfg_parse.tcl"]
source [file join $__DIR__ "Bd_topo_cfg_parse.tcl"]
source [file join $__DIR__ "Bdcom_autotest_bdproject.tcl"]
source [file join $__DIR__ "TestProjects_root.tcl"]
source [file join $__DIR__ "TestProjects_root_topo.tcl"]
