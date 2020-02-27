# Bdcom_autotest_expect.pkg.tcl --
#
# Copyright (c) 1994-2019 Shanghai Baud Data Communication Co., Ltd.
package require common
package require Expect
package provide Bdcom_autotest_expect 1.0

fconfigure stderr -buffering line

set __DIR__ [file join [file dirname [info script]] "expect"]

source [file join $__DIR__ "Bd_expect.tcl"]
source [file join $__DIR__ "Bd_expect_checkpoint.tcl"]
source [file join $__DIR__ "Bd_expect_settings.tcl"]
source [file join $__DIR__ "Bd_expect_topo.tcl"]
source [file join $__DIR__ "Bdcom_autotest_expect.tcl"]
