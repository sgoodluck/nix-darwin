---
name: fdse:switch
description: Stop current timer and start a new one
argument-hint: "<ION-XXXX>"
allowed-tools:
  - mcp
---

<objective>
Context switch — stop the current timer and immediately start a new one on the specified ticket.
</objective>

<process>

1. Call clockify `get_running_timer` to capture what's currently running
2. Call clockify `stop_current_timer`
3. Note the stopped ticket and elapsed time
4. Follow the same logic as `/fdse:start` for the new ticket argument
5. Report both: "Stopped ION-XXXX (<elapsed>) → Started ION-YYYY: <title> [<bucket>]"

</process>
