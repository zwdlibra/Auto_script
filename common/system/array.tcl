# array.tcl --
#
# Copyright (c) 1994-2019 Shanghai Baud Data Communication Co., Ltd.

rename array theRealArray
proc array { option arrayName args } {
    switch -exact -- $option {
        "merge" {
            return [uplevel 1 [concat ArrayMerge $arrayName $args]]
        }
        "toString" {
            return [uplevel 1 [concat ArrayToString $arrayName $args]]
        }
        "values" {
            return [uplevel 1 [concat ArrayValues $arrayName $args]]
        }
        default {
            return [uplevel 1 [concat theRealArray $option $arrayName $args]]
        }
    }
}

proc ArrayMerge { arrayName args } {
    upvar 1 $arrayName array

    theRealArray set arr [theRealArray get array]
    foreach arg $args {
        upvar 1 $arg array
        theRealArray set arr [theRealArray get array]
    }

    return [array get arr]
}

proc ArrayToString { arrayName { pattern "*" } } {
    upvar 1 $arrayName array

    set maxl 0
    foreach name [theRealArray names array $pattern] {
        set l [string length $name]
        if {$l > $maxl} {
            set maxl $l
        }
    }
    set maxl [expr $maxl+[string length $arrayName]+2]

    set str ""
    foreach name [lsort [theRealArray names array $pattern]] {
        set nameString [format "%s(%s)" $arrayName $name]
        append str [format "%-*s = %s\n" $maxl $nameString $array($name)]
    }

    return [string range $str 0 end-1]
}

proc ArrayValues { arrayName { pattern "*" } } {
    upvar 1 $arrayName array

    set ret {}
    foreach { name value } [theRealArray get array $pattern] {
        lappend ret $value
    }

    return $ret
}
