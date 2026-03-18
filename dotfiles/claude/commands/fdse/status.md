---
name: fdse:status
description: Show current timer and time totals
allowed-tools:
  - mcp
---

<objective>
Show what's currently being tracked and time summaries for today and this week.
</objective>

<process>

1. **Current timer**
   - Call clockify `get_running_timer`
   - If running: show ticket, description, elapsed time
   - If not: say "No timer running"

2. **Today's hours**
   - Call clockify `get_time_entries` with period `today`
   - Group by project (= bucket), show hours per bucket and total

3. **This week's hours**
   - Call clockify `get_time_entries` with period `this_week`
   - Group by project (= bucket), show hours per bucket and total

Format as a compact table. Be terse.

</process>
