---
layout: post
title: systemd-resolved stopped working
---

systemd-resolved stopped retrieving my ISP\'s DNS servers. Viewing my WiFi connection via NetworkManager, I verified that the information was indeed being retrieved, but `resolvectl query <dns-name>` failed. And, of course, applications like *Chrome* and *ping* stopped. 

After enabling DEBUG output for systemd-resolved, there were still no discernable errors being shown in *journalctl* output.

I went through the following steps to disable systemd-resolved and switched to simply using NetworkManager and dhclient directly. And name resolution was restored. Since this is just my home machine and I only have 1 WiFi endpoint, this is fine for now.

```
$ rm /etc/resolv.conf
$ systemctl disable systemd-resolved
$ systemctl stop systemd-resolved
$ ln -s /run/NetworkManager/resolv.conf /etc/resolv.conf
$ reboot
```

The end.
