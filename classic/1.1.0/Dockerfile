FROM debian:stretch-slim

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu gpg wget \
	&& rm -rf /var/lib/apt/lists/*

ENV BITCOIN_VERSION 1.1.0
ENV BITCOIN_URL https://github.com/bitcoinclassic/bitcoinclassic/releases/download/v1.1.0/bitcoin-1.1.0-linux64.tar.gz
ENV BITCOIN_SHA256 67a7fba1beccc490be9d92913de632eed96259fba92b6a318321b0b2f247316b
ENV BITCOIN_ASC_URL https://github.com/bitcoinclassic/bitcoinclassic/releases/download/v1.1.0/SHA256SUMS.asc
ENV BITCOIN_PGP_KEY C07B28FD422F1B49E78889F5C2A5545EA91CCAE7

# install bitcoin binaries
RUN set -ex \
	&& BITCOIN_DIST=$(basename $BITCOIN_URL) \
	&& wget -qO $BITCOIN_DIST $BITCOIN_URL \
	&& echo "$BITCOIN_SHA256 $BITCOIN_DIST" | sha256sum -c - \
	&& gpg --keyserver keyserver.ubuntu.com --recv-keys $BITCOIN_PGP_KEY \
	&& wget -qO bitcoin.asc $BITCOIN_ASC_URL \
	&& gpg --verify bitcoin.asc \
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
