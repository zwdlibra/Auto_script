# LogRecord.class.tcl --
#
# Copyright (c) 1994-2019 Shanghai Baud Data Communication Co., Ltd.

namespace eval util::logging {

    ::itcl::class LogRecord {

        public variable level
        public variable message
        public variable timestamp

        constructor args {
            eval [concat configure $args -timestamp [clock seconds]]
        }

        destructor {}

        public method toString
    }

    ::itcl::body LogRecord::toString {} {
        return [format "\[%s\]\[%5s\] %s" [clock format $timestamp -format "%y/%m/%d %H:%M:%S"] [::util::logging::Level::toString $level] $message]
    }
}
