---
layout: post
title: Making an AWS Amplify Docker build image with elm-make on Gentoo
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

## Creating the amplify-elm Docker image

Based on [https://github.com/butaca/amplify-hugo](https://github.com/butaca/amplify-hugo), I went through a number of experiments to find that amazonlinux:2 image was the best starting point. I chose install **node v12.10.0 LTS** version directly, rather than setting up `nvm` on the Docker image. And only installed the `elm` executable, as `elm-test` requires many node_modules and therefore the build steps can install `elm-test` as a build step.

Dockerfile
```
FROM amazonlinux:2

ENV VERSION_ELM=0.19.1
ENV VERSION_NODE=12.10.0

# install curl, git, openssl (AWS Amplify requirements)
# install tar, xz (nodejs requirements)
RUN yum -y update && \
    yum -y install curl git openssl tar xz && \
    yum clean all && \
    rm -fr /var/cache/yum

# Install Node (AWS Amplify and elm-repl requirements)
RUN mkdir -p /opt/nodejs && \
    curl -L -o- https://nodejs.org/dist/v${VERSION_NODE}/node-v${VERSION_NODE}-linux-x64.tar.xz | tar -xJvf- -C /opt/nodejs

# Rather than updating PATH env, symlink node,npm,npx to /usr/local/bin
RUN ln -s /opt/nodejs/node-v${VERSION_NODE}-linux-x64/bin/{node,npm,npx} /usr/local/bin/

# Install Elm
RUN curl -L -o- https://github.com/elm/compiler/releases/download/${VERSION_ELM}/binary-for-linux-64-bit.gz | gunzip > /usr/local/bin/elm && \
    chmod +x /usr/local/bin/elm

CMD ["/usr/local/bin/elm", "repl"]
```

The final Docker [image](https://hub.docker.com/repository/docker/aahamlin97/awsamplify-elm) is available on Docker Hub and the [amplify-elm](https://github.com/aahamlin/amplify-elm) project repo.


## Test out the local build

Using Docker images to compile locally is straight forward, other than some possible file permissions depending your platform. I created a small build script to compile elm.

build.sh contents:
```
SCRIPT_DIR=`dirname $0`
cd $SCRIPT_DIR
elm make src/Main.elm --output=elm.js
```
This makes the docker commandline to compile simple. Any build tool that exists \(in the docker image\) could be substituted for your needs.

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

**Warning** dealing with permissions of the docker output. The `elm.js` file will be owned by the `root` user, rather than your current user. This article and many other sources show how to map user and group ids, etc... See [https://vsupalov.com/docker-shared-permissions/](https://vsupalov.com/docker-shared-permissions/)

I found locally on my Gentoo box that it was simply enough to add the `--user "$(id -u):$(id -g)"` argument to the `docker run` command. On my MacBook, this was unnecessary. Docker Desktop for Mac preserved the permissions of my local user.

## Keep localhost storage clean

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

The Amplify setup is well documented by AWS \(as you'd expect\) but the build steps for Elm are represented here. If you choose to add `elm-test` in your package.json file, then uncomment the preBuild and test phases.

```
version: 0.1
frontend:
  phases:
    # IMPORTANT - Please verify your build commands
    #preBuild:
    #  commands:
    #    - npm ci
    build:
      commands: 
        - elm make src/Main.elm --output=elm.js
    #test:
    #  commands:
    #    - npx elm-test
  artifacts:
    # IMPORTANT - Please verify your build output directory
    baseDirectory: /
    files:
      - 'assets/**/*'
      - 'index.html'
      - 'elm.js'
  cache:
    paths:
      - 'node_modules/'
      - 'elm-stuff/'
```

