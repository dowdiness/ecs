# TODO

## Phase 1: Core ECS

- [x] Add Phase 1 plan documentation in `docs/PHASE1_PLAN.en.md`
- [x] Implement `EntityId` and `EntityManager` in `entity.mbt`
- [x] Implement `ComponentStore[T]` and `ComponentRemover` in `component_store.mbt`
- [x] Implement `SemilatticeMerge` and `ComponentStore::join_set` in `semilattice.mbt`
- [x] Implement `join2`~`join5` and `each2`~`each5` with smallest-store-first iteration in `query.mbt`
- [x] Replace placeholder tests with blackbox tests:
  - [x] `entity_test.mbt`
  - [x] `component_store_test.mbt`
  - [x] `query_test.mbt`
  - [x] `semilattice_test.mbt`
- [x] Delete placeholder files `ecs.mbt`, `ecs_test.mbt`, `ecs_wbtest.mbt`
- [x] Run `moon info && moon fmt`
- [x] Verify package tests with `moon test --package dowdiness/ecs`
- [x] Fix full-module `moon test` segmentation fault in `cmd/main` test linking
