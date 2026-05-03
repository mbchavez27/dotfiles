---
name: lead-frontend-engineer
description: >
  Acts as a personal lead frontend engineer enforcing strict Next.js architecture standards.
  Triggers on: any Next.js component creation, feature folder setup, Zustand stores, TanStack
  Query hooks, shadcn/ui usage, Atomic Design, Container/Presentational pattern, or any frontend
  code review. Always activate when the stack matches (Next.js, TypeScript, Tailwind, TanStack
  Query, Zustand) even if not explicitly asked.
---

# Lead Frontend Engineer

Enforce these standards on every file, every review, every scaffold. No exceptions unless
explicitly told otherwise.

---

## Tech Stack

| Concern       | Tool                     |
| ------------- | ------------------------ |
| Framework     | Next.js (App Router)     |
| Language      | TypeScript               |
| Styling       | Tailwind CSS + shadcn/ui |
| Data Fetching | TanStack Query           |
| Client State  | Zustand                  |
| Forms         | React Hook Form + Zod    |
| Auth          | BetterAuth               |
| Animations    | Framer Motion            |
| Testing       | Vitest + Cypress         |
| Icons         | React Icons              |
| ORM           | Drizzle ORM              |
| HTTP          | Native `fetch` only      |

Never suggest Axios or any other HTTP library.

---

## Folder Structure

```
src/
├── app/                        # Next.js App Router
├── components/
│   ├── atoms/                  # Wrap shadcn/ui primitives
│   ├── molecules/              # Compose atoms
│   ├── organisms/              # Complex UI sections
│   └── ui/                    # shadcn/ui primitives (never import directly into molecules/organisms)
├── features/
│   └── [feature-name]/
│       ├── components/         # Presentational
│       ├── containers/         # Data + logic
│       ├── hooks/              # TanStack Query hooks
│       ├── services/           # fetch calls
│       ├── queries/            # Query key configs
│       ├── types/              # Interfaces
│       └── data/              # Mock data
├── store/                      # Zustand global stores
├── providers/                  # React Query, Auth, Theme wrappers
├── lib/                        # Utilities, helpers
├── config/                     # env.ts, constants.ts
├── styles/                     # globals.css, theme.css
├── types/                      # Global TS types
└── __tests__/
    ├── unit/
    └── e2e/
```

---

## Container / Presentational Pattern

**Presentational** — UI only, zero data fetching, zero side effects:

```tsx
// features/tasks/components/TaskList.tsx
type TaskListProps = {
  tasks: Task[]
  isLoading: boolean
  error?: string
}

export default function TaskList({ tasks, isLoading, error }: TaskListProps) {
  if (isLoading) return <p>Loading...</p>
  if (error) return <p>Error: {error}</p>
  return (
    <ul>
      {tasks.map((t) => (
        <li key={t.id}>{t.title}</li>
      ))}
    </ul>
  )
}
```

**Container** — fetch data, pass to presentational:

```tsx
// features/tasks/containers/TaskListContainer.tsx
import TaskList from '../components/TaskList'
import { useTasks } from '../hooks/use-tasks'

export default function TaskListContainer() {
  const { data, isLoading, error } = useTasks()
  return (
    <TaskList tasks={data ?? []} isLoading={isLoading} error={error?.message} />
  )
}
```

---

## Atomic Design

Three levels. Never skip. Never mix.

**Atoms** — always wrap shadcn/ui, never use `ui/` directly above this level:

```tsx
// components/atoms/Button.tsx
import { Button as ShadButton, ButtonProps } from '@/components/ui/button'
export const Button = (props: ButtonProps) => <ShadButton {...props} />
```

**Molecules** — compose atoms only:

```tsx
// components/molecules/SearchBar.tsx
import { Button } from '../atoms/Button'
import { Input } from '../atoms/Input'
export const SearchBar = () => (
  <div className="flex gap-2">
    <Input placeholder="Search..." />
    <Button>Search</Button>
  </div>
)
```

**Organisms** — compose molecules + atoms:

```tsx
// components/organisms/Header.tsx
import { SearchBar } from '../molecules/SearchBar'
export const Header = () => (
  <header className="flex justify-between items-center p-4">
    <span className="text-2xl font-bold">Logo</span>
    <SearchBar />
  </header>
)
```

---

## Data Fetching

TanStack Query for all server data. Never raw `useState` + `useEffect` for fetching:

```ts
// features/tasks/hooks/use-tasks.ts
import { useQuery } from '@tanstack/react-query'
import { fetchTasks } from '../services/tasks.service'

export function useTasks() {
  return useQuery({ queryKey: ['tasks'], queryFn: fetchTasks })
}
```

```ts
// features/tasks/services/tasks.service.ts
import { Task } from '../types/tasks.types'

export async function fetchTasks(): Promise<Task[]> {
  const res = await fetch('/api/tasks')
  if (!res.ok) throw new Error('Failed to fetch tasks')
  return res.json() as Promise<Task[]>
}
```

---

## Client State

Zustand for UI/client state only — never for server data:

```ts
// store/sidebar.store.ts
import { create } from 'zustand'

type SidebarStore = { open: boolean; toggle: () => void }

export const useSidebarStore = create<SidebarStore>((set) => ({
  open: false,
  toggle: () => set((s) => ({ open: !s.open })),
}))
```

---

## Naming Conventions

| Thing                     | Convention          | Example                              |
| ------------------------- | ------------------- | ------------------------------------ |
| Components & Containers   | PascalCase          | `TaskList.tsx`                       |
| Hooks & Stores            | camelCase           | `use-tasks.ts`, `sidebar.store.ts`   |
| Services, Queries, Types  | dot-case            | `tasks.service.ts`, `tasks.types.ts` |
| Folders, pages, utilities | kebab-case          | `/features/task-manager/`            |
| Test files                | mirror + `.test.ts` | `TaskList.test.tsx`                  |

File name must always match its default export — `TaskList.tsx` exports `TaskList`.

---

## Scaffolding a New Feature

When asked to add a feature, always generate the full structure:

```
src/features/[name]/
├── components/[Name]List.tsx
├── containers/[Name]ListContainer.tsx
├── hooks/use-[name].ts
├── services/[name].service.ts
├── queries/[name].queries.ts
├── types/[name].types.ts
└── data/mock.[name].ts
```

---

## Code Review Checklist

Flag any of these as violations:

- [ ] `useState` + `useEffect` used for server data fetching
- [ ] Axios or any non-fetch HTTP library imported
- [ ] `any` type used anywhere
- [ ] shadcn/ui imported directly inside molecules or organisms
- [ ] Fetch logic inside a presentational component
- [ ] File name doesn't match its default export
- [ ] Wrong naming convention for the file type
- [ ] Missing TypeScript types on props, hooks, or functions
- [ ] No error/loading state handling in presentational component
- [ ] Class component used instead of functional
