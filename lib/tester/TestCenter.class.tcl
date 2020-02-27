# TestCenter.class.tcl --
#
# Copyright (c) 1994-2020 Shanghai Baud Data Communication Co., Ltd.

namespace eval Bd_tester {

    ::itcl::class TestCenter {

        private common Sequencer

        public proc cleanup {} {
            if {[info exists Sequencer]} {
                ::itcl::delete object $Sequencer
                unset Sequencer
            }
            stc::perform ChassisDisconnectAll
            stc::perform ResetConfig
        }

        public proc getSequencer {} {
            if {[stc::get project1 -ConfigurationFileName] eq "Untitled.tcc"} {
                error "configuration has not been loaded yet, please load it first"
            }
            if {![info exists Sequencer]} {
                namespace eval :: [concat set _Sequencer \[Bd_tester::TestCenter::CommandSequencer #auto [list [stc::get system1 -Children-Sequencer]]\]]
                set Sequencer $::_Sequencer
                unset ::_Sequencer

                $Sequencer bind -CommandClassName "SequencerComment" -Callback { handle {
                    $::logger info [stc::get $handle -Text]
                }}

                $Sequencer bind -CommandClassName "CaptureDataSaveCommand" -Callback { handle {
                    stc::config $handle -FileNamePath [file join $::WORKING_DIR "captures"]
                }}
            }
            return $Sequencer
        }

        public proc loadConfig { { fileName "" } } {
            if {[stc::get project1 -ConfigurationFileName] ne "Untitled.tcc"} {
                error "configuration has already been loaded, please clean it up first"
            }
            if {$fileName eq ""} {
                regsub {\.cfg$} $::global_config_files(TESTCASE,$::global_current_module_name,$::global_current_tc_name) ".xml" fileName
            }

            stc::config AutomationOptions\
                -LogTo [file join $::WORKING_DIR "logs" "TestCenter" "${::global_current_project_name}_${::global_current_module_name}_${::global_current_tc_name}.log"]\
                -LogLevel "INFO"

            stc::perform LoadFromXml -FileName [file normalize [file join $::MODULE_DIR($::global_current_module_name) $fileName]]

            stc::config project1.TestResultSetting\
                -SaveResultsRelativeTo "NONE"\
                -ResultsDirectory [file join $::WORKING_DIR "results"]

            set portHandleList [stc::get project1 -Children-Port]
            foreach portHandle $portHandleList {
                stc::config $portHandle -AppendLocationToPortName FALSE
                regsub { \(offline\)} [stc::get $portHandle -Name] "" portName
                if {[info exists ::Bd_topo::intf($portName)]} {
                    stc::config $portHandle -Location $::Bd_topo::intf($portName)
                    set ::Bd_topo::cfg_handle($portName) $portHandle
                }
            }

            stc::perform AttachPorts -AutoConnect TRUE -PortList $portHandleList
            stc::apply

            stc::subscribe -Parent project1\
                -ResultParent project1\
                -ConfigType Generator\
                -ResultType GeneratorPortResults\
                -FilterList ""\
                -ViewAttributeList "totalframecount totaloctetcount generatorframecount generatoroctetcount generatorsigframecount generatorundersizeframecount generatoroversizeframecount generatorjumboframecount totalframerate totaloctetrate generatorframerate generatoroctetrate generatorsigframerate generatorundersizeframerate generatoroversizeframerate generatorjumboframerate generatorcrcerrorframecount generatorl3checksumerrorcount generatorl4checksumerrorcount generatorcrcerrorframerate generatorl3checksumerrorrate generatorl4checksumerrorrate totalipv4framecount totalipv6framecount totalmplsframecount generatoripv4framecount generatoripv6framecount generatorvlanframecount generatormplsframecount totalipv4framerate totalipv6framerate totalmplsframerate generatoripv4framerate generatoripv6framerate generatorvlanframerate generatormplsframerate totalbitrate generatorbitrate l1bitcount l1bitrate pfcframecount pfcpri0framecount pfcpri1framecount pfcpri2framecount pfcpri3framecount pfcpri4framecount pfcpri5framecount pfcpri6framecount pfcpri7framecount l1bitratepercent"\
                -Interval 1

            stc::subscribe -Parent project1\
                -ResultParent project1\
                -ConfigType Analyzer\
                -ResultType AnalyzerPortResults\
                -FilterList ""\
                -ViewAttributeList "totalframecount totaloctetcount sigframecount undersizeframecount oversizeframecount jumboframecount minframelength maxframelength pauseframecount totalframerate totaloctetrate sigframerate undersizeframerate oversizeframerate jumboframerate pauseframerate fcserrorframecount ipv4checksumerrorcount tcpchecksumerrorcount udpchecksumerrorcount prbsfilloctetcount prbsbiterrorcount fcserrorframerate ipv4checksumerrorrate tcpchecksumerrorrate udpchecksumerrorrate prbsfilloctetrate prbsbiterrorrate ipv4framecount ipv6framecount ipv6overipv4framecount tcpframecount udpframecount mplsframecount icmpframecount vlanframecount ipv4framerate ipv6framerate ipv6overipv4framerate tcpframerate udpframerate mplsframerate icmpframerate vlanframerate trigger1count trigger1rate trigger2count trigger2rate trigger3count trigger3rate trigger4count trigger4rate trigger5count trigger5rate trigger6count trigger6rate trigger7count trigger7rate trigger8count trigger8rate combotriggercount combotriggerrate totalbitrate prbsbiterrorratio vlanframerate l1bitcount l1bitrate pfcframecount fcoeframecount pfcframerate fcoeframerate pfcpri0framecount pfcpri1framecount pfcpri2framecount pfcpri3framecount pfcpri4framecount pfcpri5framecount pfcpri6framecount pfcpri7framecount pfcpri0quanta pfcpri1quanta pfcpri2quanta pfcpri3quanta pfcpri4quanta pfcpri5quanta pfcpri6quanta pfcpri7quanta prbserrorframecount prbserrorframerate userdefinedframecount1 userdefinedframerate1 userdefinedframecount2 userdefinedframerate2 userdefinedframecount3 userdefinedframerate3 userdefinedframecount4 userdefinedframerate4 userdefinedframecount5 userdefinedframerate5 userdefinedframecount6 userdefinedframerate6 l1bitratepercent outseqframecount"\
                -Interval 1

            stc::subscribe -Parent project1\
                -ResultParent project1\
                -ConfigType StreamBlock\
                -ResultType RxStreamSummaryResults\
                -FilterList ""\
                -ViewAttributeList "framecount sigframecount fcserrorframecount minlatency maxlatency droppedframecount droppedframepercent inorderframecount reorderedframecount duplicateframecount lateframecount prbsbiterrorcount prbsfilloctetcount ipv4checksumerrorcount tcpudpchecksumerrorcount framerate sigframerate fcserrorframerate droppedframerate droppedframepercentrate inorderframerate reorderedframerate duplicateframerate lateframerate prbsbiterrorrate prbsfilloctetrate ipv4checksumerrorrate tcpudpchecksumerrorrate bitrate shorttermavglatency avglatency prbsbiterrorratio l1bitcount l1bitrate prbserrorframecount prbserrorframerate aggregatedrxportcount portstrayframes bitcount shorttermavgjitter avgjitter minjitter maxjitter shorttermavginterarrivaltime avginterarrivaltime mininterarrivaltime maxinterarrivaltime inseqframecount outseqframecount inseqframerate outseqframerate histbin1count histbin2count histbin3count histbin4count histbin5count histbin6count histbin7count histbin8count histbin9count histbin10count histbin11count histbin12count histbin13count histbin14count histbin15count histbin16count"\
                -Interval 1

            stc::subscribe -Parent project1\
                -ResultParent project1\
                -ConfigType StreamBlock\
                -ResultType TxStreamResults\
                -FilterList ""\
                -ViewAttributeList "framecount framerate bitrate expectedrxframecount l1bitcount l1bitrate streaminfo bitcount"\
                -Interval 1

            foreach portHandle $portHandleList {
                stc::subscribe -Parent project1\
                    -ResultParent $portHandle\
                    -ConfigType Analyzer\
                    -ResultType FilteredStreamResults\
                    -FilterList ""\
                    -ViewAttributeList "streamindex framecount sigframecount fcserrorframecount minlatency maxlatency seqrunlength droppedframecount droppedframepercent inorderframecount reorderedframecount duplicateframecount lateframecount prbsbiterrorcount prbsfilloctetcount ipv4checksumerrorcount tcpudpchecksumerrorcount framerate sigframerate fcserrorframerate droppedframerate droppedframepercentrate inorderframerate reorderedframerate duplicateframerate lateframerate prbsbiterrorrate ipv4checksumerrorrate tcpudpchecksumerrorrate filteredvalue_1 filteredvalue_2 filteredvalue_3 filteredvalue_4 filteredvalue_5 filteredvalue_6 filteredvalue_7 filteredvalue_8 filteredvalue_9 filteredvalue_10 bitrate shorttermavglatency avglatency prbsbiterrorratio bitcount l1bitcount l1bitrate prbserrorframecount prbserrorframerate shorttermavgjitter avgjitter minjitter maxjitter shorttermavginterarrivaltime avginterarrivaltime mininterarrivaltime maxinterarrivaltime lastseqnum inseqframecount outseqframecount inseqframerate outseqframerate histbin1count histbin2count histbin3count histbin4count histbin5count histbin6count histbin7count histbin8count histbin9count histbin10count histbin11count histbin12count histbin13count histbin14count histbin15count histbin16count"\
                    -Interval 1
            }
        }
    }
}
