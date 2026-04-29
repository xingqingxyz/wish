#!/bin/sh
[ -p /tmp/handy.fifo ] || mkfifo /tmp/handy.fifo
echo -n "$1" | tee /tmp/handy.fifo > /dev/null
