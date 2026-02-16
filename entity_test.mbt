///|
test "entity lifecycle" {
  let em = @ecs.EntityManager::new()
  let e1 = em.spawn()
  let e2 = em.spawn()
  inspect(em.is_alive(e1), content="true")
  inspect(em.is_alive(e2), content="true")
  let _ = em.despawn(e1)
  inspect(em.is_alive(e1), content="false")
  inspect(em.is_alive(e2), content="true")
}

///|
test "entity reuse with generation" {
  let em = @ecs.EntityManager::new()
  let e1 = em.spawn()
  let _ = em.despawn(e1)
  let e2 = em.spawn()
  inspect(e1 == e2, content="false")
  inspect(em.is_alive(e1), content="false")
  inspect(em.is_alive(e2), content="true")
}

///|
test "despawn with stale entity id returns false" {
  let em = @ecs.EntityManager::new()
  let e1 = em.spawn()
  let _ = em.despawn(e1)
  let _e2 = em.spawn()
  inspect(em.despawn(e1), content="false")
}

///|
test "entity reuse is FIFO" {
  let em = @ecs.EntityManager::new()
  let e1 = em.spawn()
  let e2 = em.spawn()
  let _e3 = em.spawn()
  let _ = em.despawn(e1)
  let _ = em.despawn(e2)
  let e4 = em.spawn()
  let e5 = em.spawn()
  inspect(e4.index == e1.index, content="true")
  inspect(e5.index == e2.index, content="true")
  inspect(e4 == e1, content="false")
  inspect(e5 == e2, content="false")
}

///|
test "alive_entities" {
  let em = @ecs.EntityManager::new()
  let _e1 = em.spawn()
  let e2 = em.spawn()
  let _e3 = em.spawn()
  let _ = em.despawn(e2)
  inspect(em.alive_entities().length(), content="2")
}
