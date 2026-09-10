# Chapter 4 companion: the Fairmind Studio contract

The repository contract assembled through Chapter 4, as runnable files.
Copy `CLAUDE.md` and the `.claude/` directory into a repository to try them;
`services/api/CLAUDE.md` shows the nested package layer.

| File | What it is |
|---|---|
| `CLAUDE.md` | The root contract the chapter builds, definition of done included |
| `.claude/settings.json` | Shared settings: the deny rules, the ask rule and the two hooks |
| `.claude/rules/testing.md` | Path-scoped rule; loads when a matching file is read |
| `.claude/rules/docs.md` | Path-scoped rule for the `.mdx` documentation pages |
| `.claude/rules/kubernetes.md` | Binds cluster paths to the `/cluster-change` skill |
| `.claude/skills/local-testing/SKILL.md` | The skill the contract points at for local testing |
| `.claude/skills/verify-done/SKILL.md` | Runs the definition of done before any work is declared finished |
| `.claude/skills/cluster-change/SKILL.md` | How cluster work is done (the Chapter 3 skill, listed in Chapter 4's worked examples) |
| `prompts/audit-claude-md.txt` | Prompt to paste, not a script: audit an existing CLAUDE.md line by line |
| `prompts/audit-memory.txt` | Prompt to paste, not a script: audit the agent's auto-memory |
| `scripts/update-clickup-start.sh` | Called by the `UserPromptSubmit` hook |
| `scripts/update-clickup-end.sh` | Called by the `Stop` hook |
| `services/api/CLAUDE.md` | The nested contract owned by the API team |

The hook scripts are safe to run as-is: without `CLICKUP_TOKEN` and
`CLICKUP_TASK_ID` in the environment they exit quietly, so a session with no
ticket attached is never blocked.
