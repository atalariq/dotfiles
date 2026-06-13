# Coding Rules & Conventions

## Critical: How to Load These Rules
When you encounter a file reference like `@path/to/file.md`, use your Read tool
to load it on a need-to-know basis only. Do NOT preemptively load all references.

---

## General

- Read existing code before editing. Match the style already in the file.
- Prefer minimal diffs. Don't refactor unrelated code in the same PR.
- Never hardcode secrets, credentials, or environment-specific values.
- Confirm before destructive operations (drop table, delete files, force push).
- When ambiguous: state your interpretation, then proceed.

---

## TypeScript

- Strict mode always: `"strict": true` in tsconfig.
- Prefer `type` over `interface` unless declaration merging is needed.
- No `any`. Use `unknown` + type narrowing, or proper generics.
- Async: always `async/await`, never raw `.then()` chains.
- Error handling: typed errors, not `catch (e: any)`.
- Imports: use path aliases (`@/...`), not deep relative paths (`../../../`).
- Testing: Vitest for unit, prefer co-located `*.test.ts` files.
- For API routes: validate input with Zod before processing.

## Go

- Follow standard Go conventions: `gofmt`, `golint`, `go vet` must pass.
- Error handling: always handle errors explicitly, no `_` for err unless justified.
- Naming: short variable names in small scopes, descriptive in package scope.
- Interfaces: define at point of use (consumer side), not at implementation.
- Context: always propagate `context.Context` as first argument.
- No global state. Use dependency injection.
- Testing: table-driven tests, `testify` for assertions.
- For HTTP handlers: always set timeouts, handle cancellation.

---

## Git Workflow (mimicking team/corp conventions)

- Branch naming: `feat/`, `fix/`, `chore/`, `docs/` prefixes.
- Commit messages: conventional commits format.
  - `feat: add user auth middleware`
  - `fix: resolve race condition in worker pool`
  - `chore: update dependencies`
- Never commit directly to `main`. Always PR.
- PR description: what changed, why, how to test.
- Keep commits atomic — one logical change per commit.

---

## PostgreSQL

- Use parameterized queries always. No string interpolation in SQL.
- Migrations: always reversible (up + down). Use sequential numbering.
- Indexes: add for all foreign keys and frequent query predicates.
- Transactions: explicit for multi-statement operations.
- Naming: snake_case for tables/columns, plural table names.

---

## Docker

- Multi-stage builds for production images.
- Non-root user in containers.
- `.dockerignore` must exclude: node_modules, .git, .env, build artifacts.
- Health checks in Dockerfile for long-running services.
- Never put secrets in Dockerfile or docker-compose.yml — use env files or secrets.

---

## Agentic / Multi-Agent Tasks

For complex tasks requiring orchestration:
- Reference planner agent first: `/agent planner`
- Get explicit plan with stages before executor starts
- Each stage must have: objective, inputs, outputs, success criteria
- Executor stops at stage boundaries and reports status
- Reviewer checks output before merging

For multi-agent learning resources:
@.opencode/AGENTIC.md
