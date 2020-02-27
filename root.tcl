# root.tcl --
#
# Copyright (c) 1994-2020 Shanghai Baud Data Communication Co., Ltd.
package require Bdcom_autotest_bdproject
package require Bdcom_autotest_tester

variable MODULE_DIR
variable PROJECT_DIR
variable TOPOLOGY_DIR
variable WORKING_DIR [pwd]

array set opt [list --entry_script "" --ignore_list {} --order "IN_ORDER" --module "" --project "" --testcase ""]
array set opt $argv

foreach { name value } [array get opt] {
    switch -exact -- $name {
        --entry_script {
            if {$value eq ""} {
                error "option \"--entry_script\" is required"
            }
        }
        --ignore_list {
            if {[file isfile $value]} {
                set opt($name) [split [file cat $value] "\n"]
            }
        }
        --order {
            set value [string toupper $value]
            switch -exact -- $value {
                "IN_ORDER"      -
                "REVERSE_ORDER" -
                "OUT_OF_ORDER"  -
                "RANDOM"        { set opt($name) $value }
                default         { error "invalid value for option \"--order\": must be IN_ORDER, REVERSE_ORDER, OUT_OF_ORDER, or RANDOM" }
            }
        }
    }
}

source $opt(--entry_script)
if {$opt(--order) eq "RANDOM"} {
    package require Bdcom_autotest_bdproject_ext
}

cd $WORKING_DIR
file mkdir "captures"
file mkdir "logs"
file mkdir "logs/TestCenter"
file mkdir "results"

set configParser [util::ConfigParser #auto]
set logger       [util::logging::LogManager::getLogger]

TestProjects_root

exit 0
