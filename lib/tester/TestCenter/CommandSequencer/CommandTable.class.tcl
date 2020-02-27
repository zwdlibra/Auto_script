# CommandTable.class.tcl --
#
# Copyright (c) 1994-2020 Shanghai Baud Data Communication Co., Ltd.

namespace eval Bd_tester::TestCenter::CommandSequencer {

    ::itcl::class CommandTable {

        private variable InnerMatrix

        constructor { sequencerHandle } {
            set InnerMatrix [::struct::matrix]
            $InnerMatrix add columns 6
            $InnerMatrix add row { "Command Handle" "" "Command Name" "P/F" "Start Time" "Elapsed Time" }
            Init $sequencerHandle 0
        }

        destructor {
            $InnerMatrix destroy
        }

        private method Init
        public method toString
        public method update
    }

    ::itcl::body CommandTable::Init { parentHandle level } {
        foreach commandHandle [stc::get $parentHandle -CommandList] {
            array set cmdResult [list -PassFailState ""]
            array set cmdResult [stc::get $commandHandle]

            set state [format " \[%9s\]" $cmdResult(-State)]
            set commandName [string repeat " " [expr 4 * $level]]
            switch -regexp -- $commandHandle {
                {sequencercomment\d+} {
                    append commandName [format "# %s" $cmdResult(-Text)]
                }
                {sequencer(dowhile|elseif|if|while)command\d+} {
                    append commandName [format "%s (%s == %s)" $cmdResult(-Name) [stc::get $cmdResult(-ExpressionCommand) -Name] [string totitle $cmdResult(-Condition)]]
                }
                {sequencerstopcommand\d+} {
                    append commandName [format "%s (%s)" $cmdResult(-Name) [string map { "CHANGE_TO_FAILED" "Failed" "CHANGE_TO_PASSED" "Passed" "NO_CHANGE" "No Change" } $cmdResult(-SequencerTestState)]]
                }
                default {
                    append commandName $cmdResult(-Name)
                }
            }
            set passFailState $cmdResult(-PassFailState)

            $InnerMatrix add row [list $commandHandle $state $commandName $passFailState "" ""]

            if {[regexp {sequencer(dowhile|elseif|group|if|loop|while)command\d+} $commandHandle]} {
                Init $commandHandle [expr $level + 1]
            }
        }
    }

    ::itcl::body CommandTable::toString {} {
        set formatStr ""
        set tableWidth 0
        for {set c 1} {$c <= 5} {incr c} {
            set columnWidth [expr $c==1?[$InnerMatrix columnwidth $c]+1:[$InnerMatrix columnwidth $c]+4]
            append formatStr "%-${columnWidth}s"
            incr tableWidth $columnWidth
        }

        set str ""
        append str [string repeat "=" $tableWidth]
        append str "\n"
        for {set r 0} {$r < [$InnerMatrix rows]} {incr r} {
            append str [eval [concat format $formatStr [lrange [$InnerMatrix get row $r] 1 5]]]
            append str "\n"
            if {$r == 0} {
                append str [string repeat "-" $tableWidth]
                append str "\n"
            }
        }
        append str [string repeat "=" $tableWidth]

        return $str
    }

    ::itcl::body CommandTable::update {} {
        for {set r 1} {$r < [$InnerMatrix rows]} {incr r} {
            set commandHandle [$InnerMatrix get cell 0 $r]
            array set cmdResult [list -PassFailState ""]
            array set cmdResult [stc::get $commandHandle]

            set state [format " \[%9s\]" $cmdResult(-State)]
            set passFailState $cmdResult(-PassFailState)
            set startTime [expr $cmdResult(-StartTime)>0?"[clock format [expr int($cmdResult(-StartTime))] -format "%x %X"]":""]
            set elapsedTime [expr $cmdResult(-ElapsedTime)>0?"[timespan [expr int($cmdResult(-ElapsedTime))]]":""]

            $InnerMatrix set cell 1 $r $state
            $InnerMatrix set cell 3 $r $passFailState
            $InnerMatrix set cell 4 $r $startTime
            $InnerMatrix set cell 5 $r $elapsedTime
        }
    }
}
