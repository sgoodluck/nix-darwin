---
name: fdse:start
description: Start a timer on a ticket or create a new ticket and start timing
argument-hint: "<ION-XXXX | description, bucket: work-type>"
allowed-tools:
  - mcp
---

<objective>
Start tracking time against work. Either reference an existing ION ticket or describe new work to create a ticket on the fly.
</objective>

<process>

1. **Check for running timer**
   - Call clockify `get_running_timer`
   - If a timer is running, stop it first via `stop_current_timer`
   - Report: "Stopped ION-XXXX (<elapsed>)"

2. **Parse the argument**
   - If it matches `ION-\d+`: existing ticket → step 3
   - Otherwise: new ticket description → step 4

3. **Existing ticket**
   - Fetch the ticket from linear-fr by identifier
   - Extract the `fdse-work-type` label → this is the Clockify project
   - If no `fdse-work-type` label exists, ask the user immediately. Do not guess.
   - Start a Clockify timer: description = "ION-XXXX: <ticket title>", project = the bucket label
   - Respond: "Timer started — ION-XXXX: <title> [<bucket>]"

4. **New ticket (ad-hoc or interrupt)**
   - The argument should include a description and `bucket:` qualifier
   - If bucket is missing or ambiguous, ask immediately
   - Create a new ticket in linear-fr:
     - team: Engineering (ION)
     - title: the description (prefix with client name if clearly client work)
     - labels: the specified fdse-work-type label
     - assignee: seth.martin@firstresonance.io
     - status: In Progress
   - Start a Clockify timer against the new ticket
   - Respond: "Created ION-XXXX: <title> [<bucket>]. Timer started."

</process>
