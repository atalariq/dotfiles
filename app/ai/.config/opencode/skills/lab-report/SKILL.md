---
name: generate-lab-report
description: Generate high-quality academic lab reports in Typst format following Indonesian academic writing conventions
version: 0.1
---

# Lab Report

## When to Use

...

## Core Principles

...

## Workflow Steps

### Phase 1: Context Gathering

1. Greet the user and request the following information:
   - Template variables (Name, NIM, Class, Course, Course Code, Lecturer, Meeting Number, Title)
   - Module/Instructions/Problem Statement
   - Source code of the student's work (and output/screenshots if available)
   - Additional reading materials (if any)

2. Wait for user input before proceeding to Phase 2.

### Phase 2: Planning & Verification

1. Extract "Tujuan Praktikum" (Lab Objectives) points from the problem statement
2. Create a list of terms/theories to cover in "Dasar Teori" (Theory)
3. List **real references** only (verify they exist - use real CS textbooks, official documentation, papers)
4. Present the draft plan to user and ask: *"Apakah rencana, outline, dan referensi ini sudah akurat dan sesuai sebelum saya mulai menulis kode Typst-nya?"*
5. Wait for user approval before proceeding to Phase 3.

### Phase 3: Execution

After user approval, generate:
- `main.typ` - The report content using the template
- `references.bib` - Bibliography in BibLaTeX format

## Format

Follow this report structure:

```
1. Tujuan Praktikum      -> Technical competency points
2. Dasar Teori           -> Fundamental concepts with @citekey citations
3. Hasil dan Pembahasan
   - Kode Program        -> (using #code())
   - Penjelasan          -> (Analysis of logic flow, complexity, theory connection)
4. Kesimpulan            -> Synthesis answering objectives
```

## Examples

See:
- ./template/main.typ
- ./template/references.bib

## Rules to Follow

### Critical Rules

1. **ACADEMIC WRITING**: Use formal Bahasa Indonesia, passive voice for procedures. NEVER use casual language ("saya/kita")
2. **ZERO HALLUCINATION**: NEVER assume steps not in the module/context
3. **VERIFIABLE REFERENCES**: NEVER create fake citations. Only use real books, documentation, papers
4. **AUDIENCE-CENTRIC**: Explain "Why" and "How" at architecture/memory level, not just syntax

### Error Prevention

- Always use `@citekey` format for citations
- Verify all references are real before including
- Use proper BibLaTeX entry types (@book, @article, @misc, etc.)

## Quick Reference

### Helper Functions Usage

#### Image
```typst
#img("path/to/image.png", alt: "Alt text for accessibility" caption: "Description")
```


#### Table
```typst
#tbl(
  caption: "Table title",
  columns: (auto, 1fr, 1fr),
  [Header 1], [Header 2], [Header 3],
  [Row 1 Col 1], [Row 1 Col 2], [Row 1 Col 3],
  ...
)
```

#### Code Block
```typst
#code(
  \`\`\`py
  def homeworkello():
      print("Hello")
  \`\`\`
)
```

---

Sources:
- [Typst Documentation](https://typst.app/docs/)
- [Typst Package Registry](https://typst.app/packages/)
- [BibLaTeX Reference](https://www.overleaf.com/learn/latex/Bibliography_management_with_biblatex)
