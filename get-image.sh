#!/bin/bash

# This script expects the following to be installed:
# curl, libguestfs-tools-c

IMAGE=Fedora-x86_64-20-20140618-sda.qcow2
TARGET=fedora-20-k8s.qcow2

if ! [ -f "$IMAGE" ]; then
    echo "Downloading $IMAGE"
    curl -O http://archive.fedoraproject.org/pub/alt/openstack/20/x86_64/$IMAGE
fi

echo "Copying $IMAGE to $TARGET"
cp "$IMAGE" $TARGET

PACKAGES="jq,dnf,bridge-utils,docker-io,git\
,python-netifaces,python-requests,tcpdump,python-setuptools"

virt-customize \
    --add $TARGET \
    --install dnf,dnf-plugins-core \
    --run-command "dnf -y copr enable walters/atomic-next" \
    --run-command "dnf -y copr enable larsks/fakedocker" \
    --update \
    --install $PACKAGES \
    --install kubernetes \
    --run-command "yum clean all" \
    --root-password password:password

# SELinux relabeling requires virt-customize to have networking disabled
# https://bugzilla.redhat.com/show_bug.cgi?id=1122907
virt-customize --add $IMAGE --selinux-relabel --no-network
