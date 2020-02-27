# list.tcl --
#
# Copyright (c) 1994-2019 Shanghai Baud Data Communication Co., Ltd.

proc lreverse { list } {
    set first 0
    set last [expr [llength $list] - 1]
    while {$first < $last} {
        lswap list $first $last
        incr first
        incr last -1
    }

    return $list
}

proc lshuffle { list } {
    expr srand([clock seconds])
    for {set i [expr [llength $list] - 1]} {$i >= 0} {incr i -1} {
        set index [expr int(rand() * ($i + 1))]
        if {$index != $i} {
            lswap list $index $i
        }
    }

    return $list
}

proc lswap { varName index1 index2 } {
    upvar 1 $varName list

    set temp [lindex $list $index2]
    lset list $index2 [lindex $list $index1]
    lset list $index1 $temp

    return $list
}
