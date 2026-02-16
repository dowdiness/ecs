///|
priv struct TestMax {
  value : Int
} derive(Show)

///|
impl @ecs.SemilatticeMerge for TestMax with join(a, b) {
  { value: if a.value > b.value { a.value } else { b.value } }
}

///|
test "join_set merges with semilattice" {
  let store : @ecs.ComponentStore[TestMax] = @ecs.ComponentStore::new()
  let em = @ecs.EntityManager::new()
  let e = em.spawn()
  store.join_set(e, { value: 3 })
  store.join_set(e, { value: 7 })
  inspect(store.get(e), content="Some({value: 7})")
  store.join_set(e, { value: 5 })
  inspect(store.get(e), content="Some({value: 7})")
}
