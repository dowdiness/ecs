///|
pub struct EntityId {
  index : Int
  generation : Int
} derive(Eq, Hash, Compare, Show)

///|
pub struct EntityManager {
  mut next_index : Int
  generations : Array[Int]
  alive : Array[Bool]
  free_list : Array[Int]
  removers : Array[&ComponentRemover]
}

///|
pub fn EntityManager::new() -> EntityManager {
  EntityManager::{
    next_index: 0,
    generations: [],
    alive: [],
    free_list: [],
    removers: [],
  }
}

///|
pub fn EntityManager::spawn(self : EntityManager) -> EntityId {
  if self.free_list.length() > 0 {
    let index = self.free_list.remove(0)
    self.generations[index] = self.generations[index] + 1
    self.alive[index] = true
    EntityId::{ index, generation: self.generations[index] }
  } else {
    let index = self.next_index
    self.next_index = self.next_index + 1
    self.generations.push(0)
    self.alive.push(true)
    EntityId::{ index, generation: 0 }
  }
}

///|
pub fn EntityManager::despawn(self : EntityManager, entity : EntityId) -> Bool {
  let index = entity.index
  if index < 0 || index >= self.alive.length() {
    false
  } else if !self.alive[index] {
    false
  } else if self.generations[index] != entity.generation {
    false
  } else {
    self.alive[index] = false
    self.free_list.push(index)
    for remover in self.removers {
      remover.remove_component(entity)
    }
    true
  }
}

///|
pub fn EntityManager::is_alive(self : EntityManager, entity : EntityId) -> Bool {
  let index = entity.index
  if index < 0 || index >= self.alive.length() {
    false
  } else {
    self.alive[index] && self.generations[index] == entity.generation
  }
}

///|
pub fn EntityManager::alive_entities(self : EntityManager) -> Array[EntityId] {
  let entities : Array[EntityId] = []
  for index = 0; index < self.alive.length(); index = index + 1 {
    if self.alive[index] {
      entities.push(EntityId::{ index, generation: self.generations[index] })
    }
  }
  entities
}

///|
pub fn EntityManager::register_store(
  self : EntityManager,
  remover : &ComponentRemover,
) -> Unit {
  self.removers.push(remover)
}
