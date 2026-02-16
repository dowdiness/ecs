# ecs

Design documents and implementation scaffold for a MoonBit Entity-Component-System framework.

## Current Status

As of February 16, 2026, this repository is still at scaffold stage:

- The root package currently exports no ECS APIs.
- `cmd/main` is a template executable that prints `Hello`.
- `EntityManager`, `ComponentStore`, `joinN`, reactive APIs, and CRDT APIs are planned but not implemented yet.

## Planned Architecture (Design Target)

- **No type erasure**: ComponentStores as independently typed fields
- **Reactive change detection**: optional integration with [incr](https://github.com/dowdiness/incr)
- **CRDT-extensible model**: causal clock and operation log primitives

## Install

```bash
moon add dowdiness/ecs
```

The package can be added, but there is no stable public ECS API yet.

## Documentation

- [Design (English)](./docs/DESIGN.en.md)
- [Design (Japanese)](./docs/DESIGN.ja.md)
- [Roadmap (English)](./docs/ROADMAP.en.md)
- [Roadmap (Japanese)](./docs/ROADMAP.ja.md)

## License

Apache-2.0
