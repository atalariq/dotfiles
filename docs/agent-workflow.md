# Native multi-agent workflow

Use one agent for routine tasks. For independent parallel tasks, Hermes is the
coordinator this owner reaches for by default, but it is not the only one: a
codex, claude or opencode session coordinates its own batch just as well, so the
choice stays with whoever opens it. Beads
is the shared task queue and handoff; it does not discover running agents or lock
source files. No background dispatcher or additional agent service is required.

## Start and assign

When parallel work is justified, start the coordinator (Hermes by default) in
the main checkout and give it the desired outcome or Beads issue.
A request to implement authorizes routine project read, edit, test, build, and
delegation. The coordinator continues independent work in that batch and collects
protected operations for review at the end.

Before assigning work, the coordinator reads `git status --short`,
`br coordination status --json`, and `br ready --json`. Inspect existing claims;
claim age alone is not permission to take another worker's task.

For each task, record a compact Beads comment containing:

- Unique tool/session actor and issue ID.
- Worktree path and exact allowed write paths.
- Starting revision and inherited uncommitted source changes, if any.
- Acceptance checks, worker process/session ID, and next action.

Claim atomically with `br update ISSUE --claim --actor TOOL-SESSION`. Run every
worktree Beads command against the main queue, for example
`br --db "$DOTFILES_BEADS_DIR/beads.db" show ISSUE`. Keep this override scoped to
this repository, rather than setting `BEADS_DIR` globally for unrelated projects.

Use a separate Git worktree for each implementation scope. Plain
`git worktree add` is the supported path. Existing uncommitted changes need an explicitly recorded baseline:
apply the reviewed source diff and copy only named new source files. Do not copy
credentials, runtime state, caches, or a second Beads database. Compare the worker's
result against that inherited baseline, not only against HEAD.
Before a local worker commit, stage only its assigned changes; inherited changes
are not part of the worker commit. Keep signing enabled. If signing requires
unavailable authentication, submit the diff instead of bypassing signing.

Claims reserve issues, not files. The coordinator admits only disjoint write
scopes concurrently. It owns shared integration files, host selections, and final
documentation. Workers report conflicts instead of editing another scope.

## Run and control workers

Allow at most **two external workers** at once; fewer is appropriate when tasks
overlap or coordination costs outweigh concurrency. Codex and Claude are trusted
implementers for this project. OpenCode and Hermes submit draft changes for
trusted review. Trust covers the evaluated tool/model configuration;
changing a model or provider requires reassessment. Native
subagents use their parent tool's account limits; they do not increase the Codex
quota. Workers do not recursively launch more workers unless assigned to do so.

Hermes launches the native CLI through its terminal tool with the assigned
worktree as `workdir`, `background=true`, `notify_on_complete=true`, and
`persist_on_release=true`. Wrap each command in
`timeout --signal=TERM --kill-after=10s 30m` and retain the returned process
`session_id`, OS PID and deadline. The two-worker cap is a coordinator admission rule;
`delegation.max_concurrent_children` only limits Hermes children, not external
CLI processes.

The native headless interfaces are `codex exec`, `opencode2 run --standalone`,
and `claude -p`. Pass the task through stdin or a task file, use each CLI's JSON
output, and record its native session/conversation ID for resume. Use the current
installed CLI help for arguments. Give Codex scoped access to the main queue
with `--add-dir "$DOTFILES_BEADS_DIR"`; OpenCode's generated policy
includes that directory. If native project trust is required, trust only the
assigned owner-authorized worktree, never the entire home directory. Worker HOME stays unchanged so the application
can use its existing authentication; credentials never enter the prompt, command
line, worktree, or Beads artifacts.

For a trusted Codex worker that needs a local commit, use a detached worktree and
a native session permission overlay. Removing a command prompt does not make the
linked Git metadata writable. Resolve the exact assigned Git directory; wildcard
grants do not override the pinned sandbox's linked-worktree protection. Keep the
common Git directory read-only and grant only the assigned metadata and shared
object database. Named inheritance retains the project's credential denies:

