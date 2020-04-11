---
layout: post
title: Setting up Charmed OSM on Macbook
---

I spent some time this month exploring Ubuntu\'s Charmed distribution of Open Source Mano. See the article, [Getting started with Charmed OSM](https://jaas.ai/tutorials/charmed-osm-get-started)

Some things they don\'t call out. The default multipass VM is underpowered.

```
multipass -c 2 -m 4G -d 50G -n primary
```
memory 4G is **required**


This init process take a long time \(on my 2015 Macbook\)\!

```
sudo microstack.init --auto
```
expect 10-15 minutes, per microstack setup doc

Exposing the OSM Dashboard is not explained. This [Juju discourse](https://discourse.jujucharms.com/t/first-steps-with-the-canonical-distribution-of-open-source-mano/1533/12) has some answers. 

