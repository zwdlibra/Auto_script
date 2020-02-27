# CommandSequencer.class.tcl --
#
# Copyright (c) 1994-2020 Shanghai Baud Data Communication Co., Ltd.

namespace eval Bd_tester::TestCenter {

    ::itcl::class CommandSequencer {

        private variable CallbackArr
        private variable Handle
        private variable Table

        constructor { sequencerHandle } {
            array set CallbackArr {}
            set Handle $sequencerHandle
            set Table [CommandTable #auto $sequencerHandle]
            Init
        }

        destructor {
            ::itcl::delete object $Table
        }

        private method _InvokeCallback
        public method bind
        private method Callback
        private method GetCommandByClassName
        private method GetCommandByName
        private method GetCommandByNameInternal
        public method getStatus
        public method getTestState
        private method Init
        public method run
        public method toString
    }

    ::itcl::body CommandSequencer::bind args {
        array set option $args

        if {[info exists option(-CommandName)]} {
            set commandHandleList [GetCommandByName $option(-CommandName)]
        } elseif {[info exists option(-CommandClassName)]} {
            set commandHandleList [GetCommandByClassName $option(-CommandClassName)]
        } else {
            set commandHandleList {}
        }

        foreach commandHandle $commandHandleList {
            if {[regexp {runcustomcommand\d+} $commandHandle]} {
                stc::config $commandHandle -ScriptFileName [file join $::env(APP_PATH) "scripts" "stc_script.tcl"]
            }

            set parentHandle [stc::get $commandHandle -Parent]
            if {\
                [regexp {sequencer(dowhile|elseif|if|while)command\d+} $parentHandle] &&\
                ([stc::get $parentHandle -ExpressionCommand] eq $commandHandle)\
            } {
                set CallbackArr($parentHandle) $option(-Callback)
            } else {
                set CallbackArr($commandHandle) $option(-Callback)
            }
        }
    }

    ::itcl::body CommandSequencer::Callback { commandHandle } {
        if {[info proc $CallbackArr($commandHandle)] ne ""} {
            set ret [eval [concat $CallbackArr($commandHandle) $commandHandle]]
        } else {
            eval [concat ::itcl::body CommandSequencer::_InvokeCallback $CallbackArr($commandHandle)]
            set ret [eval [concat _InvokeCallback $commandHandle]]
        }

        if {[regexp {sequencer(dowhile|elseif|if|while)command\d+} $commandHandle]} {
            set commandHandle [stc::get $commandHandle -ExpressionCommand]
        }
        if {[regexp {runcustomcommand\d+} $commandHandle]} {
            if {$ret eq ""} {
                set ret 1
            }
            stc::config $commandHandle -Parameters [list -Ret $ret]
        }
    }

    ::itcl::body CommandSequencer::GetCommandByClassName { className } {
        array set cmdResult [stc::perform GetObjects -ClassName $className -RootList $Handle]
        return $cmdResult(-ObjectList)
    }

    ::itcl::body CommandSequencer::GetCommandByName { name } {
        return [GetCommandByNameInternal $name $Handle]
    }

    ::itcl::body CommandSequencer::GetCommandByNameInternal { name parentHandle } {
        set ret {}
        if {[stc::get $parentHandle -Name] eq $name} {
            lappend ret $parentHandle
        }
        foreach childHandle [stc::get $parentHandle -Children] {
            eval [concat lappend ret [GetCommandByNameInternal $name $childHandle]]
        }

        return $ret
    }

    ::itcl::body CommandSequencer::getStatus {} {
        return [stc::get $Handle -Status]
    }

    ::itcl::body CommandSequencer::getTestState {} {
        return [stc::get $Handle -TestState]
    }

    ::itcl::body CommandSequencer::Init {} {
        stc::config $Handle -ErrorHandler "STOP_ON_ERROR"
    }

    ::itcl::body CommandSequencer::run {} {
        stc::perform SequencerRemoveBreakpoint
        stc::perform SequencerInsertBreakpoint -CommandList [array names CallbackArr]

        stc::apply

        stc::perform SequencerStart
        while {[set state [stc::waitUntilComplete]] ne "RUNNING"} {
            switch -exact -- $state {
                "PAUSE" {
                    if {[catch { Callback [stc::get $Handle -PausedCommand] }]} {
                        stc::perform SequencerStop -SequencerTestState "CHANGE_TO_FAILED" -StoppedReason $::errorInfo
                    } else {
                        stc::apply
                        stc::perform SequencerStart
                    }
                }
                "IDLE"  { break }
                default { stc::perform SequencerStart }
            }
        }
    }

    ::itcl::body CommandSequencer::toString {} {
        $Table update
        return [$Table toString]
    }
}
