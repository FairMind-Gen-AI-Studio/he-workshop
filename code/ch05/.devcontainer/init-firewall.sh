#!/usr/bin/env bash
# Default-deny egress for an unattended agent container.
#
# Everything the container is allowed to reach is listed in
# /etc/agent/allowed-domains.txt. Each domain is resolved once at start and
# its addresses go into an ipset; every other outbound connection is
# rejected. Run as root from postStartCommand, after the network is up.
set -euo pipefail

ALLOWLIST=${ALLOWLIST:-/etc/agent/allowed-domains.txt}

# Start clean.
iptables -F
iptables -X
ipset destroy allowed 2>/dev/null || true
ipset create allowed hash:net

# Loopback and DNS have to work, or nothing else can be resolved.
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT

# Resolve every listed domain and record its addresses.
while read -r domain _; do
  [[ -z "$domain" || "$domain" == \#* ]] && continue
  ips=$(dig +short A "$domain" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' || true)
  if [[ -z "$ips" ]]; then
    echo "init-firewall: cannot resolve $domain" >&2
    exit 1
  fi
  for ip in $ips; do
    ipset add allowed "$ip" -exist
  done
  echo "init-firewall: allowed $domain"
done < "$ALLOWLIST"

# Let replies come back, let listed destinations out, drop the rest.
iptables -A INPUT  -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m set --match-set allowed dst -j ACCEPT
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP
iptables -A OUTPUT -j REJECT --reject-with icmp-admin-prohibited

# Prove the policy holds before the agent starts: an unlisted host must fail
# and the remote must still answer.
if curl --silent --connect-timeout 5 https://example.com >/dev/null; then
  echo "init-firewall: example.com is reachable, the policy is not in force" >&2
  exit 1
fi
if ! curl --silent --connect-timeout 5 https://api.github.com/zen >/dev/null; then
  echo "init-firewall: github.com is not reachable, the allowlist is wrong" >&2
  exit 1
fi
echo "init-firewall: egress policy in force"
