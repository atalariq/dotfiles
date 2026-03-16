---
description: Learn
agent: talk 
---

Analyze the current session and extract any patterns worth saving as skills.

## What to Extract

Look for:

1. **Error Resolution Patterns**
   - What error occurred?
   - What was the root cause?
   - What fixed it?
   - Is this reusable for similar errors?

2. **Debugging Techniques**
   - Non-obvious debugging steps
   - Tool combinations that worked
   - Diagnostic patterns

3. **Workarounds**
   - Library quirks
   - API limitations
   - Version-specific fixes

4. **Project-Specific Patterns**
   - Codebase conventions discovered
   - Architecture decisions made
   - Integration patterns

## Output Format

Present findings in this structure:

```markdown
## Skill Name

**What**: Brief description of the pattern/problem being solved

**Why**: Why this pattern is valuable (when to use it)

**How**: Step-by-step explanation of the technique

**Examples**:
1. Example scenario where this applies
2. Another concrete example
```

## Verification Checklist

Before proposing a skill, confirm:
- [ ] Solves a real, recurring problem
- [ ] Not a one-time fix or typo
- [ ] Saves time in future sessions
- [ ] Can be applied to new contexts

## Process

1. Review the session for extractable patterns
2. Identify the most valuable/reusable insight
3. Draft the skill file
4. Ask user to confirm before saving
5. Save to `~/.claude/skills/learned/`

## Notes

- Don't extract trivial fixes (typos, simple syntax errors)
- Don't extract one-time issues (specific API outages, etc.)
- Focus on patterns that will save time in future sessions
- Keep skills focused - one pattern per skill
