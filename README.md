# ecs

A general-purpose Entity-Component-System framework for MoonBit.

## Features

- **No type erasure** — ComponentStores are independently typed fields. No casts, no downcast, full compile-time safety.
- **Reactive change detection** — Optional integration with [incr](https://github.com/dowdiness/incr) for Signal/Memo-based incremental computation with backdating.
- **CRDT-extensible** — Causal clock and operation log primitives for collaborative editing via egwalker.

## Quick Start

Define your own World struct with the components you need:

```moonbit
struct MyWorld {
  entities : @ecs.EntityManager
  positions : @ecs.ComponentStore[Vec2]
  velocities : @ecs.ComponentStore[Vec2]
}

fn main {
  let world = MyWorld::{
    entities: @ecs.EntityManager::new(),
    positions: @ecs.ComponentStore::new(),
    velocities: @ecs.ComponentStore::new(),
  }

  let e = world.entities.spawn()
  world.positions.set(e, Vec2::{ x: 0.0, y: 0.0 })
  world.velocities.set(e, Vec2::{ x: 1.0, y: 2.0 })

  @ecs.each2(world.entities, world.positions, world.velocities,
    fn(entity, pos, vel) {
      println("\{entity}: \{pos} + \{vel}")
    }
  )
}
```

Systems are plain functions — the framework does not impose a special type or trait.

## Install

```bash
moon add dowdiness/ecs
```

## Documentation

- [DESIGN.md](./DESIGN.md) — Design decisions: why no type erasure, Signal granularity (Option C), execution model contracts, migration path
- [ROADMAP.md](./ROADMAP.md) — Implementation phases, what each phase provides, test items, future considerations

## License

Apache-2.0
