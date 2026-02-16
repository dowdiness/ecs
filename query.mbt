///|
pub fn[A, B] join2(
  entities : EntityManager,
  store_a : ComponentStore[A],
  store_b : ComponentStore[B],
) -> Array[(EntityId, A, B)] {
  let result : Array[(EntityId, A, B)] = []
  let a_len = store_a.length()
  let b_len = store_b.length()
  if a_len <= b_len {
    for entity in store_a.entities() {
      if entities.is_alive(entity) {
        match (store_a.get(entity), store_b.get(entity)) {
          (Some(a), Some(b)) => result.push((entity, a, b))
          _ => ()
        }
      }
    }
  } else {
    for entity in store_b.entities() {
      if entities.is_alive(entity) {
        match (store_a.get(entity), store_b.get(entity)) {
          (Some(a), Some(b)) => result.push((entity, a, b))
          _ => ()
        }
      }
    }
  }
  result
}

///|
pub fn[A, B, C] join3(
  entities : EntityManager,
  store_a : ComponentStore[A],
  store_b : ComponentStore[B],
  store_c : ComponentStore[C],
) -> Array[(EntityId, A, B, C)] {
  let result : Array[(EntityId, A, B, C)] = []
  let mut min_store = 0
  let mut min_len = store_a.length()
  let b_len = store_b.length()
  if b_len < min_len {
    min_len = b_len
    min_store = 1
  }
  let c_len = store_c.length()
  if c_len < min_len {
    min_len = c_len
    min_store = 2
  }
  match min_store {
    0 =>
      for entity in store_a.entities() {
        if entities.is_alive(entity) {
          match
            (store_a.get(entity), store_b.get(entity), store_c.get(entity)) {
            (Some(a), Some(b), Some(c)) => result.push((entity, a, b, c))
            _ => ()
          }
        }
      }
    1 =>
      for entity in store_b.entities() {
        if entities.is_alive(entity) {
          match
            (store_a.get(entity), store_b.get(entity), store_c.get(entity)) {
            (Some(a), Some(b), Some(c)) => result.push((entity, a, b, c))
            _ => ()
          }
        }
      }
    _ =>
      for entity in store_c.entities() {
        if entities.is_alive(entity) {
          match
            (store_a.get(entity), store_b.get(entity), store_c.get(entity)) {
            (Some(a), Some(b), Some(c)) => result.push((entity, a, b, c))
            _ => ()
          }
        }
      }
  }
  result
}

///|
pub fn[A, B, C, D] join4(
  entities : EntityManager,
  store_a : ComponentStore[A],
  store_b : ComponentStore[B],
  store_c : ComponentStore[C],
  store_d : ComponentStore[D],
) -> Array[(EntityId, A, B, C, D)] {
  let result : Array[(EntityId, A, B, C, D)] = []
  let mut min_store = 0
  let mut min_len = store_a.length()
  let b_len = store_b.length()
  if b_len < min_len {
    min_len = b_len
    min_store = 1
  }
  let c_len = store_c.length()
  if c_len < min_len {
    min_len = c_len
    min_store = 2
  }
  let d_len = store_d.length()
  if d_len < min_len {
    min_len = d_len
    min_store = 3
  }
  match min_store {
    0 =>
      for entity in store_a.entities() {
        if entities.is_alive(entity) {
          match
            (
              store_a.get(entity),
              store_b.get(entity),
              store_c.get(entity),
              store_d.get(entity),
            ) {
            (Some(a), Some(b), Some(c), Some(d)) =>
              result.push((entity, a, b, c, d))
            _ => ()
          }
        }
      }
    1 =>
      for entity in store_b.entities() {
        if entities.is_alive(entity) {
          match
            (
              store_a.get(entity),
              store_b.get(entity),
              store_c.get(entity),
              store_d.get(entity),
            ) {
            (Some(a), Some(b), Some(c), Some(d)) =>
              result.push((entity, a, b, c, d))
            _ => ()
          }
        }
      }
    2 =>
      for entity in store_c.entities() {
        if entities.is_alive(entity) {
          match
            (
              store_a.get(entity),
              store_b.get(entity),
              store_c.get(entity),
              store_d.get(entity),
            ) {
            (Some(a), Some(b), Some(c), Some(d)) =>
              result.push((entity, a, b, c, d))
            _ => ()
          }
        }
      }
    _ =>
      for entity in store_d.entities() {
        if entities.is_alive(entity) {
          match
            (
              store_a.get(entity),
              store_b.get(entity),
              store_c.get(entity),
              store_d.get(entity),
            ) {
            (Some(a), Some(b), Some(c), Some(d)) =>
              result.push((entity, a, b, c, d))
            _ => ()
          }
        }
      }
  }
  result
}

