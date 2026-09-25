FROM debian:bookworm-slim

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu gpg wget \
	&& rm -rf /var/lib/apt/lists/*

ENV BITCOIN_VERSION=27.1.0
ENV BITCOIN_URL=https://github.com/bitcoin-cash-node/bitcoin-cash-node/releases/download/v27.1.0/bitcoin-cash-node-27.1.0-x86_64-linux-gnu.tar.gz
ENV BITCOIN_SHA256=0dcc387cbaa3a039c97ddc8fb99c1fa7bff5dc6e4bd3a01d3c3095f595ad2dce
ENV BITCOIN_ARM64_URL=https://github.com/bitcoin-cash-node/bitcoin-cash-node/releases/download/v27.1.0/bitcoin-cash-node-27.1.0-aarch64-linux-gnu.tar.gz
ENV BITCOIN_ARM64_SHA256=e7996c776a5432df0455c2d33d7d8779624d11534ee84c8a668bc209f8c1713d

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