---
layout: post
title: Simplest hot reloading of webpack and jekyll
---

There are several jekyll and webpack boilerplate projects but I usually avoid them because I like to keep my
dev environment as tight and simple as possible and to understand what's happening under the hood.

This is the easiest setup I have found to work for hot reloading webpack and jekyll.

The key to this working is that both webpack (4.17) and jekyll (4.0) both provide a `--watch` flag. For other
frontend projects I have usually used webpack-dev-server, which works great when it controls everything but
adding the additional Jekyll static site generator caused the hot reloading to fail.

The only requirement here is the npm package `concurrently`.

In `webpack.config.js` set your build output to a location within the Jekyll site structure.

Then setup these build and start scripts in `package.json` for building the distribution and developing locally.

```
    "scripts": {
        "start": "npm run-script clean && concurrently \"webpack --watch\" \"npm run-script start:jekyll\""
        "start:jekyll": "jekyll serve --config _config.yml --livereload --incremental",
        "build": "npm run-script clean && npm run-script build:webpack && npm run-script build:jekyll",
        "build:jekyll": "JEKYLL_ENV=production jekyll build --config _config.yml",
        "build:webpack": "NODE_ENV=production webpack --progress --profile --colors",
        "clean": "rimraf ./site/_includes/scripts.html ./site/assets/js ./dist"
    }
```
