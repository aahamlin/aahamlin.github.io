---
layout: post
title: Random stuff that happened this week
tags: covid-19, audio, ffmpeg
---

My son needs to record a vocal performance for school. Its going to be a choral review built by piecing together audio-video tracks of all students, filmed at home in quaratine due to covid-19. I suggested we use my Tascam DP-02CF digital recorder, all I needed was the song in WAV format (44.1K 16-bit mono, to be exact), then we could record his vocal track, etc. The song was sent to us in .m4a file. After some fiddling and missteps, `ffmpeg` was able to decode m4a and produce 2 mono wav tracks in a single command.

```
ffmpeg -i source.m4a -map_channel 0.0.0 LEFT.WAV -map_channel 0.0.1 RIGHT.WAV
```


My music studio computer's hard drive started crashing during a 'world' update, and I was no longer able to boot successfully because the root partition got corrupted. Luckily, I found my Gentoo Live CD USB stick and was able to boot, check and fix the drive with `fsck.ext4`.

I have been in the habit of doing 'world' updates without chromium because it takes hours to compile.
```
sudo emerge -avuDN --exclude=www-client/chromium @world
```


And I am always annoyed by how long emerge dependency calculations take, a single cpu gets pegs at 100%. Searching online I found references that the dependency checker is restricted to a single core/cpu. But, also found the recommendation to use `ccache` to speed up compile of large packages, overtime. I am running an update of chromium now after setting up [ccache](https://wiki.gentoo.org/wiki/Ccache). Hopefully, future updates will see a noticeable decrease in time spent.

At the beginning of the week, I discovered [M-Emacs](https://github.com/MatthewZMD/.emacs.d) as I was experimenting with [eglot](https://github.com/joaotavora/eglot) and [lsp-mode](https://github.com/emacs-lsp/lsp-mode) for [Elm](https://elm-lang.org) programming. My initial problem with eglot was that it did not differentiate different projects within emacs buffers, or so I thought, and I tried lsp-mode to see if it worked better. I stumbled across M-Emacs during that search and have been trying it. It is a little too heavy on remapping keybindings for my taste and includes a ton of stuff I don't care about, but it also has configured a lot of great packages. I am excited to continue customizing and may use it as a base to update my own emacs config project...

That's all for now.

