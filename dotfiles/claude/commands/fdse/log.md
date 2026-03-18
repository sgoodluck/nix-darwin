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
4. Call clockify `log_time` with:
   - description: "ION-XXXX: <ticket title or provided description>"
   - duration: as parsed
   - project: the bucket label
5. Confirm: "Logged <duration> to ION-XXXX [<bucket>]"

</process>
