# Private OpenVPN setup

Managed with [kylemanna/docker-openvpn](https://github.com/kylemanna/docker-openvpn) docker image.

Generate server & client configuration:

```shell
$ docker run --net=none --rm -ti -v $PWD:/etc/openvpn -w /etc/openvpn kylemanna/openvpn ./setup.sh
```

Copy server configuration to the destination server:

```shell
$ scp -r servers/vpn.example.com/* vpn.example.com:/etc/openvpn/
```

Run on destination server:

```shell
$ docker run --rm --cap-add=NET_ADMIN -v /etc/openvpn:/etc/openvpn -p 2194:1194/udp kylemanna/openvpn ovpn_run
```

Connect with client config and have fun!
