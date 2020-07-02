---
layout: post
title: Refresh Gentoo Release Keys
---

After following the setup contained on the [Features](https://wiki.gentoo.org/wiki/Handbook:Parts/Working/Features/en) page, I was getting an `untrusted key` warning when running: `emerge --sync`. I found that this feature was entirely deprecated and replaced with `sync-webrsync-verify-signature` in repos.conf. See `man portage (5)`.

Going back to the [Release Engineering](https://wiki.gentoo.org/wiki/Project:RelEng) page, I ran the following to update the existing keys. Then, I was able to sync without warning.

```
$ cd /usr/share/openpgp-keys
$ gpg --keyserver hkps://keys.gentoo.org --recv-keys 0x825533CBF6CD6C97
$ gpg --keyserver hkps://keys.gentoo.org --recv-keys 0xDB6B8C1F96D8BF6D
$ gpg --keyserver hkps://keys.gentoo.org --recv-keys 0x9E6438C817072058
$ gpg --keyserver hkps://keys.gentoo.org --recv-keys 0xBB572E0E2D182910
$ gpg --keyserver hkps://keys.gentoo.org --recv-keys 0x0838C26E239C75C4
```

Remove `app-crypt/gentoo-keys` and `FEATURE=webrsync-gpg` and `PORTAGE_GPG_DIR=` from your make.conf.

The repos.conf settings look like they should automatically refresh the keys. Maybe I inadvertently broke the signature verification when I attempted to use the deprecated feature.
