# How to run a full Bitcoin node using Docker Compose

This directory contains an example [docker-compose.yml](./docker-compose.yml) file which will allow you to run a full Bitcoin node. The compose file will automatically handle creating a data volume for you, so that blockchain data is persisted between Bitcoin upgrades. It also makes it easy to run `bitcoin-cli` against your running Bitcoin node.

Before you can get started, you need to install Docker Compose. Follow the [Docker Compose installation instructions](https://docs.docker.com/compose/install/) relevant to your platform.

### Create a workspace

First, you should create a directory to keep your compose file in. Copy the example `docker-compose.yml` file from this repository into your local directory.

```sh
$ mkdir bitcoin
$ cd bitcoin
$ wget https://raw.githubusercontent.com/amacneil/docker-bitcoin/master/example/docker-compose.yml
```

### Launch bitcoind

To launch your node, simply type `docker-compose up`:

```sh
$ docker-compose up -d  # start bitcoind in the background
$ docker-compose ps     # show running processes
$ docker-compose down   # stop bitcoind (blockchain data will remain on disk)
```

### Run bitcoin-cli

To run commands against your running Bitcoin node, a `bitcoin-cli` shorthand is provided. Simply use the `docker-compose run` command:

```sh
$ docker-compose run --rm bitcoin-cli getinfo
```

Note that passing `--rm` to `docker-compose run` is not strictly necessary. However, it will prevent exited containers building up on your system after each command, which can waste disk space. If you forget to pass `--rm`, the unused containers will be cleaned up next time you run `docker-compose down`.

### Configuration options

To configure your Bitcoin node, update the `command: bitcoind` line in `docker-compose.yml`. For example, to run a node on the Bitcoin testnet, you would change the line to:

```
command: bitcoind -testnet
```

### Running a specific fork or version

The `docker-compose.yml` file can be edited to suit your needs. If you wish to run a specific version or fork of bitcoin, simply replace `amacneil/bitcoin` with the desired image.
