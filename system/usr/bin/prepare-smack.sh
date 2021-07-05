#!/bin/bash

export PATH=$PATH:/home/scientist/Work/smack/utils/

iptables -t mangle -A INPUT -j SECMARK --selctx _
iptables -t mangle -A OUTPUT -j SECMARK --selctx _

find / -type f -exec chsmack -AME {} +
find / -type d -exec chsmack -AMTE {} +

find / -type f -not -regex "^/etc/kubernetes.*" \
  -not -regex "^/usr/libexec/kubernetes/kubelet-plugins/volume/exec.*" \
  -not -regex "^/usr/share/ca-certificates.*" \
  -not -regex "^/var/lib/containerd/io.containerd.grpc.v1.cri.*" \
  -not -regex "^/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs.*" \
  -not -regex "^/var/lib/kubelet/pods.*" \
  -not -regex "^/var/lib/etcd.*" \
  -not -regex "^/etc/cni/net.d.*" \
  -not -regex "^/etc/openvswitch.*" \
  -not -regex "^/opt/cni/bin.*" \
  -not -regex "^/run/openvswitch.*" \
  -not -regex "^/var/log/openvswitch.*" \
  -not -regex "^/dev.*" \
  -not -regex "^/proc.*" \
  -not -regex "^/run.*" \
  -not -regex "^/sys.*" \
  -exec chsmack -a host {} +
find / -type d -not -regex "^/etc/kubernetes.*" \
  -not -regex "^/usr/libexec/kubernetes/kubelet-plugins/volume/exec.*" \
  -not -regex "^/usr/share/ca-certificates.*" \
  -not -regex "^/var/lib/containerd/io.containerd.grpc.v1.cri.*" \
  -not -regex "^/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs.*" \
  -not -regex "^/var/lib/kubelet/pods.*" \
  -not -regex "^/var/lib/etcd.*" \
  -not -regex "^/etc/cni/net.d.*" \
  -not -regex "^/etc/openvswitch.*" \
  -not -regex "^/opt/cni/bin.*" \
  -not -regex "^/run/openvswitch.*" \
  -not -regex "^/var/log/openvswitch.*" \
  -not -regex "^/dev.*" \
  -not -regex "^/proc.*" \
  -not -regex "^/run.*" \
  -not -regex "^/sys.*" \
  -exec chsmack -a host -t {} +

chsmack -a host /dev 
chsmack -a host /proc
chsmack -a host /run
chsmack -a host /sys 

