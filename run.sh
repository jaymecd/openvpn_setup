#!/bin/sh

set -exo pipefail

docker run --net=none --rm -ti -v $PWD:/etc/openvpn -w /etc/openvpn kylemanna/openvpn ./setup.sh
