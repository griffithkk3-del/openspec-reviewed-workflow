# openspec-reviewed-workflow

An evidence-driven review workflow for [OpenSpec](https://github.com/Fission-AI/OpenSpec) that adds a **review gate** between proposal and specs/design.

> **This is a workflow extension, not a standalone tool.** You need [OpenSpec CLI](https://github.com/Fission-AI/OpenSpec) installed first.

## Why

When AI writes a proposal, it relies on a snapshot understanding of the codebase — it may miss existing utilities, overlook simpler approaches, or introduce unnecessary abstractions. These mistakes compound through specs, design, and tasks.

This workflow inserts a **mandatory review step** that forces the AI to:

1. Search the actual codebase for existing solutions
2. Compare at least 2 alternative approaches
3. Verify feasibility (dependencies, performance, testability)
4. Produce a structured verdict: **OPTIMAL** / **IMPROVABLE** / **RETHINK**

Specs and design are blocked until the review passes.

## Workflow

```
proposal → review → specs → design → tasks → apply
              ↑
        NEW: evidence-driven
        codebase investigation
```

| Artifact | Purpose |
|---|---|
| `proposal.md` | Why this change is needed |
| `review.md` | Codebase investigation + verdict (NEW) |
| `specs/**/*.md` | What the system should do |
| `design.md` | How to implement it |
| `tasks.md` | Trackable implementation checklist |

## Review Verdicts

| Verdict | Meaning | Next Step |
|---|---|---|
| **OPTIMAL** | Best approach found | Proceed to specs/design |
| **IMPROVABLE** | Direction correct, needs tweaks | Update proposal, then proceed |
| **RETHINK** | Fundamental issues found | Rework proposal with alternative |

## Quick Start

### 1. Install OpenSpec CLI (required)

```bash
npm install -g @fission-ai/openspec
```

> See [OpenSpec GitHub](https://github.com/Fission-AI/OpenSpec) for more details.

### 2. Initialize OpenSpec in your project

```bash
cd /path/to/your-project
openspec init
```

### 3. Install this review workflow

```bash
git clone https://github.com/griffithkk3-del/openspec-reviewed-workflow.git
cd openspec-reviewed-workflow
./scripts/install.sh /path/to/your-project
```

This copies the schema, templates, and Cursor skill into your project, and sets `spec-driven-reviewed` as the default schema.

### Manual Install (alternative)

If you prefer to copy manually:

1. Copy `openspec/schemas/spec-driven-reviewed/` to your project's `openspec/schemas/`
2. Copy `.cursor/skills/openspec-review-proposal/` to your project's `.cursor/skills/`
3. Set `schema: spec-driven-reviewed` in your project's `openspec/config.yaml`

### 4. Use

```bash
# Create a new change
openspec new my-feature

# Step through artifacts (proposal → review → specs → ...)
openspec continue my-feature
```

The review step will automatically trigger when the proposal is complete.

## What Gets Installed

```
your-project/
├── openspec/
│   ├── config.yaml                          # updated: schema → spec-driven-reviewed
│   └── schemas/
│       └── spec-driven-reviewed/
│           ├── schema.yaml                  # workflow definition
│           └── templates/
│               ├── proposal.md
│               ├── review.md                # NEW: review report template
│               ├── design.md
│               ├── spec.md
│               └── tasks.md
└── .cursor/
    └── skills/
        └── openspec-review-proposal/
            └── SKILL.md                     # Cursor AI skill for review
```

## Cursor Integration

If you use [Cursor](https://cursor.com), the included skill (`openspec-review-proposal`) teaches the AI how to perform the review step:

- Executes at least 2 codebase searches before writing a verdict
- Records evidence (code snippets, search keywords)
- Builds an alternative comparison table
- Follows strict guardrails (no rubber-stamp OPTIMALs, no evidence-free verdicts)

The skill is automatically picked up by Cursor when placed in `.cursor/skills/`.

## Without Cursor

The schema works with any AI tool that supports OpenSpec. The `review` artifact's instruction in `schema.yaml` contains the full review process — any AI agent can follow it. The Cursor skill is an optional enhancement.

## License

MIT
