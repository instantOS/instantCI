#!/usr/bin/expect

set timeout 20

spawn vercel . --prod

expect "and deploy"
sleep 1
send "Y\n"
# which scope?
expect "scope"
sleep 1
send "\n"

expect "existing"
sleep 1
send "y\n"

expect "name"
send "instantos\n"
interact