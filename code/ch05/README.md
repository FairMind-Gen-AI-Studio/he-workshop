# Chapter 5 companion: the boundaries, as files

The execution boundaries Chapter 5 argues for, as configuration you can copy
into a repository and run. Nothing here is a maintained base image; take the
shape and adapt the lists.

| File | What it is |
|---|---|
| `.claude/settings.json` | Project settings: the ask rules for consequential commands, the deny rules for network tools and force-push, the sandbox with its egress allowlist and the MCP server approvals |
| `user-floor.settings.json` | The personal safety floor. Copy into `~/.claude/settings.json`: deny rules for credential paths that no project can reopen, plus credential protection inside the sandbox (a denied AWS secret, a masked GitHub token) |
| `.mcp.json` | A project-scoped server declaration, with one server the settings approve and one they reject |
| `.devcontainer/devcontainer.json` | The container for unattended work: non-root user, the two capabilities the firewall needs, no host secrets mounted, telemetry off |
| `.devcontainer/Dockerfile` | Builds the image: iptables and ipset, a non-root `agent` user whose sudo reaches the firewall script and nothing else, the CLI pinned by build argument |
| `.devcontainer/allowed-domains.txt` | The egress allowlist, one domain per line with the reason beside it |
| `.devcontainer/init-firewall.sh` | Default-deny egress: resolves the allowlist into an ipset, rejects everything else and refuses to finish unless an unlisted host fails and the remote answers |

To try the container: open the folder in an editor that supports dev
containers, or run `devcontainer up --workspace-folder .` with the reference
CLI. The firewall runs on start and prints `egress policy in force`; if it
prints an error instead, the container is up but the agent should not be.

`user-floor.settings.json` masks `GH_TOKEN` for `api.github.com` only. Masking
requires the sandbox proxy to terminate TLS, which the file enables, and is
honored from user or managed settings only, which is why it is not in the
project file.

Checked 2026-08-23 on Docker 28.3 (macOS): the image builds, the firewall
script reports `egress policy in force`, `https://example.com` is refused
and `https://api.github.com/zen` answers 200 from inside the container.
