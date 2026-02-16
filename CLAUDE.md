# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A general-purpose Entity-Component-System (ECS) framework for MoonBit with:
- **No type erasure** — ComponentStores are independently typed struct fields
- **Reactive change detection** — Optional integration with [incr](https://github.com/dowdiness/incr) for Signal/Memo-based incremental computation
- **CRDT-extensible** — Causal clock and operation log primitives for collaborative editing

### Current Implementation Reality

As of February 16, 2026, this repository is still scaffold/template stage and does not yet implement the ECS APIs described below.

### Why This Design?

**MoonBit Constraints**
- **Lacks**: TypeId/Any/downcast, associated types, type parameters on traits, macros/code generation
- **Has**: Generics, traits (Self-based), trait objects, newtypes, first-class functions/closures

This framework works within MoonBit's type system by using:
- **Generics** for `ComponentStore[T]` and `joinN[A, B, ...]`
- **Trait objects** only for cleanup (`&ComponentRemover`) — a safe, limited use case
- **Dictionary passing pattern** via first-class functions for flexible system composition
- **Newtypes** to distinguish components sharing the same underlying type

## Development Commands

### Essential Commands
```bash
# Run tests
moon test

# Update snapshot tests after intentional changes
moon test --update

# Format code (always run before commits)
moon fmt

# Update generated interface files (.mbti)
moon info

# Standard workflow: update interfaces and format
moon info && moon fmt

# Build the project
moon build

# Type-check without building
moon check

# Run the main program
moon run cmd/main

# Check test coverage
moon coverage analyze > uncovered.log
```

### Typical Development Workflow
1. Make code changes in your editor
2. Run `moon test` to verify behavior
3. If snapshots changed intentionally: `moon test --update`
4. Run `moon info && moon fmt` before committing
5. Check `.mbti` diffs — unchanged means safe refactoring

### Testing Strategy
- **Blackbox tests** (`*_test.mbt`): Test public API using `@ecs` imports
- **Whitebox tests** (`*_wbtest.mbt`): Test internal helpers and invariants
- **Snapshot tests**: Use for behavior recording; update with `moon test --update`
- **Assertion tests**: Prefer `assert_eq` or `assert_true` for stable, well-defined results

## Architecture

### Core Design Principles

**Type-Safe Component Storage**
- No TypeId or downcast — MoonBit lacks these features
- Users define custom World structs listing their ComponentStores:
  ```moonbit
  struct MyWorld {
    entities : @ecs.EntityManager
    positions : @ecs.ComponentStore[Vec2]
    velocities : @ecs.ComponentStore[Vec2]
  }
  ```
- Adding components requires changing the World struct definition (compile-time, not runtime)

**Entity Management**
- EntityId = index + generation pair
- Generational indices detect stale entity access
- Free list uses FIFO to distribute index reuse evenly
- Automatic component cleanup on despawn via `ComponentRemover` trait objects

**Query System**
- Fixed-arity join functions: `join2` through `join5`
- `each2` through `each5` for closure-based iteration
- **Smallest-store-first optimization**: Iterates from the store with fewest entities to avoid wasted lookups
- No built-in With/Without filters — use `.filter()` on results

**SemilatticeMerge Trait**
- Type-level constraint for types safe to write in reactive derivation layer during CRDT integration
- Framework provides trait definition; users implement concrete types (e.g., `EnableWinsFlag`)
- Implementors must guarantee these algebraic properties:
  - **Idempotence**: `join(a, a) == a`
  - **Commutativity**: `join(a, b) == join(b, a)`
  - **Associativity**: `join(a, join(b, c)) == join(join(a, b), c)`
- Used by `join_set` method for conflict-free writes in both `ComponentStore` and `ReactiveComponentStore`

### Implementation Phases

**Phase 1: Core ECS** (Planned)
- Pure ECS with `Map[EntityId, T]`-based storage
- No incr dependency
- Types: `EntityManager`, `ComponentStore[T]`, `SemilatticeMerge` trait

**Phase 2: incr Integration**
- `ReactiveComponentStore[T]` with version Signal + data Map (Option C)
- `reactive_join2` through `reactive_join5` (Memo-wrapped queries)
- `ReactivePipeline` flush mechanism
- `on_change_derived` for reactive derivations via `SemilatticeMerge`
- `drain_changes()` method to retrieve and clear changed entity sets for delta processing
- Execution order: Signal change → flush → System execution

**Migration Compatibility**: `ComponentStore` and `ReactiveComponentStore` share identical method signatures (`set`, `get`, `remove`, `has`, `entities`), making migration a type annotation change only.

**Phase 3: CRDT Foundation**
- `RawVersion` causal clock (distinct from incr's Revision)
- `OperationLog` for collaborative editing
- `set_with_version` for applying remote operations

### Reactive Architecture (Phase 2)

**Option C Design (Planned)**
- One Signal per ComponentStore (not per entity)
- Coarse-grained change detection with backdating
- No dynamic Signal GC required in incr
- Migration to Option A (one Signal per entity×component) only when:
  1. Entity count causes Memo verification cost to dominate frame budget
  2. incr implements Subscriber Links with Signal GC

**Critical Implementation Detail for reactive_join**
- `reactive_join` MUST call `version.get()` on ALL participating stores
- This holds even when using smallest-store-first optimization (only one store is iterated)
- Ensures dependency tracking isn't skipped for non-iterated stores
- Pattern: Call all `version.get()` at the top, then perform smallest-store-first iteration

**Execution Model Contract**
- Do NOT call `Memo.get()` synchronously inside `on_change` callbacks
- Only reads through Memos are transactional during `Runtime::batch`
- Signal's `get()` returns pre-commit value during batch; Memos see cached values
- Direct `store.data` access sees mutations immediately — all reads during batch must go through Memos

## Coding Conventions

### docs/TODO.md Maintenance

`docs/TODO.md` tracks the current implementation progress. Always read it at the start of a session to understand where things stand.

- After completing a task, check its box in `docs/TODO.md` (`- [x]`) and commit the update together with the implementation.
- Do not delete completed tasks within an active Phase — they tell you what is already done and should not be re-implemented.
- When an entire Phase is completed, collapse its individual tasks into a single line marked `Done: Phase N ✓`. This keeps the file short without losing the signal that the Phase is finished.
- Always work on tasks in the order listed. Do not skip ahead to a later Phase.

### File Organization
- **Block style**: Code organized in blocks separated by `///|`
- Block order is irrelevant — refactor block-by-block independently
- Deprecated code goes in `deprecated.mbt` per directory

### Package Structure
- Each directory is a package with a `moon.pkg` file listing dependencies
- `moon.mod.json` at project root contains module metadata
- Generated `.mbti` files describe the public interface

### Best Practices
- Check `.mbti` diffs after `moon info` — unchanged means safe refactoring
- Keep blocks small and focused for easy refactoring
- Systems are plain functions — no special type or trait imposed
- Use newtypes (`type Frequency Float`) to distinguish components with the same underlying type

## Important Files

- `docs/DESIGN.en.md` — Detailed design rationale (type erasure, Signal granularity, execution model)
- `docs/ROADMAP.en.md` — Implementation phases and test items
- `AGENTS.md` — MoonBit project conventions and tooling reference
- `moon.mod.json` — Module metadata
- `moon.pkg` — Package dependency file (per directory)

## MoonBit Tooling Notes

- `moon ide` provides `peek-def`, `outline`, and `find-references`
- MoonBit supports snapshot testing natively
- Prefer assertion tests for scientific/deterministic computations
- Always run `moon info && moon fmt` before committing

## Design Influences

This framework's design draws from:
- **Jane Street Incremental** — Fixed-arity combinators (`map2` through `map6`), backdating for change detection
- **Bevy ECS** — Archetype-based storage patterns, change detection, observer pattern
- **Aztecs** — Haskell ECS with component lifecycle observers
- **Core ECS paper** (Redmond et al. 2025) — Formal model of Entity-Component-System
- **Matt Weidner CRDT Survey Part 2** — Semantic techniques for conflict-free replicated data types
