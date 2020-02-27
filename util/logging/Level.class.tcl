# Level.class.tcl --
#
# Copyright (c) 1994-2019 Shanghai Baud Data Communication Co., Ltd.

namespace eval util::logging {

    ::itcl::class Level {

        public common DEBUG 0
        public common INFO  1
        public common WARN  2
        public common ERROR 3

        public proc parse { value } {
            set value [string toupper $value]
            switch -exact -- $value {
                "DEBUG" -
                "INFO"  -
                "WARN"  -
                "ERROR" { return [expr $$value] }
                default { error "bad value \"$value\": must be DEBUG, INFO, WARN, or ERROR" }
            }
        }

        public proc toString { value } {
            switch -exact -- $value [subst {
                $DEBUG { return "DEBUG" }
                $INFO  { return "INFO" }
                $WARN  { return "WARN" }
                $ERROR { return "ERROR" }
                default { return "" }
            }]
        }
    }
}
