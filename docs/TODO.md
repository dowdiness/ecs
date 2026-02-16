# TODO

## Phase 1: Core ECS

- [ ] Add Phase 1 plan documentation in `docs/PHASE1_PLAN.en.md`
- [ ] Implement `EntityId` and `EntityManager` in `entity.mbt`
- [ ] Implement `ComponentStore[T]` and `ComponentRemover` in `component_store.mbt`
- [ ] Implement `SemilatticeMerge` and `ComponentStore::join_set` in `semilattice.mbt`
- [ ] Implement `join2`~`join5` and `each2`~`each5` with smallest-store-first iteration in `query.mbt`
- [ ] Replace placeholder tests with blackbox tests:
  - [ ] `entity_test.mbt`
  - [ ] `component_store_test.mbt`
  - [ ] `query_test.mbt`
  - [ ] `semilattice_test.mbt`
- [ ] Delete placeholder files `ecs.mbt`, `ecs_test.mbt`, `ecs_wbtest.mbt`
- [ ] Run `moon info && moon fmt`
- [ ] Verify package tests with `moon test --package dowdiness/ecs`
- [ ] Fix full-module `moon test` segmentation fault in `cmd/main` test linking
