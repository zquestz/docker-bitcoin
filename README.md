# Docker-Bitcoin

[![Build Status](https://img.shields.io/travis/amacneil/docker-bitcoin.svg)](https://travis-ci.org/amacneil/docker-bitcoin)
[![License](https://img.shields.io/github/license/amacneil/docker-bitcoin.svg)](https://github.com/amacneil/docker-bitcoin/blob/master/LICENSE)

Bitcoin uses peer-to-peer technology to operate with no central authority or banks; managing transactions and the issuing of bitcoin is carried out collectively by the network. Bitcoin is open-source; its design is public, nobody owns or controls Bitcoin and everyone can take part. Through many of its unique properties, Bitcoin allows exciting uses that could not be covered by any previous payment system.

This Docker image provides `bitcoin`, `bitcoin-cli` and `bitcoin-tx` applications which can be used to run and interact with a bitcoin server.

Images are provided for a range of current and historic Bitcoin forks.
To see the available versions/tags, please visit the appropriate pages on Docker Hub:

* [Bitcoin Core](https://hub.docker.com/r/amacneil/bitcoin/tags/)
* [Bitcoin Classic](https://hub.docker.com/r/amacneil/bitcoinclassic/tags/)
* [Bitcoin Unlimited](https://hub.docker.com/r/amacneil/bitcoinunlimited/tags/)
* [Bitcoin XT](https://hub.docker.com/r/amacneil/bitcoinxt/tags/)
* [btc1 Core](https://hub.docker.com/r/amacneil/btc1/tags/)

### Usage

To start a bitcoind instance running the latest version:

```
$ docker run amacneil/bitcoin
```

This docker image provides different tags so that you can specify the exact version of bitcoin you wish to run. For example, to run the latest minor version in the `0.11.x` series (currently `0.11.2`):

```
$ docker run amacneil/bitcoin:0.11
```

Or, to run the `0.11.1` release specifically:

```
$ docker run amacneil/bitcoin:0.11.1
```

To run a bitcoin container in the background, pass the `-d` option to `docker run`, and give your container a name for easy reference later:

```
$ docker run -d --rm --name bitcoind amacneil/bitcoin
```

Once you have a bitcoin service running in the background, you can show running containers:

```
$ docker ps
```

Or view the logs of a service:

```
$ docker logs -f bitcoind
```

To stop and restart a running container:

```
$ docker stop bitcoind
$ docker start bitcoind
```

### Alternative Clients

Images are also provided for btc1, Bitcoin Unlimited, Bitcoin Classic, and Bitcoin XT, which are separately maintained forks of the original Bitcoin Core codebase.

To run the latest version of btc1 Core:

```
$ docker run amacneil/btc1
```

To run the latest version of Bitcoin Classic:

```
$ docker run amacneil/bitcoinclassic
```

To run the latest version of Bitcoin Unlimited:

```
$ docker run amacneil/bitcoinunlimited
```

To run the latest version of Bitcoin XT:

```
$ docker run amacneil/bitcoinxt
```

Specific versions of these alternate clients may be run using the command line options above.

### Configuring Bitcoin

The best method to configure the bitcoin server is to pass arguments to the `bitcoind` command. For example, to run bitcoin on the testnet:

```
$ docker run --name bitcoind-testnet amacneil/bitcoin bitcoind -testnet
```

Alternatively, you can edit the `bitcoin.conf` file which is generated in your data directory (see below).

### Data Volumes

By default, Docker will create ephemeral containers. That is, the blockchain data will not be persisted, and you will need to sync the blockchain from scratch each time you launch a container.

To keep your blockchain data between container restarts or upgrades, simply add the `-v` option to create a [data volume](https://docs.docker.com/engine/tutorials/dockervolumes/):

```
$ docker run -d --rm --name bitcoind -v bitcoin-data:/data amacneil/bitcoin
$ docker ps
$ docker inspect bitcoin-data
```

Alternatively, you can map the data volume to a location on your host:

```
$ docker run -d --rm --name bitcoind -v "$PWD/data:/data" amacneil/bitcoin
$ ls -alh ./data
```

### Using bitcoin-cli

By default, Docker runs all containers on a private bridge network. This means that you are unable to access the RPC port (8332) necessary to run `bitcoin-cli` commands.

There are several methods to run `bitclin-cli` against a running `bitcoind` container. The easiest is to simply let your `bitcoin-cli` container share networking with your `bitcoind` container:

```
$ docker run -d --rm --name bitcoind -v bitcoin-data:/data amacneil/bitcoin
$ docker run --rm --network container:bitcoind amacneil/bitcoin bitcoin-cli getinfo
```

If you plan on exposing the RPC port to multiple containers (for example, if you are developing an application which communicates with the RPC port directly), you probably want to consider creating a [user-defined network](https://docs.docker.com/engine/userguide/networking/). You can then use this network for both your `bitcoind` and `bitclin-cli` containers, passing `-rpcconnect` to specify the hostname of your `bitcoind` container:

```
$ docker network create bitcoin
$ docker run -d --rm --name bitcoind -v bitcoin-data:/data --network bitcoin amacneil/bitcoin
$ docker run --rm --network bitcoin amacneil/bitcoin bitcoin-cli -rpcconnect=bitcoind getinfo
```

### Complete Example

For a complete example of running a bitcoin node using Docker Compose, see the [Docker Compose example](/example#readme).

### License

Configuration files and code in this repository are distributed under the [MIT license](/LICENSE).

### Contributing

All files are generated from templates in the root of this repository. Please do not edit any of the generated Dockerfiles directly.

* To add a new Bitcoin version, update [versions.yml](/versions.yml), then run `make update`.
* To make a change to the Dockerfile which affects all current and historical Bitcoin versions, edit [Dockerfile.erb](/Dockerfile.erb) then run `make update`.

If you would like to build and test containers for all versions (similar to what happens in CI), run `make`. If you would like to build and test all containers for a specific Bitcoin fork, run `BRANCH=core make`.
