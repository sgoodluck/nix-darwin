---
name: fdse:stop
description: Stop the current timer
allowed-tools:
  - mcp
---

<objective>
Stop whatever Clockify timer is running and report the result.
</objective>

<process>

1. Call clockify `get_running_timer`
2. If no timer is running, say so and exit
3. Call clockify `stop_current_timer`
4. Report: "Stopped ION-XXXX: <description> — <elapsed time>"
5. Show today's total hours by bucket (call `get_time_entries` with period `today`, group by project)

</process>
