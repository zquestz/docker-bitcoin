FROM debian:stretch-slim

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu gpg wget \
	&& rm -rf /var/lib/apt/lists/*

ENV BITCOIN_VERSION 1.0.0.1
ENV BITCOIN_URL https://github.com/BitcoinUnlimited/BitcoinUnlimitedWebDownloadHistory/raw/master/bitcoinUnlimited-1.0.0.1-linux64.tar.gz
ENV BITCOIN_SHA256 cfedf1a4701cf05f8e8a9ff4da0f887bcb2b3bbdcd7631e9cfdeebb6dff01c72

# install bitcoin binaries
RUN set -ex \
	&& BITCOIN_DIST=$(basename $BITCOIN_URL) \
	&& wget -qO $BITCOIN_DIST $BITCOIN_URL \
	&& echo "$BITCOIN_SHA256 $BITCOIN_DIST" | sha256sum -c - \
	&& tar -xzvf $BITCOIN_DIST -C /usr/local --strip-components=1 --exclude=*-qt \
	&& rm bitcoin*

ENV BITCOIN_DATA /data
RUN mkdir $BITCOIN_DATA \
	&& chown bitcoin:bitcoin $BITCOIN_DATA \
	&& ln -s $BITCOIN_DATA /home/bitcoin/.bitcoin
VOLUME /data

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8332 8333 18332 18333
CMD ["bitcoind"]
