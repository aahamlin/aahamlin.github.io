---
layout: post
title: Setting up qemu/kvm on Gentoo with systemd
categories: [gentoo]
tags: [gentoo, linux]
---

Recently, I reinstalled my [Gentoo Linux](https://www.gentoo.org) system from scratch; rebuilding it from the ground up. The reason for embarking on this is a bigger life story, but the short version is that this computer is my music production workstation \(which makes it seem waaaay more serious and professional than it is\) and due to moving between CT and TX and CT again over the past few years, the computer had been in a box for nearly 3 years. Upgrading a system 3 years out-of-date, that has already grown and expanded haphazardly since 2010-ish, was a huge time sink I decided to avoid.

Now this computer has two purposes, the primary being for digital audio recording and mastering. A passion I have had since I was 8 or 9 years old. My first career, though short-lived, was as an audio engineer, producer and studio owner. Though I have been a software developer since my late twenties, I thoroughly enjoy having a home studio. The secondary purpose is for experimenting with new languages and tools. Having just rebuilt this machine, I haven't yet installed a hypervisor and this week I am going to be researching [Open Source Mano \(OSM\)](https://osm.etsi.org/) and [Charmed OSM](https://charmed-osm.com/), in order to do that I will be following the [Getting started with Charmed OSM](https://jaas.ai/tutorials/charmed-osm-get-started#1-introduction) tutorial from [Canonical](https://canonical.com/). But, first, I am installing QEMU and KVM onto my Gentoo box.

The [Gentoo Wiki](https://wiki.gentoo.org) article on [QEMU](https://wiki.gentoo.org/wiki/QEMU) covers the basics, starting with compiling support for KVM into the kernel. 

## Disk partitioning, kernel config, and bootloader

Speaking of configuring the kernel, I want to also write a post documenting my audio setup and add a copy of the kernel config for my machine here as well. Then, a future rebuild could be accomplished with a simple `make oldconfig`.

That reminds me that another huge surprise for me while rebuilding this machine was that the hardware \(being 10 years old\) was not compatible with the latest and greatest guides for partitioning the disks. Initially, I followed the [article](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Disks) from the [Gentoo AMD64 Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64) and used a GUID Partition Table \(GPT\) and could not get grub2 to boot the system at all. This was terrible, as the only resort was to wipe the disks and repartion them using the old MBR format and reinstall the whole OS, again.  Talk about dusting off the cobwebs in my head. :/

## Emerge QEMU and dependencies

Following the [QEMU](https://wiki.gentoo.org/wiki/QEMU) article, and rebooting into the KVM enabled kernel, I decided to try the virt-manager and gnome-boxes GUIs. Compiling *app-emulation/qemu* with support for spice, usbredir and smartcard were required USE flags.

*/etc/portage/package.use/qemu*
```
app-emulation/qemu -oss spice usbredir smartcard
```

I run systemd and found the *app-emulation/libvirt* package was blocked because *sys-apps/systemd* was not compiled with the *cgroup-hybrid* USE flag. I was reminded how to interpret the blocked packages error from ebuilds. For some reason it always takes me several minutes and, often, a web search to remind myself that I do actually know the answer. 

For the future, an emerge blocked package error like the following means that the package must be rebuilt with \(or without\) the noted USE flag. In this instance, the interpretation is that app-emulation/libvirt-5.6.0 is blocked because systemd was built *without* cgroup-hybrid USE flag. The solution is to add the missing USE flag to the package.use file for sys-apps/systemd.

```
[blocks B     ] sys-apps/systemd[-cgroup-hybrid(+)] ("sys-apps/systemd[-cgroup-hybrid(+)]" is blocking app-emulation/libvirt-5.6.0)
```

The other *big* issue I found after trial and error \(I seriously don\'t know why the QEMU article doesn\'t mention it\) is that in order to support networking in your VMs *app-emulation/libvirt* needs to be compiled with the *virt-network* USE flag. Initially I ran into the following error while following this [article](https://medium.com/@artem.v.vasilyev/use-ubuntu-cloud-image-with-kvm-1f28c19f82f8) on setting up Ubuntu 18.04 image using [cloud-init](https://cloud-init.io/).

From `journalctl -u libvirtd.service`,
```
Failed to connect socket to '/var/run/libvirt/virtnetworkd-sock': No such file or directory
```

After rebuilding libvirtd with virt-network USE flag, the `virt-install` command from the ubuntu cloud image article succeeded. However, the image did not boot. In the interest of time, since I really want to explore OSM, I downloaded and installed Ubuntu 18.04 manually and everything worked without a hitch. Just remember to remove the installation media path before rebooting. :\)

Now onto [Getting started with Charmed OSM](https://jaas.ai/tutorials/charmed-osm-get-started#1-introduction)...

