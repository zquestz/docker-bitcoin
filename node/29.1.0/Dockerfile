FROM debian:bookworm-slim

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu gpg wget \
	&& rm -rf /var/lib/apt/lists/*

ENV BITCOIN_VERSION=29.1.0
ENV BITCOIN_URL=https://github.com/bitcoin-cash-node/bitcoin-cash-node/releases/download/v29.1.0/bitcoin-cash-node-29.1.0-x86_64-linux-gnu.tar.gz
ENV BITCOIN_SHA256=2d52f6c3091351095839415bfd9ad6ee5cdd34aa6c726f2078ae28aa9015acc4
ENV BITCOIN_ARM64_URL=https://github.com/bitcoin-cash-node/bitcoin-cash-node/releases/download/v29.1.0/bitcoin-cash-node-29.1.0-aarch64-linux-gnu.tar.gz
ENV BITCOIN_ARM64_SHA256=15c5c0400c828d6690970200ad59c18207313c7047b29d571f7e9870d06300ea

# set by buildx (and by BuildKit for the host platform)
ARG TARGETARCH

# install bitcoin binaries
RUN set -ex \
	&& cd /tmp \
	&& if [ "$TARGETARCH" = "arm64" ]; then \
		BITCOIN_URL="$BITCOIN_ARM64_URL"; \
		BITCOIN_SHA256="$BITCOIN_ARM64_SHA256"; \
	fi \
	&& wget -qO bitcoin.tar.gz "$BITCOIN_URL" \
	&& echo "$BITCOIN_SHA256 bitcoin.tar.gz" | sha256sum -c - \
	&& tar -xzvf bitcoin.tar.gz -C /usr/local --strip-components=1 --exclude=*-qt \
	&& rm -rf /tmp/*

# create data directory
ENV BITCOIN_DATA=/data
RUN mkdir "$BITCOIN_DATA" \
	&& chown -R bitcoin:bitcoin "$BITCOIN_DATA" \
	&& ln -sfn "$BITCOIN_DATA" /home/bitcoin/.bitcoin \
	&& chown -h bitcoin:bitcoin /home/bitcoin/.bitcoin
VOLUME /data

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8332 8333 18332 18333
CMD ["bitcoind"]