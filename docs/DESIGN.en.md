# Design

Design decisions for a general-purpose ECS framework targeting MoonBit.

## Current Implementation Reality

As of February 16, 2026, this design is forward-looking. The repository currently contains scaffold/template code and does not yet implement the ECS APIs described below.

## No Type Erasure

Existing ECS frameworks like Bevy and Aztecs use `Map[TypeId, ErasedStorage]` to store different component types in a single container, recovering concrete types via `downcast` at retrieval time. MoonBit has neither TypeId nor downcast, so this approach is not possible.

This framework **does not erase types. Each ComponentStore is held as an independently typed field.** Users define their own World struct and list the ComponentStores they need:

```moonbit
struct MyWorld {
  entities : @ecs.EntityManager
  positions : @ecs.ComponentStore[Position]
  velocities : @ecs.ComponentStore[Velocity]
  health : @ecs.ComponentStore[Int]
}
```

This gives us:

- Full type safety. No casts whatsoever
- Implementable with MoonBit's existing features alone
- Component type mismatches caught at compile time

The tradeoff is that the World struct must be written by hand. Adding a component requires changing the World definition. However, this is a development-time change, not a runtime concern.

## Designing for MoonBit's Type System

What MoonBit **lacks**:

- TypeId / Any / downcast
- Associated types (`trait Component { type Value }`)
- Type parameters on traits (`trait Store[T]`)
- Macros / code generation

What MoonBit **has** and we leverage:

- Generics (`struct ComponentStore[T]`, `fn join2[A, B](...)`)
- Traits (Self-based, `trait SemilatticeMerge { join(Self, Self) -> Self }`)
- Trait objects (`&ComponentRemover`) — used exclusively for despawn cleanup
- Newtypes (`type Frequency Float`) — type-level distinction of components sharing the same underlying type
- First-class functions / closures — used for the dictionary passing pattern

## Entity Generational Management

EntityId is an index–generation pair. After despawn, the same index is reused but the generation is incremented, allowing detection of stale EntityId access.

The free list is managed as a FIFO to distribute index reuse evenly.

## Automatic Component Cleanup

When an entity is despawned, its components are automatically removed from all registered ComponentStores. This is the one place where we use trait objects (`&ComponentRemover`). Only the single operation `remove_component(EntityId)` is exposed, so no type recovery is needed — a safe pattern for trait objects.

## Fixed-Arity joinN

Functionality equivalent to Bevy's Query API is provided through fixed-arity functions `join2` through `join5`.

Precedent:
- Jane Street Incremental: `map2` through `map6`
- Bevy: macro-generated trait implementations over tuples

Since MoonBit has no macros, these are defined by hand. In practice, a single query rarely needs more than 5 components simultaneously. `join6` and beyond can be added as needed.

With/Without filters are not built into joinN. Instead, users apply `.filter()` on query results. This avoids combinatorial explosion of function signatures.

### Smallest-Store-First Iteration

joinN iterates starting from the smallest participating store rather than scanning all alive entities. This avoids the waste of most `get()` calls returning None when entity counts are high and components are sparse.

```moonbit
// Iterate from the smaller store
let a_entities = store_a.entities()
let b_entities = store_b.entities()
if a_entities.length() <= b_entities.length() {
  for entity in a_entities {
    if em.is_alive(entity) {
      match store_b.get(entity) { ... }
    }
  }
} else {
  for entity in b_entities {
    if em.is_alive(entity) {
      match store_a.get(entity) { ... }
    }
  }
}
```

A projectional editor can easily reach thousands of nodes, so this is the standard implementation from Phase 1. The overhead is minimal (one `entities().length()` comparison).

The same optimization applies to reactive_joinN. However, `version.get()` must be called for all participating stores at the top to ensure dependency recording is not skipped:

```moonbit
@incr.Memo::new(rt, fn() {
  // Record dependency on all store versions (even if only one is scanned)
  let _ = store_a.version.get()
  let _ = store_b.version.get()
  // Actual iteration uses smallest-store-first
  ...
})
```

## incr Integration: Option C (Version Signal + Data Map)

ReactiveComponentStore holds a single version Signal for the entire store, with data in a plain Map.

