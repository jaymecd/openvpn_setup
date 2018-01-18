#!/bin/sh

set -exo pipefail

cd "${OPENVPN}"

PORT="2194"
DOMAIN="jaymecd.rocks"
SERVERS="loppanga loppinga"
CLIENTS="nikolai jelena"

export EASYRSA_PKI="${OPENVPN}/pki"
export EASYRSA_BATCH=1
export EASYRSA_REQ_CN="jaymecd CA"

test -d "${EASYRSA_PKI}" || easyrsa init-pki
test -f "${EASYRSA_PKI}/ca.crt" || easyrsa build-ca nopass --batch
test -f "${EASYRSA_PKI}/dh.pem" || easyrsa gen-dh
test -f "${EASYRSA_PKI}/ta.key" || openvpn --genkey --secret "${EASYRSA_PKI}/ta.key"

for client in ${CLIENTS}; do
    test -f "${EASYRSA_PKI}/issued/${client}.crt" || easyrsa build-client-full "${client}" nopass
done

for server in ${SERVERS}; do
    fqdn="${server}.${DOMAIN}"
    test -f "${EASYRSA_PKI}/issued/${fqdn}.crt" || easyrsa build-server-full "${fqdn}" nopass

    ovpn_genconfig -u "udp://${fqdn}:${PORT}" -z -C 'AES-256-CBC'
    ovpn_copy_server_files "servers/${server}"

    for client in ${CLIENTS}; do
        mkdir -p "clients/${client}"
        ovpn_getclient "${client}" > "clients/${client}/${server}.${client}.ovpn"
    done

    rm -f ovpn_env.sh openvpn.conf
done
