---
layout: post
title: Emacs and elm-0.19 with Language Server Protocol
---

With my recent upgrade to elm-0.19.1, I have discovered my [Emacs configuration](https://bitbucket.org/andrew_hamlin/emacs.d/src/master/) needs to be updated for [elm-mode](https://github.com/jcollard/elm-mode) to support [Elm >=0.19](https://github.com/jcollard/elm-mode#completion-for-elm--019). The new support is through the [Language Server Protocol](https://microsoft.github.io/language-server-protocol/) from Microsoft.

First step is to disable my old broken configuration. This basically consists of removing `company-elm` and `flycheck-elm` from my elm-setup.el file. 

## Installation

### Emacs

Add `eglot` to my emacs package list. Using my configuration files, adding `eglot` to the `my-packages` variable in `packages-setup.el`. 
Conventionally, `M-x package-install RET eglot RET`

Then, add the proper hook as provided in [eglot](https://github.com/joaotavora/eglot) installation instructions.

### Node

Install `elm-language-server` [plugin](https://github.com/elm-tooling/elm-language-server) for the language server protocol, `sudo node install -g @elm-tooling/elm-language-server`. 

On my Gentoo box, the global npm install of `elm-format` fails so I have followed the [manual installation steps](https://github.com/avh4/elm-format/releases/tag/0.8.3). 

_I should swing back and create ebuilds for both `elm` and `elm-format`_. =)

And, on my MacBook, global npm install of `elm-test` failed when I used "sudo" but it worked without "sudo". Everything symlinked and installed properly to /usr/local/bin and /usr/local/lib/node_modules/elm-test; _something to keep in mind for the future_. 

### Final configuration

The emacs configuration for elm with LSP looks like this, having turned on `elm-format-on-save-mode`:
```
(require 'elm-mode)

(add-hook 'elm-mode-hook
          (lambda ()
            (eglot-ensure)
            (elm-format-on-save-mode)
            ))
```

Now, restart Emacs and try editing an elm file.

## Wrap up

With LSP, I no longer need elm-oracle. So I will remove that from my system.

```
$ sudo npm un -g elm-oracle
```

LSP looks promising. I should circle back and try this for python, haskell, etc...

