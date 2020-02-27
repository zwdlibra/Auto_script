# common.tcl --
#
# Copyright (c) 1994-2019 Shanghai Baud Data Communication Co., Ltd.

proc formatMacAddr { macAddr } {
    set macAddr [string tolower $macAddr]
    switch -regexp -- $macAddr {
        {^([0-9a-f]{2}:){5}[0-9a-f]{2}$} {
            return $macAddr
        }
        {^([0-9a-f]{2}-){5}[0-9a-f]{2}$} {
            return [string map { "-" ":" } $macAddr]
        }
        {^([0-9a-f]{4}\.){2}[0-9a-f]{4}$} {
            set hex [format "0x%s" [string map { "." "" } $macAddr]]
        }
        {^[0-9a-f]{12}$} {
            set hex [format "0x%s" $macAddr]
        }
        default {
            return $macAddr
        }
    }

    return [format "%02x:%02x:%02x:%02x:%02x:%02x"\
        [expr ($hex >> (8 * 5)) & 0xff]\
        [expr ($hex >> (8 * 4)) & 0xff]\
        [expr ($hex >> (8 * 3)) & 0xff]\
        [expr ($hex >> (8 * 2)) & 0xff]\
        [expr ($hex >> (8 * 1)) & 0xff]\
        [expr ($hex >> (8 * 0)) & 0xff]]
}

rename puts print
proc puts args {
    uplevel 1 [concat print $args]
}

proc timespan { totalSeconds } {
    set SECONDS_PER_MINUTE 60
    set SECONDS_PER_HOUR [expr 60 * $SECONDS_PER_MINUTE]
    set SECONDS_PER_DAY [expr 24 * $SECONDS_PER_HOUR]

    return [format "%s.%02s:%02s:%02s"\
        [expr $totalSeconds / $SECONDS_PER_DAY]\
        [expr $totalSeconds % $SECONDS_PER_DAY / $SECONDS_PER_HOUR]\
        [expr $totalSeconds % $SECONDS_PER_DAY % $SECONDS_PER_HOUR / $SECONDS_PER_MINUTE]\
        [expr $totalSeconds % $SECONDS_PER_DAY % $SECONDS_PER_HOUR % $SECONDS_PER_MINUTE]]
}

proc sleep { seconds } {
    set timeout 0
    after [expr $seconds*1000] set timeout 1
    vwait timeout
}
