#!/bin/bash

set -o errexit

OP=$(echo $@ | cut -d " " -f7)
ID=$(echo $@ | rev | cut -d " " -f1 | rev)

if [ "$OP" = "start" ]
then
    echo "host $ID rwaxtl" > /sys/fs/smackfs/load2
    echo "_ $ID rwaxtl" > /sys/fs/smackfs/load2
    FILEPATH=$(cat /run/containerd/io.containerd.runtime.v2.task/moby/$ID/config.json | jq -r ".root.path")
    find $FILEPATH/* -type f -exec chsmack -L -a $ID -e $ID {} +
    find $FILEPATH -type d -exec chsmack -L -a $ID -t {} +
    find $FILEPATH/../diff/* -type f -exec chsmack -L -a $ID -e $ID {} +
    find $FILEPATH/../diff -type d -exec chsmack -L -a $ID -t {} +
    find $FILEPATH/../ -type l -exec xattr -w -s security.SMACK64 $ID {} +
    find $FILEPATH/../ -type l -exec xattr -w -s security.SMACK64EXEC $ID {} +
    (echo $ID > /proc/self/attr/current ; exec runc_exec $@)
else
    exec runc_exec $@
fi