///|
pub fn[A, B, C, D, E] join5(
  entities : EntityManager,
  store_a : ComponentStore[A],
  store_b : ComponentStore[B],
  store_c : ComponentStore[C],
  store_d : ComponentStore[D],
  store_e : ComponentStore[E],
) -> Array[(EntityId, A, B, C, D, E)] {
  let result : Array[(EntityId, A, B, C, D, E)] = []
  let mut min_store = 0
  let mut min_len = store_a.length()
  let b_len = store_b.length()
  if b_len < min_len {
    min_len = b_len
    min_store = 1
  }
  let c_len = store_c.length()
  if c_len < min_len {
    min_len = c_len
    min_store = 2
  }
  let d_len = store_d.length()
  if d_len < min_len {
    min_len = d_len
    min_store = 3
  }
  let e_len = store_e.length()
  if e_len < min_len {
    min_len = e_len
    min_store = 4
  }
  match min_store {
    0 =>
      for entity in store_a.entities() {
        if entities.is_alive(entity) {
          match
            (
              store_a.get(entity),
              store_b.get(entity),
              store_c.get(entity),
              store_d.get(entity),
              store_e.get(entity),
            ) {
            (Some(a), Some(b), Some(c), Some(d), Some(e)) =>
              result.push((entity, a, b, c, d, e))
            _ => ()
          }
        }
      }
    1 =>
      for entity in store_b.entities() {
        if entities.is_alive(entity) {
          match
            (
              store_a.get(entity),
              store_b.get(entity),
              store_c.get(entity),
              store_d.get(entity),
              store_e.get(entity),
            ) {
            (Some(a), Some(b), Some(c), Some(d), Some(e)) =>
              result.push((entity, a, b, c, d, e))
            _ => ()
          }
        }
      }
    2 =>
      for entity in store_c.entities() {
        if entities.is_alive(entity) {
          match
            (
              store_a.get(entity),
              store_b.get(entity),
              store_c.get(entity),
              store_d.get(entity),
              store_e.get(entity),
            ) {
            (Some(a), Some(b), Some(c), Some(d), Some(e)) =>
              result.push((entity, a, b, c, d, e))
            _ => ()
          }
        }
      }
    3 =>
      for entity in store_d.entities() {
        if entities.is_alive(entity) {
          match
            (
              store_a.get(entity),
              store_b.get(entity),
              store_c.get(entity),
              store_d.get(entity),
              store_e.get(entity),
            ) {
            (Some(a), Some(b), Some(c), Some(d), Some(e)) =>
              result.push((entity, a, b, c, d, e))
            _ => ()
          }
        }
      }
    _ =>
      for entity in store_e.entities() {
        if entities.is_alive(entity) {
          match
            (
              store_a.get(entity),
              store_b.get(entity),
              store_c.get(entity),
              store_d.get(entity),
              store_e.get(entity),
            ) {
            (Some(a), Some(b), Some(c), Some(d), Some(e)) =>
              result.push((entity, a, b, c, d, e))
            _ => ()
          }
        }
      }
  }
  result
}

///|
pub fn[A, B] each2(
  entities : EntityManager,
  store_a : ComponentStore[A],
  store_b : ComponentStore[B],
  f : (EntityId, A, B) -> Unit,
) -> Unit {
  let a_len = store_a.length()
  let b_len = store_b.length()
  if a_len <= b_len {
    for entity in store_a.entities() {
      if entities.is_alive(entity) {
        match (store_a.get(entity), store_b.get(entity)) {
          (Some(a), Some(b)) => f(entity, a, b)
          _ => ()
        }
      }
    }
  } else {
    for entity in store_b.entities() {
      if entities.is_alive(entity) {
        match (store_a.get(entity), store_b.get(entity)) {
          (Some(a), Some(b)) => f(entity, a, b)
          _ => ()
        }
      }
    }
  }
}

///|
pub fn[A, B, C] each3(
  entities : EntityManager,
  store_a : ComponentStore[A],
  store_b : ComponentStore[B],
  store_c : ComponentStore[C],
  f : (EntityId, A, B, C) -> Unit,
) -> Unit {
  let mut min_store = 0
  let mut min_len = store_a.length()
  let b_len = store_b.length()
  if b_len < min_len {
    min_len = b_len
    min_store = 1
  }
  let c_len = store_c.length()
  if c_len < min_len {
    min_len = c_len
    min_store = 2
  }
  match min_store {
    0 =>
      for entity in store_a.entities() {
        if entities.is_alive(entity) {
          match
            (store_a.get(entity), store_b.get(entity), store_c.get(entity)) {
            (Some(a), Some(b), Some(c)) => f(entity, a, b, c)
            _ => ()
          }
        }
      }
    1 =>
      for entity in store_b.entities() {
        if entities.is_alive(entity) {
          match
            (store_a.get(entity), store_b.get(entity), store_c.get(entity)) {
            (Some(a), Some(b), Some(c)) => f(entity, a, b, c)
            _ => ()
          }
        }
      }
    _ =>
      for entity in store_c.entities() {
        if entities.is_alive(entity) {
          match
            (store_a.get(entity), store_b.get(entity), store_c.get(entity)) {
            (Some(a), Some(b), Some(c)) => f(entity, a, b, c)
            _ => ()
          }
        }
      }
  }
}

