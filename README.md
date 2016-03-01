# Docker-Bitcoin

[![Build Status](https://img.shields.io/travis/amacneil/docker-bitcoin.svg)](https://travis-ci.org/amacneil/docker-bitcoin)
[![License](https://img.shields.io/github/license/amacneil/docker-bitcoin.svg)](https://github.com/amacneil/docker-bitcoin/blob/master/LICENSE)

Bitcoin uses peer-to-peer technology to operate with no central authority or banks; managing transactions and the issuing of bitcoin is carried out collectively by the network. Bitcoin is open-source; its design is public, nobody owns or controls Bitcoin and everyone can take part. Through many of its unique properties, Bitcoin allows exciting uses that could not be covered by any previous payment system.

This Docker image provides `bitcoin`, `bitcoin-cli` and `bitcoin-tx` applications which can be used to run and interact with a bitcoin server.

To see the currently available versions/tags, please visit the appropriate pages on Docker Hub:

* [Bitcoin Core](https://hub.docker.com/r/amacneil/bitcoin/tags/)
* [Bitcoin Classic](https://hub.docker.com/r/amacneil/bitcoinclassic/tags/)
* [Bitcoin XT](https://hub.docker.com/r/amacneil/bitcoinxt/tags/)

**Usage**

To start a bitcoind instance running the latest version (`0.12`):

```
$ docker run --name some-bitcoin amacneil/bitcoin
```

This docker image provides different tags so that you can specify the exact version of bitcoin you wish to run. For example, to run the latest minor version in the `0.11.x` series (currently `0.11.2`):

```
$ docker run --name some-bitcoin amacneil/bitcoin:0.11
```

Or, to run the `0.11.1` release specifically:

```
$ docker run --name some-bitcoin amacneil/bitcoin:0.11.1
```

To run a bitcoin container in the background, pass the `-d` option to `docker run`:

```
$ docker run -d --name some-bitcoin amacneil/bitcoin
```

Once you have a bitcoin service running in the background, you can show running containers:

```
$ docker ps
```

Or view the logs of a service:

```
$ docker logs -f some-bitcoin
```

To stop and restart a running container:

```
$ docker stop some-bitcoin
$ docker start some-bitcoin
```

**Alternative Clients**

Images are also provided for Bitcoin Classic and Bitcoin XT, which are separately maintained forks of the original Bitcoin Core codebase.

To run the latest version of Bitcoin Classic:

```
$ docker run amacneil/bitcoinclassic
```

To run the latest version of Bitcoin XT:

```
$ docker run amacneil/bitcoinxt
```

Specific versions of Bitcoin Classic and Bitcoin XT may be run using the command line options above.

**Data Volumes**

By default, Docker will create ephemeral containers. That is, the blockchain data will not be persisted if you create a new bitcoin container.

To create a simple `busybox` data volume and link it to a bitcoin service:

```
$ docker create -v /data --name btcdata busybox /bin/true
$ docker run --volumes-from btcdata amacneil/bitcoin
```

**Configuring Bitcoin**

The easiest method to configure the bitcoin server is to pass arguments to the `bitcoind` command. For example, to run bitcoin on the testnet:

```
$ docker run --name bitcoin-testnet amacneil/bitcoin bitcoind -testnet
```
