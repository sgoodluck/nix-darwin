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

## Remember

Good code is not just working code—it's code that can be easily understood, modified, and maintained by others (including your future self).
