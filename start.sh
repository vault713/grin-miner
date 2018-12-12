#!/bin/sh
if [ -z "$STRATUM_SERVER_ADDR" ]; then
  cat >&2 <<EOF
STRATUM_SERVER_ADDR env variable is required to run this container.
EOF
  exit 1
fi

if [ -z "$STRATUM_SERVER_LOGIN" ]; then
  cat >&2 <<EOF
STRATUM_SERVER_LOGIN env variable is required to run this container.
EOF
  exit 1
fi

if [ -z "$STRATUM_SERVER_PASSWORD" ]; then
  cat >&2 <<EOF
STRATUM_SERVER_PASSWORD env variable is required to run this container.
EOF
  exit 1
fi

cat grin-miner.toml.template | sed 's/STRATUM_SERVER_ADDR/'$STRATUM_SERVER_ADDR'/g' | sed 's/STRATUM_SERVER_LOGIN/'$STRATUM_SERVER_LOGIN'/g' | sed 's/STRATUM_SERVER_PASSWORD/'$STRATUM_SERVER_PASSWORD'/g' > grin-miner.toml
./grin-miner