---
name: fdse:report
description: Generate weekly report — hours spreadsheet and work summary
allowed-tools:
  - mcp
---

<objective>
Generate end-of-week deliverables: an hours table grouped by fdse-work-type bucket, and a narrative work summary suitable for a Notion page.
</objective>

<process>

1. **Gather data**
   - Clockify: `get_time_entries` with period `this_week` — all entries
   - FR Linear: for each unique ION-XXXX in the time entries, fetch the ticket (title, status, labels, project, description)
   - FR Linear: also fetch any tickets assigned to me updated this week that might not have time entries
   - Joby Linear: for any tickets that reference Joby ticket IDs, fetch their current status
   - Google Calendar: fetch this week's events for meeting context

2. **Correlate**
   - Group Clockify hours: ION ticket → fdse-work-type label → client
   - For each ticket: title, current status, linked Joby tickets, project name
   - Identify orphan time entries (no ION ticket reference) — flag them
   - Identify tickets missing fdse-work-type labels — flag them
   - Identify meetings from GCal not already covered by time entries

3. **Draft hours table (per client)**
   ```
   | Work Type              | Hours | Tickets                    |
   |------------------------|-------|----------------------------|
   | Feature Dev            | 14.0  | ION-1234, ION-1240         |
   | Integrations           |  8.5  | ION-1235                   |
   | ...                    |       |                            |
   | **Total**              |**XX.X**|                           |
   ```

4. **Draft work summary (narrative for Notion)**
   Group by client, then by outcome:
   - **Completed:** tickets moved to Merged/Tested/Released — what was done
   - **In progress:** actively worked, current status, what's next
   - **Blocked/On hold:** waiting on dependencies or client
   - **Ad-hoc/Support:** interrupt-driven work, incidents
   Include project names for context (e.g., "(Joby) Uptime Hardening").

5. **Present for review**
   Show both outputs. Ask for edits:
   - Move hours between buckets
   - Edit narrative
   - Reclassify orphan hours
   - Add missing context

6. **Publish (on approval)**
   - When the user says "ship it" or approves:
   - Create a new page in the Joby Weekly Updates database:
     - data_source_id: 290eba43-3e36-807e-bc3b-000bf77820b4
     - template_id: 290eba43-3e36-80ac-9a26-eef6c7a7e8d6
     - Doc name: "Joby <> First Resonance | FDE Recap (MM/DD/YYYY)" with current Friday's date
   - Then update the page content with the approved report matching the template structure:
     **Joby <> First Resonance | FDE Recap (date):**
     **Summary:** (2-3 sentence overview)
     **Completed:** (tickets moved to Merged/Tested/Released/Done)
     **In Review / Scheduled for Release:** (tickets in review pipeline)
     **In Progress / Upcoming:** (active and planned work)
     **Results:** (concrete outcomes/wins as bullets)
     **Next:** (planned work for next week)
     **Blockers:** (or "None")
     **FDE Hours Consumed: XX.X this week**
   - Include both ION-XXXX and Joby ticket refs (FR-XXX) where applicable
   - Separately generate CSV of hours by bucket for the spreadsheet

</process>
