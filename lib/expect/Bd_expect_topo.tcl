# Bd_expect_topo.tcl --
#
# Copyright (c) 1994-2019 Shanghai Baud Data Communication Co., Ltd.

proc Bd_expect_get_basemac { id type } {
    switch -exact -- [string totitle $type] {
        "Switch" {
            expect -i $id -re $::Bd_expect_settings(PROMPT,ENABLE) { exp_send -i $id -s "show version\r" }
            expect -i $id -re "Base ethernet MAC Address: (.+?)(?=\\n)" {
                set ret [formatMacAddr $expect_out(1,string)]
                exp_continue
            } -re $::Bd_expect_settings(PROMPT,ENABLE) {
                exp_send -i $id -s "\r"
            } timeout {
                exp_send_user [exp_timestamp -format "%c Bd_expect_get_basemac: command timed out\n"]
                exp_send -i $id -s $::Bd_expect_settings(NUL)
                exp_continue
            }
            return $ret
        }
        "Router" -
        default { return "" }
    }
}

proc Bd_expect_get_intf_mac { id interfaceName } {
    expect -i $id -re $::Bd_expect_settings(PROMPT,ENABLE) { exp_send -i $id -s "show controller interface $interfaceName\r" }
    expect -i $id -re "MAC=(.+?)(?=\\n)" {
        set ret [formatMacAddr $expect_out(1,string)]
        exp_continue
    } -re $::Bd_expect_settings(PROMPT,ENABLE) {
        exp_send -i $id -s "\r"
    } timeout {
        exp_send_user [exp_timestamp -format "%c Bd_expect_get_intf_mac: command timed out\n"]
        exp_send -i $id -s $::Bd_expect_settings(NUL)
        exp_continue
    }
    return $ret
}
