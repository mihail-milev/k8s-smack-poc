# Enable SMACK support in Kubernetes

This repository contains the code of my proof of concept for enabling SMACK support in Kubernetes. For more information, please read [my post on Medium](https://mihail-milev.medium.com/using-smack-to-secure-k8s-containers-and-nodes-a-proof-of-concept-6f6cf8550c1f).

# Contents

The repository contains the patches needed for runc and containerd, which essentially enable Kubernetes to confine containers inside their own SMACK jails. Furthermore supplied are some additional scripts for preparing the environment.

- the folder containerd contains the patch for containerd;
- the folder runc contains the patch for runc;
- the folder system contains a oneshot service for systemd, which executes some preparations during boot. It also contains the preparation script itself and the configuration of containerd. All files are placed in their corresponding paths.

# License

The source code here is licensed under the MIT license. For more information see LICENSE.md.
