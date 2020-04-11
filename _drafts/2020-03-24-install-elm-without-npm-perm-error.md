---
layout: post
title: Install Elm 0.19.1 without npm to avoid permissions errors
---

There is an [issue](https://github.com/elm-lang/elm-platform/issues/225) with `npm install -g elm` that has existed for more than **two years** {% include fa_icon.html content="fa-exclamation-triangle" %}

Not to dwell on that fact, in setting up my Linux box again I want to explore using AWS Amplify with Elm so I will follow the [manual instructions](https://github.com/elm/compiler/blob/master/installers/linux/README.md) from the [elm-lang.org](https://elm-lang.org) site.

The supporting global tools for Emacs editing are `npm install -g elm-format elm-oracle` and they install just fine. I also want to use `elm-test` and for now am installing it globally, but will probably switch to `npx` for any real project.

A couple of tweaks I made to the process. Rather than moving elm to /usr/local/bin, I ran `sudo install` to set the ownership permissions automatically. And because I had previously installed using npm, bash had cached the previous `/usr/bin` location and produced the error `bash: /usr/bin/elm: No such file or directory`. Steps for both of these as follows:

```
$ sudo install elm /usr/local/bin
$ hash elm
$ elm --help
```

On Mac, Homebrew install of elm-format to avoid unverified developer error seen from NPM install of elm-format.
