# Docker-Bitcoin

[![Build Status](https://img.shields.io/travis/zquestz/docker-bitcoin.svg)](https://travis-ci.org/zquestz/docker-bitcoin)
[![License](https://img.shields.io/github/license/zquestz/docker-bitcoin.svg)](https://github.com/zquestz/docker-bitcoin/blob/master/LICENSE)

Included in this repo are docker images for the main Bitcoin Cash full nodes. This includes Bitcoin ABC and Bitcoin Unlimited. A huge thanks to Adrian Macneil, and his now unmaintained original [repository](https://github.com/amacneil/docker-bitcoin), which provided the base for this repo.

This Docker image provides `bitcoind`, `bitcoin-cli` and `bitcoin-tx` which can be used to run and interact with a bitcoin server.

To see the available versions/tags, please visit the appropriate pages on Docker Hub:

* [Bitcoin ABC](https://hub.docker.com/r/zquestz/bitcoin-abc/)
* [Bitcoin Unlimited](https://hub.docker.com/r/zquestz/bitcoin-unlimited/)

### Usage

To run the latest version of Bitcoin ABC:

```
$ docker run zquestz/bitcoin-abc
```

To run the latest version of Bitcoin Unlimited:

```
$ docker run zquestz/bitcoin-unlimited
```

To run a container in the background, pass the `-d` option to `docker run`, and give your container a name for easy reference later:

```
$ docker run -d --rm --name bitcoind zquestz/bitcoin-abc
```

Once you have the bitcoind service running in the background, you can show running containers:

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

### Configuring Bitcoin

The best method to configure the server is to pass arguments to the `bitcoind` command. For example, to run bitcoin-unlimited on the testnet:

```
$ docker run --name bitcoind-testnet zquestz/bitcoin-unlimited bitcoind -testnet
```

Alternatively, you can edit the `bitcoin.conf` file which is generated in your data directory (see below).

### Data Volumes

By default, Docker will create ephemeral containers. That is, the blockchain data will not be persisted, and you will need to sync the blockchain from scratch each time you launch a container.

To keep your blockchain data between container restarts or upgrades, simply add the `-v` option to create a [data volume](https://docs.docker.com/engine/tutorials/dockervolumes/):

```
$ docker run -d --rm --name bitcoind -v bitcoin-data:/data zquestz/bitcoin-abc
$ docker ps
$ docker inspect bitcoin-data
```

Alternatively, you can map the data volume to a location on your host:

```
$ docker run -d --rm --name bitcoind -v "$PWD/data:/data" zquestz/bitcoin-abc
$ ls -alh ./data
```

### Using bitcoin-cli

By default, Docker runs all containers on a private bridge network. This means that you are unable to access the RPC port (8332) necessary to run `bitcoin-cli` commands.

There are several methods to run `bitclin-cli` against a running `bitcoind` container. The easiest is to simply let your `bitcoin-cli` container share networking with your `bitcoind` container:

```
$ docker run -d --rm --name bitcoind -v bitcoin-data:/data zquestz/bitcoin-abc
$ docker run --rm --network container:bitcoind zquestz/bitcoin-abc bitcoin-cli getinfo
```

If you plan on exposing the RPC port to multiple containers (for example, if you are developing an application which communicates with the RPC port directly), you probably want to consider creating a [user-defined network](https://docs.docker.com/engine/userguide/networking/). You can then use this network for both your `bitcoind` and `bitclin-cli` containers, passing `-rpcconnect` to specify the hostname of your `bitcoind` container:

```
$ docker network create bitcoin
$ docker run -d --rm --name bitcoind -v bitcoin-data:/data --network bitcoin zquestz/bitcoin-abc
$ docker run --rm --network bitcoin zquestz/bitcoin-abc bitcoin-cli -rpcconnect=bitcoind getinfo
```

### Kubernetes Configs

The following directions will walk you through creating a BCH full node within GKE (Google Container Engine).

By default Bitcoin ABC is used, however this can be swapped for any other node quite easily.

If you wish to run another version of bitcoind, just change the image reference in `bitcoin-deployment.yml`. If you don't trust the pre-built images, build your own. =)

Steps:
1. Add a new blank disk on GCE called `bitcoin-data` that is 200GB. You can always expand it later.
2. Save the following code snippets and place them in a new directory `kube`.
3. Change the `rpcuser` and `rpcpass` values in `bitcoin-secrets.yml`. They are base64 encoded. To base64 a string, just run `echo -n SOMESTRING | base64`.
4. Run `kubectl create -f /path/to/kube`
5. Profit!

#### bitcoin-deployment.yml
```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  namespace: default
  labels:
    service: bitcoin
  name: bitcoin
spec:
  strategy:
    type: Recreate
  replicas: 1
  template:
    metadata:
      labels:
        service: bitcoin
    spec:
      containers:
      - env:
        - name: BITCOIN_RPC_USER
          valueFrom:
            secretKeyRef:
              name: bitcoin
              key: rpcuser
        - name: BITCOIN_RPC_PASSWORD
          valueFrom:
            secretKeyRef:
              name: bitcoin
              key: rpcpass
        image: zquestz/bitcoin-abc
        name: bitcoin
        volumeMounts:
          - mountPath: /data
            name: bitcoin-data
        resources:
          requests:
            memory: "2Gi"
      restartPolicy: Always
      volumes:
        - name: bitcoin-data
          gcePersistentDisk:
            pdName: bitcoin-data
            fsType: ext4
```

#### bitcoin-secrets.yml
```
apiVersion: v1
kind: Secret
metadata:
  name: bitcoin
type: Opaque
data:
  rpcuser: YWRtaW4=
  rpcpass: aXRvbGR5b3V0b2NoYW5nZXRoaXM=
```

#### bitcoin-srv.yml
```
apiVersion: v1
kind: Service
metadata:
  name: bitcoin
  namespace: default
spec:
  ports:
    - port: 8333
      targetPort: 8333
  selector:
    service: bitcoin
  type: LoadBalancer
  externalTrafficPolicy: Local
```

### Complete Example

For a complete example of running a bitcoin node using Docker Compose, see the [Docker Compose example](/example#readme).

### License

Configuration files and code in this repository are distributed under the [MIT license](/LICENSE).

### Contributing

All files are generated from templates in the root of this repository. Please do not edit any of the generated Dockerfiles directly.

* To add a new version, update [versions.yml](/versions.yml), then run `make update`.
* To make a change to the Dockerfile which affects all current and historical versions, edit [Dockerfile.erb](/Dockerfile.erb) then run `make update`.

If you would like to build and test containers for all versions (similar to what happens in CI), run `make`. If you would like to build and test all containers for a specific node, run `BRANCH=abc make`.
