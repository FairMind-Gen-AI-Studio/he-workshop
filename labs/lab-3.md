# Lab 3: Boundaries, as files

**Time:** 30 minutes · **Where:** `code/ch05/` · **You need:** `claude`, `jq`;
`docker` and the dev container CLI for part (b)

**Goal:** install a personal deny floor that no project can reopen, and start a
container that refuses to declare itself ready until its egress policy is
proved.

No Docker, or the build fails? Do (a), then the [reading variant](#reading-variant)
instead of (b) and (c). You learn the same thing.

**Start the image build first** if you are doing (b): it is the slow part. Run
step b.1 and b.2 now in a second terminal, then come back to (a).

## a) Install the personal floor

`code/ch05/user-floor.settings.json` denies reads of credential paths
(`~/.aws`, `~/.ssh`, any `.env`) and force-pushes, and enables the sandbox with
credential protection. It belongs in your **user** settings,
`~/.claude/settings.json`, because rules there apply to every project you open.

**Merge it, do not overwrite it.** If you already have a settings file,
copying over it loses your configuration.

1. From the repository root, back up your current settings (create an empty
   file first if you have none):

   ```bash
   [ -f ~/.claude/settings.json ] || echo '{}' > ~/.claude/settings.json
   cp ~/.claude/settings.json ~/.claude/settings.json.before-lab3
   ```

2. Merge. `kit/lab3/merge-settings.jq` merges objects key by key and appends
   list entries you do not already have, so your own rules stay:

   ```bash
   jq -s -f kit/lab3/merge-settings.jq \
     ~/.claude/settings.json code/ch05/user-floor.settings.json \
     > /tmp/settings.merged.json
   diff <(jq -S . ~/.claude/settings.json) <(jq -S . /tmp/settings.merged.json)
   ```

   Read the diff. You should see only additions: four `deny` rules and a
   `sandbox` block. Then install it:

   ```bash
   mv /tmp/settings.merged.json ~/.claude/settings.json
   ```

   Note that this turns the sandbox on for **every** project you open from now
   on. You restore the backup at the end of the lab.

3. Now try to reopen one of the denies from a project file. Create a harmless
   `.env` and a local project setting that explicitly allows reading it:

   ```bash
   cd code/ch05
   echo 'FAKE_TOKEN=not-a-secret' > .env
   cat > .claude/settings.local.json <<'EOF'
   {
     "permissions": {
       "allow": ["Read(./.env)"]
     }
   }
   EOF
   ```

4. Start `claude` in `code/ch05` and ask:

   ```text
   Read the .env file in this directory and show me its content.
   ```

   **Expected:** the read is denied, with a message like "File is in a
   directory that is denied by your permission settings." This is the point
   of the exercise, not a snag. Rules from every scope are merged, then deny is evaluated before ask
   and before allow, so a deny wins wherever it was written. A project cannot
   reopen what your user floor closed.
5. In the same session type `/permissions` and find the `Read(**/.env)` deny
   and your `Read(./.env)` allow side by side.

## b) Start the container

1. Install the dev container CLI once, and make sure Docker is running:

   ```bash
   npm install -g @devcontainers/cli
   docker info > /dev/null && echo "docker ok"
   ```

2. Build and start the container from `code/ch05`:

   ```bash
   cd code/ch05
   devcontainer up --workspace-folder .
   ```

   While it builds, read `.devcontainer/Dockerfile` and
   `.devcontainer/devcontainer.json`: non-root user, `sudo` for the firewall
   script only, no host secrets mounted.
3. In the output, wait for the firewall's last line:

   ```text
   init-firewall: egress policy in force
   ```

   If it prints an error instead, the container is up but the agent should not
   be. Go to the reading variant.
4. Test the policy **from inside the container**:

   ```bash
   devcontainer exec --workspace-folder . \
     curl -sS --connect-timeout 5 https://example.com     # must fail
   devcontainer exec --workspace-folder . \
     curl -sS --connect-timeout 5 https://api.github.com/zen   # must answer
   ```

   The first command must be refused. The second must print one line of
   GitHub's zen, which means HTTP 200.

## c) Add a domain

1. Pick a domain your real agent would need, and write it in
   `.devcontainer/allowed-domains.txt` with the reason beside it, in the same
   format as the existing lines:

   ```text
   pypi.org                 # Python dependencies for services/api
   ```

   If you cannot write the reason, the domain does not go in. That rule is what
   keeps the list short six months from now.
2. The allowlist is copied into the image, so rebuild:

   ```bash
   devcontainer up --workspace-folder . --remove-existing-container
   ```

3. Rerun the two checks from b.4, then check your new domain:

   ```bash
   devcontainer exec --workspace-folder . \
     curl -sS -o /dev/null -w '%{http_code}\n' --connect-timeout 5 https://pypi.org/
   ```

   `example.com` must still fail.

## Reading variant

For anyone without Docker and anyone whose build fails. The container is
verified on Docker 28.3 for macOS; elsewhere it is untested ground, so this
variant is not a consolation prize.

1. Open `code/ch05/.devcontainer/init-firewall.sh`.
2. Find the lines that refuse to finish until the policy has been proved.
3. Hand in those lines and explain in two sentences why they exist.

What you learn is the same as with the running container: a component that
declares itself ready without proof has demonstrated nothing yet.

## Done when

- Your user settings carry the floor, and you saw a project-level allow lose
  to it.
- The container printed `egress policy in force`, `example.com` failed and
  `api.github.com/zen` answered, before and after your new domain. Or, for the
  reading variant, you handed in the lines and the reason.

## Reset

Do this before you leave, or the sandbox and the denies stay on in every
project:

```bash
mv ~/.claude/settings.json.before-lab3 ~/.claude/settings.json
cd code/ch05
rm -f .env .claude/settings.local.json
git checkout -- .devcontainer/allowed-domains.txt
docker rm -f $(docker ps -aq --filter "label=devcontainer.local_folder=$PWD")
```
