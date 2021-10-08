#!/bin/bash

set -o errexit

TEMP_PATH_FLDR="/execs"
OP=$(echo $@ | cut -d " " -f7)
ID=$(echo $@ | rev | cut -d " " -f1 | rev)

if [ "$OP" = "create" ]
then
    echo "host $ID rwaxtl" > /sys/fs/smackfs/load2
    echo "_ $ID rwaxtl" > /sys/fs/smackfs/load2
    find /run/containerd/io.containerd.runtime.v2.task/k8s.io/$ID/rootfs/* -type f -exec chsmack -L -a $ID -e $ID -m $ID {} +
    find /run/containerd/io.containerd.runtime.v2.task/k8s.io/$ID/rootfs/* -type l -exec xattr -w -s security.SMACK64 $ID {} +
    find /run/containerd/io.containerd.runtime.v2.task/k8s.io/$ID/rootfs/* -type l -exec xattr -w -s security.SMACK64EXEC $ID {} +
    find /run/containerd/io.containerd.runtime.v2.task/k8s.io/$ID/rootfs -type d -exec chsmack -L -a $ID -t {} +
    TEMP_PATH="$TEMP_PATH_FLDR/$ID"
    mkdir -p $TEMP_PATH
    cp /usr/sbin/runc_exec $TEMP_PATH
    chsmack -a $ID -e $ID $TEMP_PATH/runc_exec
    chmod a+x $TEMP_PATH/runc_exec
    echo $ID > /proc/self/attr/current
    exec $TEMP_PATH/runc_exec $@
elif [ "$OP" = "delete" ]
then
    rm -Rf "$TEMP_PATH_FLDR/$ID"
else
    exec runc_exec $@
fi