///|
pub fn[A, B, C, D] each4(
  entities : EntityManager,
  store_a : ComponentStore[A],
  store_b : ComponentStore[B],
  store_c : ComponentStore[C],
  store_d : ComponentStore[D],
  f : (EntityId, A, B, C, D) -> Unit,
) -> Unit {
  let mut min_store = 0
  let mut min_len = store_a.length()
  let b_len = store_b.length()
  if b_len < min_len {
    min_len = b_len
    min_store = 1
  }
  let c_len = store_c.length()
  if c_len < min_len {
    min_len = c_len
    min_store = 2
  }
  let d_len = store_d.length()
  if d_len < min_len {
    min_len = d_len
    min_store = 3
  }
  match min_store {
    0 =>
      for entity in store_a.entities() {
        if entities.is_alive(entity) {
          match
            (
              store_a.get(entity),
              store_b.get(entity),
              store_c.get(entity),
              store_d.get(entity),
            ) {
            (Some(a), Some(b), Some(c), Some(d)) => f(entity, a, b, c, d)
            _ => ()
          }
        }
      }
    1 =>
      for entity in store_b.entities() {
        if entities.is_alive(entity) {
          match
            (
              store_a.get(entity),
              store_b.get(entity),
              store_c.get(entity),
              store_d.get(entity),
            ) {
            (Some(a), Some(b), Some(c), Some(d)) => f(entity, a, b, c, d)
            _ => ()
          }
        }
      }
    2 =>
      for entity in store_c.entities() {
        if entities.is_alive(entity) {
          match
            (
              store_a.get(entity),
              store_b.get(entity),
              store_c.get(entity),
              store_d.get(entity),
            ) {
            (Some(a), Some(b), Some(c), Some(d)) => f(entity, a, b, c, d)
            _ => ()
          }
        }
      }
    _ =>
      for entity in store_d.entities() {
        if entities.is_alive(entity) {
          match
            (
              store_a.get(entity),
              store_b.get(entity),
              store_c.get(entity),
              store_d.get(entity),
            ) {
            (Some(a), Some(b), Some(c), Some(d)) => f(entity, a, b, c, d)
            _ => ()
          }
        }
      }
  }
}

///|
pub fn[A, B, C, D, E] each5(
  entities : EntityManager,
  store_a : ComponentStore[A],
  store_b : ComponentStore[B],
  store_c : ComponentStore[C],
  store_d : ComponentStore[D],
  store_e : ComponentStore[E],
  f : (EntityId, A, B, C, D, E) -> Unit,
) -> Unit {
  let mut min_store = 0
  let mut min_len = store_a.length()
  let b_len = store_b.length()
  if b_len < min_len {
    min_len = b_len
    min_store = 1
  }
  let c_len = store_c.length()
  if c_len < min_len {
    min_len = c_len
    min_store = 2
  }
  let d_len = store_d.length()
  if d_len < min_len {
    min_len = d_len
    min_store = 3
  }
  let e_len = store_e.length()
  if e_len < min_len {
    min_len = e_len
    min_store = 4
  }
  match min_store {
    0 =>
      for entity in store_a.entities() {
        if entities.is_alive(entity) {
          match
            (
              store_a.get(entity),
              store_b.get(entity),
              store_c.get(entity),
              store_d.get(entity),
              store_e.get(entity),
            ) {
            (Some(a), Some(b), Some(c), Some(d), Some(e)) =>
              f(entity, a, b, c, d, e)
            _ => ()
          }
        }
      }
    1 =>
      for entity in store_b.entities() {
        if entities.is_alive(entity) {
          match
            (
              store_a.get(entity),
              store_b.get(entity),
              store_c.get(entity),
              store_d.get(entity),
              store_e.get(entity),
            ) {
            (Some(a), Some(b), Some(c), Some(d), Some(e)) =>
              f(entity, a, b, c, d, e)
            _ => ()
          }
        }
      }
    2 =>
      for entity in store_c.entities() {
        if entities.is_alive(entity) {
          match
            (
              store_a.get(entity),
              store_b.get(entity),
              store_c.get(entity),
              store_d.get(entity),
              store_e.get(entity),
            ) {
            (Some(a), Some(b), Some(c), Some(d), Some(e)) =>
              f(entity, a, b, c, d, e)
            _ => ()
          }
        }
      }
    3 =>
      for entity in store_d.entities() {
        if entities.is_alive(entity) {
          match
            (
              store_a.get(entity),
              store_b.get(entity),
              store_c.get(entity),
              store_d.get(entity),
              store_e.get(entity),
            ) {
            (Some(a), Some(b), Some(c), Some(d), Some(e)) =>
              f(entity, a, b, c, d, e)
            _ => ()
          }
        }
      }
    _ =>
      for entity in store_e.entities() {
        if entities.is_alive(entity) {
          match
            (
              store_a.get(entity),
              store_b.get(entity),
              store_c.get(entity),
              store_d.get(entity),
              store_e.get(entity),
            ) {
            (Some(a), Some(b), Some(c), Some(d), Some(e)) =>
              f(entity, a, b, c, d, e)
            _ => ()
          }
        }
      }
  }
}
