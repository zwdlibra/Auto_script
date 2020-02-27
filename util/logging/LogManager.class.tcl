# LogManager.class.tcl --
#
# Copyright (c) 1994-2019 Shanghai Baud Data Communication Co., Ltd.

namespace eval util::logging {

    ::itcl::class LogManager {

        private common Logger

        public proc getLogger {} {
            if {![info exists Logger]} {
                if {[info exists ::LOG_PATH]} {
                    set logPath $::LOG_PATH
                } elseif {[info exists ::env(LOG_PATH)]} {
                    set logPath $::env(LOG_PATH)
                } else {
                    set logPath [file join $::WORKING_DIR "logs" [clock format [clock seconds] -format "Bd_Autotest_log_%m-%d-%Y-%I%p_%Mm%Ss.log"]]
                }

                if {[info exists ::LOG_LEVEL]} {
                    set logLevel $::LOG_LEVEL
                } elseif {[info exists ::env(LOG_LEVEL)]} {
                    set logLevel $::env(LOG_LEVEL)
                } else {
                    set logLevel "INFO"
                }

                namespace eval :: [concat set _Logger \[util::logging::Logger #auto [list $logPath [util::logging::Level::parse $logLevel]]\]]
                set Logger $::_Logger
                unset ::_Logger
            }
            return $Logger
        }
    }
}
