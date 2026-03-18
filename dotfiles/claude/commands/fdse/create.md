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
4. If refs provided, add them as links in the ticket description:
   "References: JOB-301, JOB-302, JOB-303"
5. Confirm: "Created ION-XXXX: <title> [<bucket>]"
6. Ask: "Start timer on this?"

</process>