```
ReactiveComponentStore[T]
  ├── version : Signal[Int]    ← change counter for the whole store
  ├── data : Map[EntityId, T]  ← plain Map
  └── changed_entities         ← for delta processing
```

Alternatives considered:
- **Option A**: One Signal per Entity×Component → requires dynamic Signal creation and GC. Not feasible until incr implements Subscriber Links
- **Option B**: One Signal per Entity → same problem as Option A
- **Option C (adopted)**: One Signal per Store → minimal migration from Phase 1. No dynamic Signal GC needed in incr

Option C is coarse-grained, but incr's backdating suppresses unnecessary recomputation in cases where "the version changed but the Memo's computed result is the same."

### Limits of Option C and Migration Criteria for Option A

Under Option C, a change to a single entity in a store marks all reactive_joinN queries depending on that store as dirty. Backdating prevents downstream recomputation when the final result is unchanged, but the cost of the "is it dirty?" verification itself is proportional to the number of dependencies.

Migration to Option A (one Signal per Entity×Component) should be considered when **both** of the following conditions are met:

1. **Demand-side condition**: The entity count in a single store grows to the point where Memo recomputation (or verification) cost becomes dominant relative to the frame budget
2. **Supply-side condition**: incr implements Subscriber Links with Signal GC (corresponding to ROADMAP future work)

Condition 1 alone is insufficient (incr does not yet support dynamic Signal lifecycle management). Condition 2 alone provides no motivation (if Option C is adequate, there is no reason to add complexity).

External API compatibility is preserved across the migration. The signatures of ReactiveComponentStore's `set`, `get`, `remove`, `has`, `entities`, `join_set`, and `drain_changes` remain unchanged. Only the internal representation changes from `Map[EntityId, T]` + `Signal[Int]` to `Map[EntityId, Signal[T]]`.

## Execution Model

```
Signal change
  → on_change fires (async scheduling only; Memo.get() is forbidden)
  → Scheduler::run_update()
      1. ReactivePipeline::flush()   ← pull all reactive derivations
      2. Run update_systems           ← systems call Memo.get() for latest values
```

The Scheduler guarantees this ordering. Reactive derivations (on_change_derived) are implemented as pull-based Memos, so they will not execute without an explicit flush.

### Batch Transaction Semantics

When multiple ComponentStores are updated inside `Runtime::batch`, reads through Memos become transactional. Signal's `get()` returns the pre-commit value during a batch, so Memos judge their dependencies as unchanged and return cached values.

However, direct access to `store.data` sees the mutated value immediately. All reads during a batch must go through Memos.

## SemilatticeMerge Trait

A type-level constraint for types that can be safely written to in the reactive derivation layer during CRDT integration. The framework provides only the trait definition; concrete implementations (e.g., EnableWinsFlag) are defined by users.

Algebraic properties that implementors must guarantee:
- Idempotence: `join(a, a) == a`
- Commutativity: `join(a, b) == join(b, a)`
- Associativity: `join(a, join(b, c)) == join(join(a, b), c)`

## ComponentStore → ReactiveComponentStore Migration

Both share identical method signatures (`set`, `get`, `remove`, `has`, `entities`). The body of joinN only calls `store.get(entity)`, so migration requires changing only type annotations.

Since MoonBit lacks associated types, abstracting over both via a trait is not possible. Instead, joinN is separately defined for ReactiveComponentStore as reactive_joinN.

## CRDT Foundation

RawVersion (causal clock) and OperationLog are part of the ECS package. These are conceptually distinct from incr's Revision (internal logical clock), and no changes to incr itself are needed.

Remote operations from egwalker are applied to ReactiveComponentStore via `set_with_version`. This triggers a normal Signal bump, causing Memos to recompute.

## References

- Jane Street Incremental — fixed-arity combinators `map2` through `map6`
- Bevy ECS — archetype-based storage, change detection, observer pattern
- Aztecs — Haskell ECS with component lifecycle observers
- Core ECS paper (Redmond et al. 2025) — formal model of ECS
- Matt Weidner CRDT Survey Part 2 — Semantic Techniques
