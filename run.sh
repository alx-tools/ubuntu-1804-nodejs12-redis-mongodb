#!/bin/bash

rm -rf /tmp/run.sh;
rm -rf /root/.bash_history;

while true
do
  /usr/sbin/sshd -D
done
