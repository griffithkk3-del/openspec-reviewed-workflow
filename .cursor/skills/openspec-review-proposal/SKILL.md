---
name: openspec-review-proposal
description: Review a proposal with evidence-driven codebase investigation before advancing to specs/design.
license: MIT
compatibility: Requires OpenSpec CLI and the spec-driven-reviewed schema.
metadata:
  author: OpenSpec Reviewed Workflow
  version: "1.0"
---

Review a proposal by investigating the codebase and producing an evidence-driven review report.

**Input**: A change name with a completed `proposal` artifact and a `review` artifact in `ready` state.

**IMPORTANT**: This skill is intended to be used when the `review` artifact is the next ready artifact in a spec-driven-reviewed workflow.

## Steps

1. **Read the proposal**

   Read `proposal.md` from the change directory. Extract the key claims:
   - What problem does it solve?
   - What files/functions does it target?
   - What new abstractions or capabilities does it introduce?
   - What existing mechanisms does it reference?

2. **Execute codebase investigation (MANDATORY)**

   You **MUST** perform at least 2 search operations before writing the review.

   **Search strategy:**
   - Search for functions/classes mentioned in the proposal's Impact section
   - Search for similar patterns or utilities that could be reused
   - Read the actual target files to verify the proposal's claims
   - Search for existing mechanisms that overlap with the proposed changes

   **Evidence recording rules:**
   - For each search, record the keyword/pattern and the results
   - If you find reusable code, include the file path and a code snippet
   - If you find conflicts, include the file path and describe the conflict
   - If you claim no reusable code exists, you **MUST** list all search keywords you attempted

3. **Evaluate alternatives**

   Based on your investigation, consider:
   - Can the problem be solved by adjusting existing parameters or config?
   - Can the problem be solved by reusing an existing mechanism?
   - Is there a simpler approach the proposal missed?
   - Build a comparison table with at least the proposed approach and one alternative

4. **Perform feasibility checks**

   Verify:
   - **Dependency Check**: All referenced modules/APIs exist in the codebase
   - **Performance Impact**: No hot-path deep copy, no unbounded dict/list growth, no unnecessary async overhead
   - **Testability**: The proposed change can be validated clearly

5. **Produce verdict**

   Rate as exactly one of:
   - **OPTIMAL**: The proposal is the best approach. No material improvements needed. Proceed to specs/design.
   - **IMPROVABLE**: The direction is correct but specific improvements are needed. List exact edits to `proposal.md` in Action Items.
   - **RETHINK**: The proposal has fundamental issues (wrong assumptions, missed existing solution, architectural mismatch). Provide a concrete alternative approach in the Alternative Analysis section grounded in codebase evidence.

6. **Write the review artifact**

   Get the review template:
   ```bash
   openspec instructions review --change "<name>" --json
   ```

   Write to the `outputPath` specified in the instructions, filling all 6 sections of the `review.md` template.

7. **Show status and next steps**

   ```bash
   openspec status --change "<name>"
   ```

   - If OPTIMAL: "Review passed. Specs and design are now unlocked. Continue to create the next artifact."
   - If IMPROVABLE: "Review found improvements. Please update `proposal.md` with the listed changes, then re-run review."
   - If RETHINK: "Review recommends rethinking the approach. See Alternative Analysis for a suggested direction."

## Prompt Guidelines for AI

When filling the `2. Research & Evidence` section:
- You **MUST** show at least two search results
- If you claim there is no reusable code, you **MUST** list the exact keywords you searched for
- You **MUST** include at least one code snippet in the Code Evidence section

When giving a `RETHINK` verdict:
- You **MUST** provide a concrete replacement approach in `3. Alternative Analysis`
- The alternative **MUST** be grounded in code you actually found during investigation, not theory

When giving an `IMPROVABLE` verdict:
- Action Items **MUST** specify which section of `proposal.md` to edit and what to change
- Changes should be specific enough to execute without further clarification

## Guardrails

- NEVER skip the codebase investigation step
- NEVER write a verdict without evidence to support it
- NEVER give OPTIMAL just to speed things along
- NEVER give RETHINK without a concrete alternative
- DO reference the target project's active conventions and rules when evaluating the proposal
- DO check whether the proposal reuses existing code and avoids unnecessary abstraction
