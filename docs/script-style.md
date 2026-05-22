# Script Style Guide

Conventions for every script under `~/.local/script/`. The goal: every script is
**self-contained and copy-pasteable** — no shared library dependency — but
follows the same predictable shape so readers know what to expect.

## Minimum bar

Every **new** script must include:

1. `set -euo pipefail` immediately after the shebang
2. A `-h`/`--help` flag that prints usage and exits 0
3. A `trap cleanup EXIT INT TERM` if the script creates temp files

Existing scripts are grandfathered. Do not refactor them unless you are already
changing their behaviour.

## Shebang

Prefer `#!/usr/bin/env bash` for portability. Use `#!/bin/sh` only if the script
is strictly POSIX-compatible (no arrays, no `local`, no `readonly`).

## Template

Start every new script by copying `template.sh` and filling in the sections:

- `VERSION` — bump on each change
- `usage()` — describe the interface, options, examples
- `cleanup()` — tear down temp files and child processes
- `parse_args()` — standard `while`/`case` over `$@`
- `main()` — top-level entry point, calls `parse_args` then does the work

## Logging

Use the four standard functions from the template:

| Function | Target | Purpose                        |
| -------- | ------ | ------------------------------ |
| `info`     | stdout | Progress messages              |
| `ok`       | stdout | Confirmation (indented)        |
| `warn`     | stderr | Non-fatal problems             |
| `err`      | stderr | Fatal errors (follow with exit) |

## Error handling

- `set -euo pipefail` catches most failures. Check command success explicitly
  only when you want a custom message:

  ```bash
  if ! some_command; then
      err "some_command failed"
      exit 1
  fi
  ```

- Use `cleanup()` + `trap` for temp file removal, not scattered `rm` calls.

## Argument parsing

Use `while`/`case` over `$@`, not manual `$1`/`$2`. This gives free `--` support
and predictable ordering independence:

```bash
while [[ ${#} -gt 0 ]]; do
    case "${1}" in
        -h|--help) usage 0 ;;
        -f|--file) file="${2}"; shift ;;
        --)        shift; break ;;
        -*)        err "Unknown option: ${1}"; usage 1 ;;
        *)         break ;;
    esac
    shift
done
```

## Copy-pasteability

Scripts must remain independently copy-pasteable. This means:

- **No sourcing** of shared libraries (`lib.sh`, helpers, etc.)
- Dependencies MUST be listed in a comment at the top:

  ```bash
  # Depends: jq, fzf, cliphist
  ```

- The `info`/`ok`/`warn`/`err` functions are the one replicated pattern — they
  are short enough (one line each) that pasting them is trivial.

## Checklist

Before committing a new script:

- [ ] `set -euo pipefail` on line 2
- [ ] `-h`/`--help` works
- [ ] `-v`/`--version` works
- [ ] Dependencies listed in header comment
- [ ] `trap cleanup EXIT INT TERM` (if temp files or children exist)
- [ ] `shellcheck` passes without errors
- [ ] Script is self-contained (no sourcing of other repo scripts)
