#!/usr/bin/expect -f
lassign $argv IPSrv Login Passwd

set timeout 10

spawn ssh-copy-id -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=1s $Login@$IPSrv

expect {
    -re ".*assword:.*" {
        send "$Passwd\r"
        exp_continue
    }

    -re ".*ERROR:.*" {
        exit 4
    }

    eof {}
}
