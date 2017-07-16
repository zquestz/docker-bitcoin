#!/bin/bash
set -e

if [ "$1" = 'bitcoin-cli' -o "$1" = 'bitcoin-tx' -o "$1" = 'bitcoind' -o "$1" = 'test_bitcoin' ]; then
	mkdir -p "$BITCOIN_DATA"

	if [ ! -s "$BITCOIN_DATA/bitcoin.conf" ]; then
		cat <<-EOF > "$BITCOIN_DATA/bitcoin.conf"
		printtoconsole=1
		rpcallowip=::/0
		rpcpassword=${BITCOIN_RPC_PASSWORD:-password}
		rpcuser=${BITCOIN_RPC_USER:-bitcoin}
		EOF
	fi

	chown -R bitcoin "$BITCOIN_DATA"
	exec gosu bitcoin "$@"
fi

exec "$@"
