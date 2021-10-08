# Enable Smack support in Kubernetes

This repository contains the code of my proof of concept for enabling Smack support in Kubernetes. For more information, please read [my post on Medium](https://mihail-milev.medium.com/using-smack-to-secure-k8s-containers-and-nodes-a-proof-of-concept-6f6cf8550c1f).

# Update 8. October 2021

There are two new "wrapper" scripts under system/usr/bin. These allow using Smack without recompiling containerd and runc. The runc executable must be moved to "runc_exec" in the same where it was before. Afterwards in the same folder one of the wrapper scripts has to be placed and renamed to "runc". Which of the wrapper scripts to use depends on your configuration - if you use docker for your Kubernetes configuration, then use the docker wrapper script. If you use only containerd directly after Kubernetes, then use the containerd wrapper.

Here is an example how to activate Smack and containerd/runc with a wrapper script on a Ubuntu Server 21.04:

```bash
systemctl stop apparmor
systemctl disable apparmor
apt remove --assume-yes --purge apparmor
sed -ie 's/^GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 lsm=lockdown,yama,smack"/g' /etc/default/grub
echo "smackfs   /sys/fs/smackfs smackfs defaults        0       0" >> /etc/fstab
update-grub
reboot
```

After the machine has started up again, install needed software ...

```bash
apt-get install containerd runc xattr jq git automake libtool linux-headers-$(uname -r) make
apt-mark hold runc
```

Then compile the Smack tools

```bash
git clone https://github.com/smack-team/smack.git
cd smack
libtoolize 
aclocal
autoheader 
autoconf 
automake
./configure
make
find ./utils -maxdepth 1 -perm /0111 -exec cp -R {} /usr/bin {} \;
cd ..
```

Then deploy the Smack wrappers for containerd/runc ...

```bash
curl -LO https://raw.githubusercontent.com/mihail-milev/k8s-smack-poc/master/system/usr/bin/runc-wrapper-containerd.sh
curl -LO https://raw.githubusercontent.com/mihail-milev/k8s-smack-poc/master/system/etc/systemd/system/prepare-smack.service
curl -LO https://raw.githubusercontent.com/mihail-milev/k8s-smack-poc/master/system/usr/bin/prepare-smack.sh
mv prepare-smack.sh /usr/bin
chmod a+x /usr/bin/prepare-smack.sh
mv prepare-smack.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable prepare-smack
export RUNC_DEF_PATH=$(which runc)
mv $RUNC_DEF_PATH ${RUNC_DEF_PATH}_exec
mv runc-wrapper-containerd.sh $RUNC_DEF_PATH
chmod a+x $RUNC_DEF_PATH
systemctl enable containerd
reboot
```

Now the containerd system will use Smack for containers. On top of it, you have to install Kubernetes.

# Contents

The repository contains the patches needed for runc and containerd, which essentially enable Kubernetes to confine containers inside their own Smack jails. Furthermore supplied are some additional scripts for preparing the environment.

- the folder containerd contains the patch for containerd;
- the folder runc contains the patch for runc;
- the folder system contains a oneshot service for systemd, which executes some preparations during boot. It also contains the preparation script itself and the configuration of containerd. All files are placed in their corresponding paths.

# License

The source code here is licensed under the MIT license. For more information see LICENSE.md.
