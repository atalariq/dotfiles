# Agentic & Multi-Agent Reference

> Load ini hanya kalau task involve orchestration atau lo lagi belajar multi-agent setup.

---

## Mental Model: Agent Roles

Setiap agent di setup ini punya satu tanggung jawab:

```
User Request
    │
    ▼
[planner]          ← Thinks. Produces PLAN. Cannot edit files.
    │
    ▼ PLAN
[executor]         ← Acts. Executes stage by stage. Uses tools.
    │
    ▼ Output
[reviewer]         ← Judges. Read-only. Reports findings.
    │
    ▼ Findings
[quick / db]       ← Specialized. Called for specific sub-tasks.
```

---

## How to Run a Multi-Step Task

### Pattern 1: Plan-then-Execute (manual)
```
# Step 1: Get plan
/agent planner
Build a REST API for user authentication with JWT in Go

# Step 2: Execute stage by stage
/agent executor
Execute Stage 1 from the plan: [paste stage]

# Step 3: Review
/agent reviewer
Review the auth middleware in internal/middleware/auth.go
```

### Pattern 2: One-shot agentic (for clear tasks)
```
/agent executor
Implement JWT auth middleware for Go Gin. Requirements:
- Validate Bearer token from Authorization header
- Inject user claims into context
- Return 401 with structured error on failure
- Write table-driven tests
```

---

## Agent Routing Guide

| Task Type | Agent | Why |
|---|---|---|
| Architecture decision | planner | Needs depth, no side effects |
| PRD / specs | planner | Structured output only |
| Multi-file feature | executor | Kimi K2.6 sustained agentic |
| Single bug fix | quick | Fast, minimal context |
| Code review | reviewer | Read-only, structured output |
| DB schema / query | db | PostgreSQL-specialized prompt |
| Long refactor | executor | 4000+ tool calls sustained |

---

## Common Patterns in Agentic TS/Go Projects

### Pattern: Worker Pool (Go)
```go
// Agent understands this pattern — reference it explicitly:
// "Use worker pool pattern with errgroup, max N concurrent workers"
```

### Pattern: Repository Pattern (Go + PostgreSQL)
```
// Mention explicitly: "Use repository pattern, inject db as interface"
// Agent will generate: UserRepository interface + PostgresUserRepository struct
```

### Pattern: Feature Modules (TypeScript)
```
// "Structure as feature module: types.ts, service.ts, repository.ts, routes.ts"
// Agent follows this without further instruction
```

---

## Debugging Agentic Tasks

Kalau agent stuck atau looping:
1. Stop dengan Ctrl+C
2. Check `.opencode/sessions/` untuk lihat apa yang terjadi
3. Restart dengan context yang lebih spesifik
4. Pecah task lebih kecil: "Only do X, not Y"

Kalau tool calls tidak berjalan:
- Check MCP server status: sequential-thinking dan postgres harus jalan
- Restart: `opencode` fresh session
- Verify permissions di config untuk direktori yang diakses
