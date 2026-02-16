///|
pub struct ComponentStore[T] {
  data : Map[EntityId, T]
}

///|
pub fn[T] ComponentStore::new() -> ComponentStore[T] {
  ComponentStore::{ data: {} }
}

///|
pub fn[T] ComponentStore::set(
  self : ComponentStore[T],
  entity : EntityId,
  value : T,
) -> Unit {
  self.data[entity] = value
}

///|
pub fn[T] ComponentStore::get(
  self : ComponentStore[T],
  entity : EntityId,
) -> T? {
  self.data.get(entity)
}

///|
pub fn[T] ComponentStore::remove(
  self : ComponentStore[T],
  entity : EntityId,
) -> T? {
  let existing = self.data.get(entity)
  match existing {
    Some(_) => self.data.remove(entity)
    None => ()
  }
  existing
}

///|
pub fn[T] ComponentStore::has(
  self : ComponentStore[T],
  entity : EntityId,
) -> Bool {
  self.data.get(entity) is Some(_)
}

///|
pub fn[T] ComponentStore::length(self : ComponentStore[T]) -> Int {
  self.data.length()
}

///|
pub fn[T] ComponentStore::entities(self : ComponentStore[T]) -> Array[EntityId] {
  let result : Array[EntityId] = []
  for entity, _value in self.data {
    result.push(entity)
  }
  result
}

///|
pub(open) trait ComponentRemover {
  remove_component(Self, EntityId) -> Unit
}

///|
pub impl[T] ComponentRemover for ComponentStore[T] with remove_component(
  self,
  entity,
) {
  let _ = self.remove(entity)
}
