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
   - **Auto-apply customer label**
     - If any of these are true, add the `customer.joby-aviation` label (id: e7b104df-12db-41d2-9a82-7cbdd7781ed4):
       - The ticket description or title mentions "joby" (case insensitive)
       - Joby ticket refs are present (JOB-*, FR-*, FACT-*)
       - The ticket is in a project prefixed with "(Joby)"
       - The user explicitly says it's Joby work
     - If none of these signals are present AND it's not clearly internal FR work, ask: "Is this Joby work?"
     - For clearly internal work (mentions "internal", "FR only", etc.), skip the customer label.
   - **Resolve Clockify project (client-aware)**
     - If ticket has `customer.joby-aviation` label → clientId = `68e69bbbd1605947f26e5690` (Joby Aero)
     - Otherwise → clientId = `68e7e0a8631c3b32395aba2f` (First Resonance)
     - Call `get_projects` and find a project matching the bucket name AND clientId
     - If no match, create the project with `create_project(name=bucket, clientId=clientId)`
   - Start a Clockify timer: description = "ION-XXXX: <ticket title>", projectId = resolved project
   - Respond: "Timer started — ION-XXXX: <title> [<bucket>, <client>]"

4. **New ticket (ad-hoc or interrupt)**
   - The argument should include a description and `bucket:` qualifier
   - If bucket is missing or ambiguous, ask immediately
   - Create a new ticket in linear-fr:
     - team: Engineering (ION)
     - title: the description (prefix with client name if clearly client work)
     - labels: the specified fdse-work-type label
     - assignee: seth.martin@firstresonance.io
     - status: In Progress
   - **Auto-apply customer label**
     - If any of these are true, add the `customer.joby-aviation` label (id: e7b104df-12db-41d2-9a82-7cbdd7781ed4):
       - The description mentions "joby" (case insensitive)
       - Joby ticket refs are included (JOB-*, FR-*, FACT-*)
       - The ticket is in a project prefixed with "(Joby)"
       - The user explicitly says it's Joby work
     - If none of these signals are present AND it's not clearly internal FR work, ask: "Is this Joby work?"
     - For clearly internal work (mentions "internal", "FR only", etc.), skip the customer label.
   - **Resolve Clockify project (client-aware)**
     - If ticket has `customer.joby-aviation` label → clientId = `68e69bbbd1605947f26e5690` (Joby Aero)
     - Otherwise → clientId = `68e7e0a8631c3b32395aba2f` (First Resonance)
     - Call `get_projects` and find a project matching the bucket name AND clientId
     - If no match, create the project with `create_project(name=bucket, clientId=clientId)`
   - Start a Clockify timer against the new ticket with the resolved projectId
   - Respond: "Created ION-XXXX: <title> [<bucket>, <client>]. Timer started."

</process>
