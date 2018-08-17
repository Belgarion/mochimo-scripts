#!/bin/bash
NETDEV=$(ip route get 8.8.8.8 | sed -n 's/.*dev \([A-Za-z0-9-]*\).*/\1/p')
iptables -t nat -A POSTROUTING -s 10.200.1.0/24 -o $NETDEV -j MASQUERADE
