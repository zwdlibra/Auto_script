# BD_TOPOTYPES.tcl --
#
# Copyright (c) 1994-2019 Shanghai Baud Data Communication Co., Ltd.

variable BD_TOPOTYPES [dict create]
foreach f [glob -join [file dirname [info script]] "BD_TOPOTYPES" "*.json"] {
    dict append BD_TOPOTYPES [file rootname [file tail $f]] [json::json2dict [file cat $f]]
}
