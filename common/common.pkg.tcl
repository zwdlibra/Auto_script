# common.pkg.tcl --
#
# Copyright (c) 1994-2019 Shanghai Baud Data Communication Co., Ltd.
package provide common 1.0

set __DIR__ [file dirname [info script]]

source [file join $__DIR__ "system" "array.tcl"]
source [file join $__DIR__ "system" "file.tcl"]
source [file join $__DIR__ "system" "list.tcl"]
source [file join $__DIR__ "system" "regexp.tcl"]
source [file join $__DIR__ "common.tcl"]
