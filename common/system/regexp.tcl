# regexp.tcl --
#
# Copyright (c) 1994-2019 Shanghai Baud Data Communication Co., Ltd.

proc regesc { string } {
    return [string map {
        "$"  "\\$"
        "("  "\\("
        ")"  "\\)"
        "*"  "\\*"
        "+"  "\\+"
        "."  "\\."
        "["  "\\["
        "]"  "\\]"
        "?"  "\\?"
        "\\" "\\\\"
        "^"  "\\^"
        "{"  "\\{"
        "}"  "\\}"
        "|"  "\\|"
        } $string]
}
