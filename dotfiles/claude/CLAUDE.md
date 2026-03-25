# Global Claude Preferences

> "Simplicity is the final achievement. After one has played a vast quantity of notes and more notes, it is simplicity that emerges as the crowning reward of art." - Chopin

Write code for humans, not just computers. The best code is often the simplest code that solves the problem effectively.

## Communication Style

**Be concise and direct**: Avoid unnecessary preambles

**Explain clearly but briefly**: Focus on solving the problem at hand

**Minimize output tokens**: While maintaining clarity

**Only use emojis when explicitly requested**

## Core Development Principles

**Functions should be short and sweet, and do just one thing**

**Single responsibility**: Each function should do one thing and do it well

**Readable naming**: Use meaningful variable and function names

**Comment the why, not the how**: Write self-explanatory code

**If you need more than 3 levels of nesting, you're doing something wrong**

**Early returns**: Use guard clauses to reduce complexity

**Extract helper functions**: Break complex logic into smaller pieces

## Development Practices

**Always check existing code patterns before making changes**

**Prefer editing existing files over creating new ones**

**Never create documentation files unless explicitly requested**

**Run appropriate lint/typecheck commands after making changes**

**Use the TodoWrite tool for complex multi-step tasks**

## Language-Specific Guidelines

### React/TypeScript

**Use modern syntax**: ES modules, async/await, destructuring

**Destructure props and state**: Makes component interfaces clear

**Modularize components**: One component per file, extract custom hooks

**Use TypeScript strictly**: Enable strict mode, avoid `any` type

**Prefer functional components**: Use hooks over class components

**Extract custom hooks**: For reusable stateful logic

```tsx
// Good: Destructured props, clear interface
interface UserCardProps {
  user: User;
  onEdit: (id: string) => void;
  className?: string;
}

const UserCard = ({ user, onEdit, className = '' }: UserCardProps) => {
  const { name, email, isActive } = user;
  
  return (
    <div className={`user-card ${className}`}>
      <h3>{name}</h3>
      <p>{email}</p>
      {isActive && <button onClick={() => onEdit(user.id)}>Edit</button>}
    </div>
  );
};

// Good: Custom hook extraction
const useUserData = (userId: string) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    fetchUser(userId).then(setUser).finally(() => setLoading(false));
  }, [userId]);
  
  return { user, loading };
};
```

**Component organization**: Keep components small and single-purpose

**State management**: Use local state when possible, lift state up only when needed

**Event handlers**: Define them outside JSX when they contain logic

**Conditional rendering**: Use early returns for complex conditions

### Python

**Follow PEP 8**: Use the standard Python style guide

**Use type hints**: Especially for function parameters and return values

**Prefer explicit imports**: `from module import specific_function` over `import *`

**Leverage pathlib**: Use `pathlib.Path` instead of `os.path` for file operations

**Context managers**: Use `with` statements for resource management

**List comprehensions**: Use them for simple transformations, prefer regular loops for complex logic

```python
# Good: Clear, typed, and uses pathlib
def read_config(config_path: Path) -> dict[str, str]:
    with config_path.open() as f:
        return json.load(f)

# Good: Simple list comprehension
active_users = [user for user in users if user.is_active]

# Bad: Complex list comprehension - use a regular loop instead
results = [process_complex_data(item, config) for item in items 
          if item.status == 'active' and validate(item)]
```

### JavaScript

**Use `const` by default, `let` when needed, avoid `var`**

**Prefer template literals over string concatenation**

**Use modern ES6+ features appropriately**

**Functional programming patterns where appropriate**

## Security

**Never hardcode API keys or secrets in code**

**Use environment variables or secure storage for sensitive data**

**Always consider security implications of code changes**

**Validate all inputs**: Never trust external data

**Use parameterized queries**: Prevent SQL injection

## Nix Preferences

**Always use flakes for Nix configurations**

**Prefer nixpkgs from stable Darwin branches for macOS systems**

**Use Home Manager for user-level configurations**

**Add descriptive comments for complex Nix expressions**

**Follow the modular structure established in this repository**

## Command Line Tools

**Important: This system uses modern CLI tool replacements via shell aliases:**

- `find` → `fd` (fd-find): More intuitive file finding with better syntax
- `grep` → `rg` (ripgrep): Faster searching with better defaults
- `cat` → `bat`: Syntax highlighting and line numbers
- `ls` → `eza`: Icons, colors, and git integration
- `tree` → `eza --tree`: Tree view with icons
- `du` → `dust`: Visual disk usage analyzer
- `ps` → `procs`: Modern process viewer
- `top` → `htop`: Interactive process viewer
- `cd` → `z` (zoxide): Smart directory jumping

