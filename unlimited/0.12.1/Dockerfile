FROM debian:jessie

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

RUN set -ex \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends ca-certificates wget \
	&& rm -rf /var/lib/apt/lists/*

# grab gosu for easy step-down from root
RUN set -ex \
	&& gpg --keyserver keyserver.ubuntu.com --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& wget -qO /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.7/gosu-$(dpkg --print-architecture)" \
	&& wget -qO /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.7/gosu-$(dpkg --print-architecture).asc" \
	&& gpg --verify /usr/local/bin/gosu.asc \
	&& rm /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu

ENV BITCOIN_VERSION 0.12.1
ENV BITCOIN_URL https://github.com/BitcoinUnlimited/BitcoinUnlimitedWebDownloadHistory/raw/master/bitcoinUnlimited-0.12.1-linux64.tar.gz
ENV BITCOIN_SHA256 34de171ac1b48b0780d68f3844c9fd2e8bfe6a7780b55e1f012067c2440ebd8a

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
