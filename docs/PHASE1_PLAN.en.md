# Phase 1 Plan (Core ECS)

Language: English

## Goal

Implement Phase 1 of `dowdiness/ecs` as a dependency-free, type-safe core ECS in the root package.

## Scope

- No external dependencies.
- Keep root `moon.pkg` empty.
- Provide core APIs:
  - `EntityId`
  - `EntityManager`
  - `ComponentStore[T]`
  - `ComponentRemover`
  - `SemilatticeMerge`
  - `join2` to `join5`
  - `each2` to `each5`
  - `ComponentStore::join_set`

## Design Constraints

- No type erasure or downcast patterns.
- `EntityManager` uses generational IDs and FIFO reuse via `free_list.remove(0)`.
- Despawn triggers automatic cleanup through `ComponentRemover` trait objects.
- Queries must use smallest-store-first iteration.
- `joinN`/`eachN` must not iterate over `alive_entities()`.

## Deliverables

### Source files

- `entity.mbt`
- `component_store.mbt`
- `query.mbt`
- `semilattice.mbt`

### Test files (blackbox)

- `entity_test.mbt`
- `component_store_test.mbt`
- `query_test.mbt`
- `semilattice_test.mbt`

### Removed placeholders

- `ecs.mbt`
- `ecs_test.mbt`
- `ecs_wbtest.mbt`

## Verification

1. `moon test`
2. `moon info && moon fmt`
3. Check `pkg.generated.mbti` for expected Phase 1 API surface.

## Exit Criteria

- All Phase 1 blackbox tests pass.
- Public API in `pkg.generated.mbti` matches roadmap Phase 1 types/functions.
- No dependency changes and root `moon.pkg` remains empty.
