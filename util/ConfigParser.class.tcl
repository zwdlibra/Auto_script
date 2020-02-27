# ConfigParser.class.tcl --
#
# Copyright (c) 1994-2019 Shanghai Baud Data Communication Co., Ltd.

namespace eval util {

    ::itcl::class ConfigParser {

        private common CONFIG_SECTION_PATTERN {(?m)^%start_(\w+)(?:[ \t]+(\S+))?(?:[ \t]+(\S+))?(\n(?:(?!^%start_).*\n)*)^%end_\1$}

        private variable ConfigSections

        constructor {} {
            array set ConfigSections {}
        }

        destructor {}

        public method load
        public method parse
        public method parseAll

        private proc Escape { string } {
            return [string map { "," "&comma;" } $string]
        }

        private proc Unescape { string } {
            return [string map { "&comma;" "," } $string]
        }
    }

    ::itcl::body ConfigParser::load { fileName } {
        if {[array size ConfigSections] > 0} {
            array unset ConfigSections
            array set ConfigSections {}
        }

        set contents [file cat $fileName]
        regsub -all {(?m)(?=#).+} $contents "" contents
        regsub -all {(?m)^[ \t]+|[ \t]+$} $contents "" contents
        regsub -all {\n+} $contents "\n" contents

        set matches [regexp -all -inline $CONFIG_SECTION_PATTERN $contents]
        foreach { match key keyValue keyValue2 value } $matches {
            set ConfigSections($key,[Escape $keyValue],[Escape $keyValue2]) [split [string trim $value] "\n"]
        }

        return [array size ConfigSections]
    }

    ::itcl::body ConfigParser::parse { key { keyValue "" } { keyValue2 "" } } {
        set escapedKeyValue [Escape $keyValue]
        set escapedKeyValue2 [Escape $keyValue2]
        if {![info exists ConfigSections($key,$escapedKeyValue,$escapedKeyValue2)]} {
            return {}
        }
        return $ConfigSections($key,$escapedKeyValue,$escapedKeyValue2)
    }

    ::itcl::body ConfigParser::parseAll { key { keyValue "" } } {
        set ret {}
        if {$keyValue eq ""} {
            foreach { name value } [array get ConfigSections "$key,?*,"] {
                lappend ret [Unescape [lindex [split $name ","] 1]] $value
            }
        } else {
            foreach { name value } [array get ConfigSections "$key,[Escape $keyValue],?*"] {
                lappend ret [Unescape [lindex [split $name ","] 2]] $value
            }
        }

        return $ret
    }
}
