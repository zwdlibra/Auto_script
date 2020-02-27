# Logger.class.tcl --
#
# Copyright (c) 1994-2019 Shanghai Baud Data Communication Co., Ltd.

namespace eval util::logging {

    ::itcl::class Logger {

        private variable FileHandle
        private variable Level

        constructor { fileName level } {
            set FileHandle [open $fileName "a"]
            set Level $level
        }

        destructor {
            catch {
                flush $FileHandle
                close $FileHandle
            }
        }

        public method debug
        public method error
        public method info
        public method warn
        private method Write
    }

    ::itcl::body Logger::debug { message } {
        Write [::itcl::local ::util::logging::LogRecord #auto -level $::util::logging::Level::DEBUG -message $message]
    }

    ::itcl::body Logger::error { message } {
        Write [::itcl::local ::util::logging::LogRecord #auto -level $::util::logging::Level::ERROR -message $message]
    }

    ::itcl::body Logger::info { message } {
        Write [::itcl::local ::util::logging::LogRecord #auto -level $::util::logging::Level::INFO -message $message]
    }

    ::itcl::body Logger::warn { message } {
        Write [::itcl::local ::util::logging::LogRecord #auto -level $::util::logging::Level::WARN -message $message]
    }

    ::itcl::body Logger::Write { record } {
        if {\
            ([$record cget -level] < $Level) ||\
            [string is space [$record cget -message]]\
        } {
            return
        }
        print $FileHandle [$record toString]
        print stdout [$record toString]
    }
}