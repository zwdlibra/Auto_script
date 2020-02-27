# Bd_expect_settings.tcl --
#
# Copyright (c) 1994-2019 Shanghai Baud Data Communication Co., Ltd.

#  5.1 - Windows XP
#  6.1 - Windows 7
# 10.0 - Windows 10
switch -exact -- $tcl_platform(osVersion) {
    "5.1" -
    "6.1" {
        set Bd_expect_settings(TELNET_CLI) [list [file join $env(APP_PATH) "plink.exe"] -raw "%s" -P "%s"]
        set Bd_expect_settings(NUL) \000
    }
    "10.0" -
    default {
        set Bd_expect_settings(TELNET_CLI) [list [file join $env(APP_PATH) "telnet.exe"] "%s" "%s"]
        set Bd_expect_settings(NUL) \040
    }
}

array set Bd_expect_settings {
    PROMPT,CONFIG           {(?:Router|Switch)[^\s#]+#}
    PROMPT,ENABLE           {(?:Router|Switch)#}
    PROMPT,ENABLE_OR_CONFIG {(?:Router|Switch)[^\s#]*#}
    PROMPT,LOGIN            {(?:Router|Switch)>}
}

array set Bd_expect_settings {
    RECV_TIMEOUT 3
    TIMEOUT      15
}

# control output to screen
exp_log_user 0

# controls for send -s
set send_slow {40 .1}

# maximum time for expect to wait
set timeout $Bd_expect_settings(TIMEOUT)
