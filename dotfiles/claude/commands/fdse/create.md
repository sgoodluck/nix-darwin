---
name: fdse:create
description: Create a new ION ticket
argument-hint: "<title>, bucket: <work-type> [, refs: JOB-XXX] [, project: <name>]"
allowed-tools:
  - mcp
---

<objective>
Create a new ticket in FR Linear with proper labels and optional cross-references.
</objective>

<process>

1. Parse the argument for: title, bucket (required), refs (optional Joby ticket IDs), project (optional)
2. If bucket is missing, ask immediately
3. Create the ticket in linear-fr:
   - team: Engineering (ION)
   - title: as provided
   - labels: the fdse-work-type label matching the bucket
   - assignee: seth.martin@firstresonance.io
   - status: Todo
   - project: if specified, attach to the named project
4. **Auto-apply customer label**
   - If any of these are true, add the `customer.joby-aviation` label (id: e7b104df-12db-41d2-9a82-7cbdd7781ed4):
     - The title or description mentions "joby" (case insensitive)
     - Joby ticket refs are included (JOB-*, FR-*, FACT-*)
     - The ticket is in a project prefixed with "(Joby)"
     - The user explicitly says it's Joby work
   - If none of these signals are present AND it's not clearly internal FR work, ask: "Is this Joby work?"
   - For clearly internal work (mentions "internal", "FR only", etc.), skip the customer label.
5. If refs provided, add them as links in the ticket description:
   "References: JOB-301, JOB-302, JOB-303"
6. Confirm: "Created ION-XXXX: <title> [<bucket>]"
7. Ask: "Start timer on this?"

</process>
