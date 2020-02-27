# Bdcom_autotest_bdproject_ext.pkg.tcl --
#
# Copyright (c) 1994-2019 Shanghai Baud Data Communication Co., Ltd.
package provide Bdcom_autotest_bdproject_ext 1.0

set __DIR__ [file join [file dirname [info script]] "bdproject_ext"]

source [file join $__DIR__ "TestProjects_root_ext.tcl"]
