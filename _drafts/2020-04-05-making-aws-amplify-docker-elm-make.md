---
layout: post
title: Installing Docker on Gentoo
---

Refer to Gentoo Wiki's [Docker](https://wiki.gentoo.org/wiki/Docker) page. I am following the `systemd` setup steps.

First, I need to check my kernel flags, no doubt I will need to configure something the first time around.  Rather than jumping right to `emerge`, check my current kernal configuration file. Do this by running the `prepare` step of the ebuild process. Also, because this is Gentoo, always check the available USE flags and research any you may want to enable beyond the default ones.

Checking the USE flags
```
$ equery u app-emulation/docker
```

For now, I am choosing not to add any non-default USE flags.

Checking the kernel configuration. 
Note: Using the `portageq` command to locate gentoo repo path for system compatibility.
```
$ ls $(portageq get_repo_path / gentoo)/app-emulation/docker
$ ebuild $(portageq get_repo_path / gentoo)/app-emulation/docker/docker-19.03.8.ebuild prepare

 * docker-19.03.8.tar.gz BLAKE2B SHA512 size ;-) ...                     [ ok ]
 * checking ebuild checksums ;-) ...                                     [ ok ]
 * checking miscfile checksums ;-) ...                                   [ ok ]
 * Determining the location of the kernel source code
 * Found kernel source directory:
 *     /usr/src/linux
 * Found sources for kernel version:
 *     5.4.28-gentoo
 * Checking for suitable kernel configuration options...
 *   CONFIG_NETFILTER_XT_MATCH_IPVS:	 is not set when it should be.
 *   CONFIG_CGROUP_PIDS:	 is not set when it should be.
 [remainder truncated]
```

On my system, there are a number of unset kernel flags. Change directory into `/usr/src/linux` and run `make menuconfig` to set them properly. Make sure you checked the current kernel version \(check link to /usr/src/linux or use `eselect kernel list`\).

Building a build image for AWS Amplify containing elm and elm-test. Elm depends on nodejs, so also adding node, npm, npx.

? aws amplify console sets up node using nvm, only available under bash shell ?

Walk through local build.
Create a build script to compile elm, for simplicity.

build.sh contents:
```
SCRIPT_DIR=`dirname $0`
cd $SCRIPT_DIR
elm make src/Main.elm --output=elm.js
```
This makes the docker commandline to compile simple. Any build tool that exists \(in the docker image\) could be substituted for your needs.

## Test out the local build.

From my Elm app directory, presuming I have installed elm on my host machine directly, I can locally run ./build.sh and see:
```
$ ./build.sh
Success!     

    Main ───> elm.js

```

Now, run it in the container after removing the test compile of `elm.js`. 
```
$ rm elm.js
$ docker run -it --rm -v `pwd`:/src awsamplify-elm:19.0 /src/build.sh
Success! Compiled 33 modules.

    Main ───> elm.js

```

Note we can remove the build container after compile with the `--rm` flag to keep the disc clean. More on that later.

**Warning** dealing with permissions of the docker output. The `elm.js` file will be owned by the `root` user, rather than your current user. This article and many other sources show how to map user and group ids, etc...
https://vsupalov.com/docker-shared-permissions/

I found locally that it was simply enough to add the `--user "$(id -u):$(id -g)"` argument to the `docker run` command.


## Keep my local host clean

See what docker has available by listing containers and images.
```
$ docker ps -a
$ docker images
```

Remove unused containers and images.
```
$ docker rm <container>
$ docker rmi <image>
```

## AWS Amplify

I already have a github repo setup with a sample Elm app, elm-spa-example.
The DockerHub repository required 
- a namespace naming convention mapping to my Docker Hub account name, aahamlin97
- that docker hub repo be public, rather than private

Additionally, I setup a docker hub access token for `docker login` to keep credentials \(more\) private but without the additional step of setting up a docker credential provider. Since this is just my home sandbox, it should be safe enough. =\)


The elm compiler worked but elm-test was unable to find the `./lib/elm-test.js` file so I am going back to run locally with a full build & test via docker container.
