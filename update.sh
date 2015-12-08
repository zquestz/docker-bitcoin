#!/bin/bash
set -e

versions=( "$@" )
for version in "${versions[@]}"; do
	exists="$(curl -fsLI https://bitcoin.org/bin/bitcoin-core-$version/bitcoin-$version-linux64.tar.gz; true)"
	if [ -z "$exists" ]; then
		echo >&2 "warning: cannot find version $version"
		continue
	fi
	major="$(echo $version | cut -d'.' -f1-2)"
	minor="$(echo $version | cut -d'.' -f3)"
	(
		set -x
		mkdir -p "$version/"
		cp docker-entrypoint.sh "$version/"
		sed '
			s/%%BITCOIN_VERSION%%/'"$version"'/g;
		' Dockerfile.template > "$version/Dockerfile"
		if [ ! -s "$major/Dockerfile" ] || [ "$(grep "ENV BITCOIN_VERSION" "$major/Dockerfile" | cut -d'.' -f3)" -lt "$minor" ]; then
			rm -rf $major
			cp -R $version $major
		fi
	)
done
