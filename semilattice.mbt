///|
/// Join-semilattice merge. Type-level constraint for types that can be safely
/// written to in the reactive derivation layer during CRDT integration.
/// Implementors must guarantee:
///   join(a, a) == a                              (idempotence)
///   join(a, b) == join(b, a)                     (commutativity)
///   join(a, join(b, c)) == join(join(a, b), c)   (associativity)
pub(open) trait SemilatticeMerge {
  join(Self, Self) -> Self
}

///|
pub fn[T : SemilatticeMerge] ComponentStore::join_set(
  self : ComponentStore[T],
  entity : EntityId,
  value : T,
) -> Unit {
  match self.get(entity) {
    Some(existing) => self.set(entity, T::join(existing, value))
    None => self.set(entity, value)
  }
}
