# Bd_expect_checkpoint.tcl --
#
# Copyright (c) 1994-2019 Shanghai Baud Data Communication Co., Ltd.

proc BD_checkpoint args {
    array set option [list -dut "" -name "" -retry_times 1 -retry_interval 10 -enter_config_mode 1]
    array set option $args

    $::logger info "BD_checkpoint: $args"

    set id $::Bd_topo::cfg_handle($option(-dut))
    set commandList $::global_tc_checkpoint_cmd_array($option(-name))
    if {\
        [info exists ::global_tc_checkpoint_expected_array($option(-name))] &&\
        ([llength $::global_tc_checkpoint_expected_array($option(-name))] > 0)\
    } {
        set patternList $::global_tc_checkpoint_expected_array($option(-name))
    }
    set retryTimes $option(-retry_times)
    set retryInterval $option(-retry_interval)
    set enterConfigMode $option(-enter_config_mode)

    BD_checkpoint_docmds $id $commandList $enterConfigMode
    if {![info exists patternList]} {
        return 0
    }
    for {\
        set i 0;\
        set ret [BD_checkpoint_expect $patternList]\
    } {\
        ($i < [expr $retryTimes-1]) && !$ret\
    } {\
        incr i;\
        set ret [BD_checkpoint_expect $patternList]\
    } {
        sleep $retryInterval
        BD_checkpoint_docmds $id $commandList $enterConfigMode
    }

    return $ret
}

proc BD_checkpoint_docmds { id commandList enterConfigMode } {
    set ::global_bd_checkpoint_cmd_output {}

    if {$enterConfigMode} {
        set commandList [linsert $commandList 0 "config"]
        set commandList [linsert $commandList end "exit"]
    }
    foreach command $commandList {
        set commandOutput [Bd_do_1cmd $id $command]
        if {$commandOutput eq ""} {
            $::logger info "\[cmd\] $command"
        } elseif {([string first "^" $commandOutput] != -1) || ($commandOutput eq "Incomplete command")} {
            $::logger error "\[cmd\] $command\n$commandOutput"
        } else {
            $::logger info "\[cmd\] $command\n\n$commandOutput\n"
            eval [concat lappend ::global_bd_checkpoint_cmd_output [split $commandOutput "\n"]]
        }
    }
}

proc BD_checkpoint_expect { patternList } {
    array unset ::global_bd_checkpoint_matched

    set ret 1
    foreach pattern $patternList {
        set ::global_bd_checkpoint_matched($pattern) {}
        foreach line $::global_bd_checkpoint_cmd_output {
            if {[regexp -nocase $pattern $line]} {
                lappend ::global_bd_checkpoint_matched($pattern) $line
            }
        }
        if {[llength $::global_bd_checkpoint_matched($pattern)] == 0} {
            set ret 0
        }
        $::logger info "\[exp: [expr [llength $::global_bd_checkpoint_matched($pattern)] > 0]\]\
                        PATTERN = $pattern,\
                        MATCHED = $::global_bd_checkpoint_matched($pattern)"
    }

    return $ret
}