**When writing scripts or commands:**
- Be aware these are aliases in the shell
- Use the modern tool syntax, not traditional Unix syntax
- For example: use `fd pattern` instead of `find . -name "pattern"`
- For searching: use `rg pattern` instead of `grep pattern`

## Remember

Good code is not just working code—it's code that can be easily understood, modified, and maintained by others (including your future self).

## FDSE Workflow

The `/fdse:*` commands manage Seth's FDSE time tracking and reporting workflow.
See `~/.claude/commands/fdse/` for command definitions.

### MCP Servers (FDSE workflow)

- **linear-fr** — First Resonance Linear. Team: "Engineering" (key: ION, id: 646208fb-5ab5-4ea9-91eb-9a8602d0ad98). Seth: seth.martin@firstresonance.io
- **linear-joby** — Joby Aviation Linear. Team: "First Resonance" (id: 5b20fcfc-f5c8-4693-88cc-fa5a98db0a15)
- **clockify** — Time tracking. Managed entirely by /fdse commands. Seth never opens Clockify.
- **gcal** — Google Calendar. Meeting context for weekly reports.
- **notion** — Publishing weekly summary pages.

### Notion — Joby Weekly Updates Database

- Database URL: https://www.notion.so/290eba433e3680bb8bdbd10d47710f1c
- Data source ID: collection://290eba43-3e36-807e-bc3b-000bf77820b4
- Template ID: 290eba43-3e36-80ac-9a26-eef6c7a7e8d6 (named "Joby Weekly Updates")
- Title property: "Doc name"
- Title format: "Joby <> First Resonance | FDE Recap (MM/DD/YYYY)"
- Parent page: "Joby <> First Resonance" (https://www.notion.so/285eba433e368088addff5e85a7d0c45)

Report template structure (match this exactly):
```
**Joby <> First Resonance | FDE Recap (MM/DD/YYYY):**
**Summary:**
<2-3 sentence overview of the week>
**Completed:**
- ION-XXXX / FR-XXX — <title>: <status>. <1-line description of what was done>
**In Review / Scheduled for Release:**
- ION-XXXX — <title>: <status>. <1-line description>
**In Progress / Upcoming:**
- ION-XXXX — <title>: <status>. <1-line description>
**Results:**
- <bullet list of concrete outcomes/wins>
**Next:**
- <bullet list of planned work for next week>
**Blockers:**
- <blockers or "None">
**FDE Hours Consumed: XX.X this week**
```

### Data Model

FR Linear (ION-XXXX) is the source of truth. Each ticket has an `fdse-work-type` label that determines the Clockify project and the spreadsheet column. Joby tickets are referenced by ION tickets (many:1, 1:1, or 0:1). Clockify entries always reference ION ticket IDs in format "ION-XXXX: description".

### Bucket Labels (fdse-work-type group in FR Linear)

feature-dev | integrations | rules | debugging | data-request | analytics-and-dashboards | process-and-training

### Client Labels

- `customer.joby-aviation` (id: e7b104df-12db-41d2-9a82-7cbdd7781ed4) — workspace-level label. Auto-applied when work is Joby-related.

### Clockify Projects

Projects are per-client per-bucket. Same bucket name can exist under different clients.

Clients:
- **Joby Aero** (id: 68e69bbbd1605947f26e5690) — use when ticket has `customer.joby-aviation` label
- **First Resonance** (id: 68e7e0a8631c3b32395aba2f) — use for internal/non-client work

Buckets: feature-dev | integrations | rules | debugging | data-request | analytics-and-dashboards | process-and-training | meetings

When starting/logging time, resolve the client from the ticket's labels, then find or create the project matching bucket + client. Create on first use with `clientId`.

### FR Linear Engineering Team Statuses

Backlog → Todo → In Progress → In Review → Merged → Tested → Released
Also: Product Planning, Failed Testing, Triage, Canceled

### Joby Linear (First Resonance team) Statuses

Triage → Backlog → Todo → In Progress → Review Ready → Scheduled for Release → Done
Also: On Hold, Blocked, Canceled, Duplicate

### Cross-Workspace Status Mapping (FR → Joby)

Todo→Todo | In Progress→In Progress | In Review→Review Ready | Merged→Scheduled for Release | Tested→Scheduled for Release | Released→Done | Canceled→Canceled

Joby also has: Blocked, On Hold (use when Seth explicitly says so).

### Rules

1. Never move Joby tickets without explicit confirmation
2. Never guess the bucket — ask if ambiguous
3. Be terse — no filler
4. Ignore legacy labels: sync-to-fr, Time Spent group on Joby side
