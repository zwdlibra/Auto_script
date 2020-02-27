# Bdcom_autotest_tester.pkg.tcl --
#
# Copyright (c) 1994-2019 Shanghai Baud Data Communication Co., Ltd.
package require common
package require Itcl
package require SpirentTestCenter
package require struct::matrix
package provide Bdcom_autotest_tester 1.0

set __DIR__ [file join [file dirname [info script]] "tester"]

source [file join $__DIR__ "TestCenter.class.tcl"]
source [file join $__DIR__ "TestCenter" "CommandSequencer.class.tcl"]
source [file join $__DIR__ "TestCenter" "CommandSequencer" "CommandTable.class.tcl"]
