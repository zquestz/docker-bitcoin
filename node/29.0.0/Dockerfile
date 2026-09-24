FROM debian:bookworm-slim

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu gpg wget \
	&& rm -rf /var/lib/apt/lists/*

ENV BITCOIN_VERSION=29.0.0
ENV BITCOIN_URL=https://github.com/bitcoin-cash-node/bitcoin-cash-node/releases/download/v29.0.0/bitcoin-cash-node-29.0.0-x86_64-linux-gnu.tar.gz
ENV BITCOIN_SHA256=6125d1cbecc1db476f2b6b7b91da5acde92d2311b8e738124e3db64ca84b33e1
ENV BITCOIN_ARM64_URL=https://github.com/bitcoin-cash-node/bitcoin-cash-node/releases/download/v29.0.0/bitcoin-cash-node-29.0.0-aarch64-linux-gnu.tar.gz
ENV BITCOIN_ARM64_SHA256=67f0006876ebb57bbef63f7c9804fb40a8b513a42f10060b0592846a9d4dd8f1

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