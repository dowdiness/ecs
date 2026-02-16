///|
test "component store CRUD" {
  let store : @ecs.ComponentStore[Int] = @ecs.ComponentStore::new()
  let em = @ecs.EntityManager::new()
  let e1 = em.spawn()
  let e2 = em.spawn()
  store.set(e1, 42)
  store.set(e2, 99)
  inspect(store.get(e1), content="Some(42)")
  inspect(store.get(e2), content="Some(99)")
  inspect(store.has(e1), content="true")
  let _ = store.remove(e1)
  inspect(store.get(e1), content="None")
  inspect(store.has(e1), content="false")
}

///|
test "despawn cleans up components" {
  let em = @ecs.EntityManager::new()
  let store : @ecs.ComponentStore[Int] = @ecs.ComponentStore::new()
  em.register_store(store)
  let e = em.spawn()
  store.set(e, 42)
  let _ = em.despawn(e)
  inspect(store.get(e), content="None")
}
