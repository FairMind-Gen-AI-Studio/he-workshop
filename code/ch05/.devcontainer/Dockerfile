FROM node:22-bookworm

# The firewall needs iptables and ipset; dig resolves the allowlist; git and
# gh are what the agent uses to reach the one remote it is allowed to see.
RUN apt-get update && apt-get install -y --no-install-recommends \
      iptables ipset dnsutils curl ca-certificates git sudo gh \
    && rm -rf /var/lib/apt/lists/*

# A non-root user: Claude Code refuses --dangerously-skip-permissions as root.
# sudo is granted for the firewall script only, and for nothing else.
ARG USERNAME=agent
RUN useradd -m -s /bin/bash $USERNAME \
    && echo "$USERNAME ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh" \
       > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Pin the CLI version in CI builds: replace "latest" with the release you tested.
ARG CLAUDE_CODE_VERSION=latest
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}

COPY init-firewall.sh /usr/local/bin/init-firewall.sh
COPY allowed-domains.txt /etc/agent/allowed-domains.txt
RUN chmod 755 /usr/local/bin/init-firewall.sh

USER $USERNAME
WORKDIR /workspace
