///|
test "join2" {
  let em = @ecs.EntityManager::new()
  let pos : @ecs.ComponentStore[Int] = @ecs.ComponentStore::new()
  let vel : @ecs.ComponentStore[Int] = @ecs.ComponentStore::new()
  let e1 = em.spawn()
  let e2 = em.spawn()
  let e3 = em.spawn()
  pos.set(e1, 0)
  pos.set(e2, 10)
  pos.set(e3, 20)
  vel.set(e1, 1)
  vel.set(e3, 3)
  inspect(@ecs.join2(em, pos, vel).length(), content="2")
}

///|
test "each2" {
  let em = @ecs.EntityManager::new()
  let a : @ecs.ComponentStore[Int] = @ecs.ComponentStore::new()
  let b : @ecs.ComponentStore[Int] = @ecs.ComponentStore::new()
  let e1 = em.spawn()
  let e2 = em.spawn()
  a.set(e1, 1)
  a.set(e2, 2)
  b.set(e1, 10)
  let mut sum = 0
  @ecs.each2(em, a, b, fn(_e, av, bv) { sum = sum + av + bv })
  inspect(sum, content="11")
}

///|
test "join2 uses smallest store" {
  let em = @ecs.EntityManager::new()
  let sparse : @ecs.ComponentStore[Int] = @ecs.ComponentStore::new()
  let dense : @ecs.ComponentStore[Int] = @ecs.ComponentStore::new()
  let entities : Array[@ecs.EntityId] = []
  for i = 0; i < 100; i = i + 1 {
    let e = em.spawn()
    entities.push(e)
    dense.set(e, i)
  }
  sparse.set(entities[0], 10)
  sparse.set(entities[50], 50)
  sparse.set(entities[99], 99)
  let results = @ecs.join2(em, sparse, dense)
  inspect(results.length(), content="3")
}
