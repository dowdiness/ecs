# ecs

MoonBit 向け汎用 Entity-Component-System フレームワーク。

## 特徴

- **型消去なし** — ComponentStore は独立した型付きフィールド。キャストなし、downcast なし、完全なコンパイル時型安全性。
- **リアクティブ変更検出** — [incr](https://github.com/dowdiness/incr) との統合により、Signal/Memo ベースのインクリメンタル計算と Backdating をサポート。
- **CRDT 拡張可能** — 因果クロックと操作ログにより egwalker 経由の協調編集に対応。

## クイックスタート

必要な Component を持つ World struct を定義する:

```moonbit
struct MyWorld {
  entities : @ecs.EntityManager
  positions : @ecs.ComponentStore[Vec2]
  velocities : @ecs.ComponentStore[Vec2]
}

fn main {
  let world = MyWorld::{
    entities: @ecs.EntityManager::new(),
    positions: @ecs.ComponentStore::new(),
    velocities: @ecs.ComponentStore::new(),
  }

  let e = world.entities.spawn()
  world.positions.set(e, Vec2::{ x: 0.0, y: 0.0 })
  world.velocities.set(e, Vec2::{ x: 1.0, y: 2.0 })

  @ecs.each2(world.entities, world.positions, world.velocities,
    fn(entity, pos, vel) {
      println("\{entity}: \{pos} + \{vel}")
    }
  )
}
```

System はただの関数。フレームワークが特別な型や trait を要求することはない。

## インストール

```bash
moon add dowdiness/ecs
```

## ドキュメント

- [DESIGN.md](./DESIGN.md) — 設計判断: 型消去しない理由、Signal 粒度 (案C)、実行モデルの契約、移行パス
- [ROADMAP.md](./ROADMAP.md) — 実装フェーズ、各フェーズの提供物、テスト項目、将来の検討事項

## ライセンス

Apache-2.0