```sh
assigned_worktree=/absolute/path/to/assigned-worktree
assigned_gitdir=$(git -C "$assigned_worktree" rev-parse --absolute-git-dir)
assigned_common=$(git -C "$assigned_worktree" rev-parse --path-format=absolute --git-common-dir)
assigned_fs=$(jq -nr --arg common "$assigned_common" --arg gitdir "$assigned_gitdir" \
  --arg objects "$assigned_common/objects" \
  '"{" + ($common|tojson) + "=\"read\"," + ($gitdir|tojson) + "=\"write\"," + ($objects|tojson) + "=\"write\"}"')
codex exec -C "$assigned_worktree" --json \
  -c 'permissions.assigned.extends="dotfiles-workspace"' \
  -c "permissions.assigned.filesystem=$assigned_fs" \
  -c 'default_permissions="assigned"' - < task.txt
```

Use this only after trusting that assigned worktree's project configuration.
Detached commits leave branch integration to the owner. Check the resulting HEAD
and diff; the pinned Git can emit a shared packed-refs lock warning even when the
detached commit succeeds. Preserve signing settings and return a diff when
signing authentication is unavailable. Do not broaden the whole common Git
directory to write merely to suppress a maintenance warning.

Use Hermes `process_manage` to poll, read bounded logs, wait, and kill the recorded
process. Persisted processes survive context compression; explicit `/stop` and
process termination still cancel them. The hard timeout bounds orphaned work if
the coordinator exits. Do not launch a detached Tmux process and assume Hermes
can still control its lifecycle. On resume, reconcile process handles and Beads
claims before launching replacements. After a full CLI restart, an old registry
handle may be unavailable: verify the recorded OS process identity and deadline
before deciding it stopped. Never launch a duplicate simply because a new
registry does not list the old job; the hard timeout still bounds that job.

Hermes `delegate_task` starts another Hermes agent; it does not select an external
Codex/OpenCode executable. `delegation.orchestrator_enabled` controls
whether those Hermes children can coordinate further; it does not disable the
parent's terminal-based coordination. External worker approvals are not forwarded
automatically to Hermes. Configure headless workers to stop and report protected
work rather than wait indefinitely for a hidden interactive prompt.

## Permissions and budgets

Routine project work should run without approval prompts. Keep protected
operations separate: privilege escalation, system activation, destructive
operations, publishing, and access to unselected private files.

Native permission settings improve command ergonomics; a shell running as the
host user is not automatically a filesystem sandbox. Do not claim a tool cannot
read outside the workspace unless its actual sandbox enforces that boundary.

On the pinned Hermes version, `approvals.deny` is an unconditional block. Removing
it does not add an approval prompt, and not every activation/publishing command
is detected as dangerous. Keep protected commands denied in Hermes and return
the exact reviewed owner-terminal command instead of inventing an `approvals.ask`
setting or enabling YOLO. Other tools use their supported native ask mechanisms.

DeepSeek direct is the default in fresh OpenCode/Hermes profiles; OpenRouter and
subscription providers are explicit alternatives. Provider routing is separate
from worker coordination: launching native CLIs does not require a local gateway.

Use existing accounts, model selections, and authorized budgets. Do not silently
switch providers when quota or auth fails. Record the failure, stop that worker,
and continue independent work with already available capacity. When the session's
budget ends, leave a resumable handoff instead of increasing it automatically.

## Review, integrate, and resume

Workers attach checks and unresolved findings to their issue, then mark it for
review. The coordinator reviews the change against its baseline and acceptance
criteria before integration. Trusted Codex/Claude workers may stage assigned
source and make signed local commits in their worktrees. Other workers submit
diffs. The owner controls main-checkout integration, its index, push, and
activation. An unavailable trusted reviewer leaves a draft; it does not promote
another worker to trusted status.

Only close an issue after all required acceptance checks pass. Use `deferred` plus
an explicit owner action when a device, account, activation, or physical test is
required. Successful evaluation, native fixture behavior, and real device
acceptance are distinct results.

Leave a short issue handoff: outcome, changed files, checks, remaining work, native
session/process identity, and cancellation state. Store detailed non-sensitive
receipts in the main checkout's ignored
`.beads/artifacts/ISSUE/SESSION/`. New work must not depend on a global external
handoff file. Keep historical checkpoints and backups intact.

Run `br sync --flush-only` explicitly when exporting queue changes; import reviewed
JSONL with `br sync --import-only`. Neither operation commits or pushes. Only the
owner coordinates commits containing shared queue changes.

Finish a batch with one concise owner report: completed tasks, verification,
remaining risks, and consolidated owner-only actions. Continue other ready,
non-overlapping slices without asking permission again for ordinary work.
