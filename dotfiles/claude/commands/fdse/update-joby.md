---
name: fdse:update-joby
description: Sync an ION ticket's status to the linked Joby ticket
argument-hint: "<ION-XXXX>"
allowed-tools:
  - mcp
---

<objective>
Propose a status update on the Joby-side ticket based on the current FR Linear ticket status. Always confirm before executing.
</objective>

<process>

1. Fetch the ION ticket from linear-fr — get current status and description
2. Parse the description/links for Joby ticket references
3. If no Joby refs found, ask the user which Joby ticket to update
4. Fetch each linked Joby ticket from linear-joby — get current status
5. Apply the status mapping:
   - Todo → Todo
   - In Progress → In Progress
   - In Review → Review Ready
   - Merged → Scheduled for Release
   - Tested → Scheduled for Release
   - Released → Done
   - Canceled → Canceled
6. Show the proposed change: "ION-XXXX is <FR status> → move <Joby ticket> from <current> to <proposed>?"
7. **Wait for explicit confirmation.** Do not proceed without it.
8. Update the Joby ticket via linear-joby

</process>
