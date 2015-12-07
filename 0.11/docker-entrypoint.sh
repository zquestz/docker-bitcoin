#!/bin/bash
set -e

if [ "$1" = 'bitcoin-cli' -o "$1" = 'bitcoin-tx' -o "$1" = 'bitcoind' -o "$1" = 'test_bitcoin' ]; then
  mkdir -p "$BITCOIN_DATA"

  if [ ! -s "$BITCOIN_DATA/bitcoin.conf" ]; then
    cat <<EOF > "$BITCOIN_DATA/bitcoin.conf"
rpcuser=bitcoin
rpcpassword=password
EOF
  fi

  chown -R bitcoin:bitcoin "$BITCOIN_DATA"
  exec gosu bitcoin "$@"
fi

exec "$@"
