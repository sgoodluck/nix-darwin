---
name: fdse:log
description: Backfill a time entry
argument-hint: "<duration> <ION-XXXX> [description]"
allowed-tools:
  - mcp
---

<objective>
Create a completed time entry for work that wasn't tracked in real-time.
</objective>

<process>

1. Parse: duration (e.g., "1h30m", "2h", "45m"), ticket ID, optional description
2. Fetch the ticket from linear-fr to get title and fdse-work-type label
3. If no fdse-work-type label, ask the user for the bucket
4. **Resolve Clockify project (client-aware)**
   - If ticket has `customer.joby-aviation` label → clientId = `68e69bbbd1605947f26e5690` (Joby Aero)
   - Otherwise → clientId = `68e7e0a8631c3b32395aba2f` (First Resonance)
   - Call `get_projects` and find a project matching the bucket name AND clientId
   - If no match, create the project with `create_project(name=bucket, clientId=clientId)`
5. Call clockify `log_time` with:
   - description: "ION-XXXX: <ticket title or provided description>"
   - duration: as parsed
   - projectId: resolved project
6. Confirm: "Logged <duration> to ION-XXXX [<bucket>, <client>]"

</process>
