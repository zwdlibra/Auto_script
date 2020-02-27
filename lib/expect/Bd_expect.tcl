# Bd_expect.tcl --
#
# Copyright (c) 1994-2019 Shanghai Baud Data Communication Co., Ltd.

proc Bd_do_1cmd { id command } {
    expect_after -i $id timeout {
        exp_send_user [exp_timestamp -format "%c Bd_do_1cmd: recv timed out\n"]
        exp_send -i $id -s $::Bd_expect_settings(NUL)
        exp_continue
    }
    expect -i $id -re $::Bd_expect_settings(PROMPT,ENABLE_OR_CONFIG) {
        exp_send -i $id -s -- "$command\r"
        expect -i $id -timeout $::Bd_expect_settings(RECV_TIMEOUT) "\n"
    } timeout {}
    expect -i $id -re ".*(?=$::Bd_expect_settings(PROMPT,ENABLE_OR_CONFIG))" {
        append output [string trimright $expect_out(0,string) "\n"]
        return $output
    } -re $::Bd_expect_settings(PROMPT,LOGIN) {
        exp_send -i $id -s "enable\r"
        expect -i $id -timeout $::Bd_expect_settings(RECV_TIMEOUT) "\n"
        exp_continue
    } -re "(.+?) --More-- " {
        append output $expect_out(1,string)
        exp_send -i $id -s " "
        expect -i $id -timeout $::Bd_expect_settings(RECV_TIMEOUT) -re "\\b{9} {8}\\b{9}| {8}"
        exp_continue
    } -re "\\(y/n\\)\\??" {
        exp_send -i $id -s "y\r"
        expect -i $id -timeout $::Bd_expect_settings(RECV_TIMEOUT) "\n"
        exp_continue
    } full_buffer {
        append output $expect_out(buffer)
        exp_continue
    } timeout {
        exp_send_user [exp_timestamp -format "%c Bd_do_1cmd: command \"$command\" timed out after $::timeout second(s)\n"]
        exp_continue
    }
}

proc Bd_expect_login { ip port username password } {
    eval [concat exp_spawn [format $::Bd_expect_settings(TELNET_CLI) $ip $port]]
    expect -timeout 60 "Connection is established." {
        exp_send -s "\r"
        exp_continue
    } "Username: " {
        exp_send -s -- "$username\r"
        exp_continue
    } "Password: " {
        exp_send -s -- "$password\r"
        exp_continue
    } -- " --More-- " {
        exp_send -s "\033"
        exp_continue
    } -re $::Bd_expect_settings(PROMPT,CONFIG) {
        exp_send -s "exit\r"
        exp_continue
    } -re $::Bd_expect_settings(PROMPT,ENABLE) {
        exp_send -s "config\r"
    } -re $::Bd_expect_settings(PROMPT,LOGIN) {
        exp_send -s "enable\r"
        exp_continue
    } timeout {
        error "could not connect to '$ip' (port $port): Login timed out"
    } eof {
        error "could not connect to '$ip' (port $port): [string trimright $expect_out(buffer)]"
    }

    expect_after timeout {
        exp_send_user [exp_timestamp -format "%c Bd_expect_login: command timed out\n"]
        exp_send -s $::Bd_expect_settings(NUL)
        exp_continue
    }
    expect -re $::Bd_expect_settings(PROMPT,CONFIG) { exp_send -s "line console 0\r" }
    expect -re $::Bd_expect_settings(PROMPT,CONFIG) { exp_send -s "exec-timeout 0\r" }
    expect -re $::Bd_expect_settings(PROMPT,CONFIG) { exp_send -s "exit\r" }
    expect -re $::Bd_expect_settings(PROMPT,CONFIG) { exp_send -s "line vty 0 3\r" }
    expect -re $::Bd_expect_settings(PROMPT,CONFIG) { exp_send -s "exec-timeout 0\r" }
    expect -re $::Bd_expect_settings(PROMPT,CONFIG) { exp_send -s "exit\r" }
    expect -re $::Bd_expect_settings(PROMPT,CONFIG) { exp_send -s "exit\r" }
    expect -re $::Bd_expect_settings(PROMPT,ENABLE) { exp_send -s "terminal length 0\r" }
    expect -re $::Bd_expect_settings(PROMPT,ENABLE) { exp_send -s "no terminal monitor\r" }
    expect -re $::Bd_expect_settings(PROMPT,ENABLE) { exp_send -s "\r" }

    return $spawn_id
}

proc Bd_expect_logout { id } {
    expect_after -i $id timeout {
        exp_send_user [exp_timestamp -format "%c Bd_expect_logout: command timed out\n"]
        exp_send -i $id -s $::Bd_expect_settings(NUL)
        exp_continue
    }
    expect -i $id -re $::Bd_expect_settings(PROMPT,ENABLE) { exp_send -i $id -s "no terminal length\r" }
    expect -i $id -re $::Bd_expect_settings(PROMPT,ENABLE) { exp_send -i $id -s "terminal monitor\r" }
    expect -i $id -re $::Bd_expect_settings(PROMPT,ENABLE)
    exp_close -i $id
}
