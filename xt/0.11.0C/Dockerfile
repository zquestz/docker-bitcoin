FROM debian:stretch-slim

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu gpg wget \
	&& rm -rf /var/lib/apt/lists/*

ENV BITCOIN_VERSION 0.11.0C
ENV BITCOIN_URL https://github.com/bitcoinxt/bitcoinxt/releases/download/v0.11C/bitcoin-xt-0.11.0-C-linux64.tar.gz
ENV BITCOIN_SHA256 d879c701f500303ef807b3f49a6aa1ab021ad9e86b3f4a6f7a0bf3d5ce05e545

# install bitcoin binaries
RUN set -ex \
	&& BITCOIN_DIST=$(basename $BITCOIN_URL) \
	&& wget -qO $BITCOIN_DIST $BITCOIN_URL \
	&& echo "$BITCOIN_SHA256 $BITCOIN_DIST" | sha256sum -c - \
	&& tar -xzvf $BITCOIN_DIST -C /usr/local --strip-components=1 --exclude=*-qt \
	&& rm bitcoin*

# create data directory
ENV BITCOIN_DATA /data
RUN mkdir $BITCOIN_DATA \
	&& chown -R bitcoin:bitcoin $BITCOIN_DATA \
	&& ln -sfn $BITCOIN_DATA /home/bitcoin/.bitcoin \
	&& chown -h bitcoin:bitcoin /home/bitcoin/.bitcoin
VOLUME /data

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8332 8333 18332 18333
CMD ["bitcoind"]
