# util.pkg.tcl --
#
# Copyright (c) 1994-2019 Shanghai Baud Data Communication Co., Ltd.
package require common
package require Itcl
package provide util 1.0

set __DIR__ [file dirname [info script]]

source [file join $__DIR__ "ConfigParser.class.tcl"]
source [file join $__DIR__ "logging" "Level.class.tcl"]
source [file join $__DIR__ "logging" "Logger.class.tcl"]
source [file join $__DIR__ "logging" "LogManager.class.tcl"]
source [file join $__DIR__ "logging" "LogRecord.class.tcl"]
