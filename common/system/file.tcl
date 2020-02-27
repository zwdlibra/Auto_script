# file.tcl --
#
# Copyright (c) 1994-2019 Shanghai Baud Data Communication Co., Ltd.

rename file theRealFile
proc file { option arg args } {
    set arg [list $arg]
    switch -exact -- $option {
        "cat" {
            return [uplevel 1 [concat FileCat $arg]]
        }
        default {
            return [uplevel 1 [concat theRealFile $option $arg $args]]
        }
    }
}

proc FileCat { path } {
    set fileHandle [open $path "r"]
    set data [read $fileHandle]
    close $fileHandle

    return $data
}
