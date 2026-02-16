# Roadmap

Language: English | [日本語](./ROADMAP.ja.md)

## Current Implementation Reality

As of February 16, 2026:

- The repository is still at scaffold/template stage.
- The root package exports no ECS APIs yet.
- All APIs listed in this roadmap are planned targets, not currently implemented behavior.

## Overview

```
Phase 1: Core ECS              No incr dependency
Phase 2: incr Integration      Depends on incr
Phase 3: CRDT Foundation       Depends on incr
```

Integration with incr's `on_change` notification is planned, but not implemented in this repository yet.

---

## Phase 1: Core ECS

A pure ECS with no incr dependency. `Map[EntityId, T]`-based.

### Types and Functions

| Type / Function | Summary |
|-----------------|---------|
| `EntityId` | index + generation pair |
| `EntityManager` | spawn, despawn, is_alive, alive_entities, register_store |
| `ComponentStore[T]` | set, get, remove, has, entities, join_set |
| `ComponentRemover` | Trait object for automatic cleanup on despawn |
| `SemilatticeMerge` | Trait definition only; concrete implementations are user-side |
| `join2` – `join5` | Inner join with smallest-store-first iteration. Returns Array |
| `each2` – `each5` | Inner join with smallest-store-first iteration. Iterates via closure |

### Test Items

- Entity spawn / despawn / generational reuse
- Despawn with stale EntityId returns false
- alive_entities returns only living entities
- ComponentStore CRUD
- Automatic component cleanup on despawn
- join2 inner join
- join2 iterates from the smallest store (efficient with sparse components)
- each2 iteration
- join_set semilattice merge (verified with a test-local type)

---

## Phase 2: incr Integration

Change detection and reactive queries using incr's Signal/Memo.

### Types and Functions

| Type / Function | Summary |
|-----------------|---------|
| `ReactiveComponentStore[T]` | version Signal + data Map (Option C) |
| `reactive_join2` – `reactive_join5` | Memo-wrapped joinN |
| `ReactivePipeline` | Flush mechanism for reactive derivation Memos |
| `on_change_derived` | source → target derivation via SemilatticeMerge |
| `Scheduler` | Guarantees startup / update execution order |

### Additional ReactiveComponentStore Methods

- `drain_changes` — retrieve and clear the set of changed entities
- `join_set` — SemilatticeMerge-constrained write (reactive version)

### Test Items

- set bumps version Signal and Memo recomputes
- Same-value set does not trigger Memo recomputation
- reactive_join2 recomputes after change
- Backdating suppresses unnecessary downstream recomputation
- Batch updates to multiple stores are atomic
- on_change notifies external scheduler
- on_change_derived takes effect after flush
- Scheduler guarantees flush → systems ordering

### Execution Model Contract

- Do not synchronously call `Memo.get()` inside `on_change` callbacks
- Only reads through Memos are transactional during a batch
- Execution order: Signal change → flush → System execution

---

## Phase 3: CRDT Foundation

Operation log and causal clock for egwalker integration.

### Types and Functions

| Type / Function | Summary |
|-----------------|---------|
| `RawVersion` | Causal clock (distinct from incr's Revision) |
| `OpKind` | Set / Remove |
| `Operation` | entity, component, kind, version |
| `OperationLog` | Records operations |
| `ReactiveComponentStore::set_with_version` | Apply remote operations + log recording |

### Test Items

- set_with_version records to operation log
- Remote operation → Signal bump → Memo recomputation flow

---

## Future Considerations

- **incr Subscriber Links → Option A migration**: When incr implements Subscriber Links with GC and the entity count in a single store grows enough that Memo verification cost becomes dominant, migration to Option A (one Signal per Entity×Component) becomes possible. External API remains unchanged. See `DESIGN.en.md` for detailed migration criteria
- **System dependency graph analysis and parallel execution**: Sequential execution initially. Added when needed
- **Full egwalker integration**: Phase 3 provides only the ECS-side interface. The egwalker protocol implementation lives in a separate repository
