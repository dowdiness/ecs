# Design

MoonBit 向け汎用 ECS フレームワークの設計判断を記述する。

## 型消去しない

Bevy や Aztecs 等の既存 ECS は `Map[TypeId, ErasedStorage]` で異なる型の Component を1つのコンテナに入れ、取り出し時に `downcast` で具体型に復元する。MoonBit には TypeId も downcast もないため、この方式は使えない。

本フレームワークは **型消去せず、各 ComponentStore を独立した型付きフィールドとして保持する**。ユーザーが World struct を定義し、必要な ComponentStore を並べる:

```moonbit
struct MyWorld {
  entities : @ecs.EntityManager
  positions : @ecs.ComponentStore[Position]
  velocities : @ecs.ComponentStore[Velocity]
  health : @ecs.ComponentStore[Int]
}
```

これにより:

- 完全な型安全性。キャストが一切ない
- MoonBit の既存機能だけで実現可能
- コンパイル時に Component 型の不整合を検出

トレードオフとして、World struct はユーザーが手で書く。Component を追加するたびに World の定義を変更する必要がある。ただしこれは開発時の変更であり、実行時の問題ではない。

## MoonBit の型システムに合わせた設計

MoonBit に **ない** もの:

- TypeId / Any / downcast
- Associated types (`trait Component { type Value }`)
- Trait 上の型パラメータ (`trait Store[T]`)
- マクロ / コード生成

MoonBit に **ある** もので活用するもの:

- ジェネリクス (`struct ComponentStore[T]`, `fn join2[A, B](...)`)
- Trait (Self ベース、`trait SemilatticeMerge { join(Self, Self) -> Self }`)
- Trait object (`&ComponentRemover`) — despawn 時のクリーンアップに限定使用
- Newtype (`type Frequency Float`) — 同じ基底型の Component を型レベルで区別
- 第一級関数 / クロージャ — Dictionary Passing パターンに使用

## Entity の世代管理

EntityId は index と generation のペア。despawn 後に同じ index を再利用するが generation をインクリメントすることで、古い EntityId への誤アクセスを検出する。

free_list は FIFO で管理し、index の再利用を均一にする。

## Component 削除の自動化

Entity 削除時に全 ComponentStore から該当 Entity の Component を自動削除する。ここでは例外的に trait object (`&ComponentRemover`) を使う。`remove_component(EntityId)` という単一の操作だけを公開し、型の復元が不要な安全なパターン。

## joinN の固定アリティ

Bevy の Query API に相当する機能を `join2` 〜 `join5` の固定アリティ関数で提供する。

先例:
- Jane Street Incremental: `map2` 〜 `map6`
- Bevy: タプルに対する trait 実装をマクロで生成

MoonBit にはマクロがないため、手動で定義する。実用上、1つのクエリで同時に必要な Component 数は 5 個以下で十分。必要に応じて `join6` 以降を追加できる。

With/Without フィルタは joinN に組み込まず、クエリ結果に対する `.filter()` で対応する。関数数の爆発を避けるため。

### 最小ストア起点の反復

joinN は全生存 Entity を走査するのではなく、参加する store のうち最小のものを起点に反復する。Entity 数が多く Component が疎な場合に、大半の `get()` が None を返す無駄を避けるため。

```moonbit
// 小さい方の store の Entity を起点に反復
let a_entities = store_a.entities()
let b_entities = store_b.entities()
if a_entities.length() <= b_entities.length() {
  for entity in a_entities {
    if em.is_alive(entity) {
      match store_b.get(entity) { ... }
    }
  }
} else {
  for entity in b_entities {
    if em.is_alive(entity) {
      match store_a.get(entity) { ... }
    }
  }
}
```

Projectional Editor ではノード数が数千に達しうるため、これは Phase 1 から標準実装とする。コストは低い（`entities().length()` の比較を追加するだけ）。

reactive_joinN でも同じ最適化を適用する。ただし全参加 store の `version.get()` を冒頭で呼び、依存記録は省略しない:

```moonbit
@incr.Memo::new(rt, fn() {
  // 全 store の version に依存を記録（最適化で片方しか走査しなくても）
  let _ = store_a.version.get()
  let _ = store_b.version.get()
  // 実際の反復は最小ストア起点
  ...
})
```

## incr 統合: 案C（version Signal + data Map）

ReactiveComponentStore は ComponentStore 全体で1つの version Signal を持ち、data は通常の Map に格納する。

```
ReactiveComponentStore[T]
  ├── version : Signal[Int]    ← Store 全体の変更カウンタ
  ├── data : Map[EntityId, T]  ← 通常の Map
  └── changed_entities         ← 差分処理用
```

検討した代替案:
- **案A**: Entity×Component ごとに Signal → Signal の動的生成・GC が必要。incr に Subscriber Links が実装されるまで非現実的
- **案B**: Entity ごとに Signal → 案A と同じ問題
- **案C (採用)**: Store 全体で1つの Signal → Phase 1 からの移行が最小。incr に動的 Signal GC 不要

案C は粒度が粗いが、incr の Backdating により「version は変わったが Memo の計算結果は同じ」ケースの不要な再計算が抑制される。

### 案C の限界と案A への移行基準

案C では Store 内の1 Entity が変更されただけで、その Store に依存する全ての reactive_joinN が dirty になる。Backdating で最終結果が同じなら下流は再計算されないが、「dirty かどうかの検証」自体のコストは依存の数に比例する。

以下の **両方** が満たされたとき、案A（Entity×Component ごとの Signal）への移行を検討する:

1. **需要側の条件**: 単一 Store の Entity 数が増加し、Memo の再計算（または検証）コストがフレームバジェットに対して支配的になった
2. **供給側の条件**: incr に Subscriber Links と Signal GC が実装された（ROADMAP Phase 4 相当）

条件1だけでは移行できない（incr が動的 Signal のライフサイクル管理をサポートしていない）。条件2だけでは移行する動機がない（案C で十分なら複雑さを増やす必要がない）。

移行時の外部 API 互換性は維持される。ReactiveComponentStore の `set`, `get`, `remove`, `has`, `entities`, `join_set`, `drain_changes` のシグネチャは変わらない。内部実装のみが `Map[EntityId, T]` + `Signal[Int]` から `Map[EntityId, Signal[T]]` に変わる。

## 実行モデル

```
Signal 変更
  → on_change 発火（非同期スケジューリングのみ。Memo.get() 禁止）
  → Scheduler::run_update()
      1. ReactivePipeline::flush()   ← 反応的派生を全て pull
      2. update_systems を順次実行    ← Memo.get() で最新値取得
```

この順序を Scheduler が保証する。反応的派生（on_change_derived）は pull-based な Memo として実装されるため、明示的な flush がないと実行されない。

### Batch のトランザクション意味論

`Runtime::batch` 内で複数の ComponentStore を更新すると、Memo 経由の読み取りはトランザクショナルになる。Signal の `get()` は batch 中もコミット前の値を返すため、Memo は「依存が変わっていない」と判定してキャッシュ値を返す。

ただし `store.data` への直接アクセスは即座に変更後の値が見える。batch 中の読み取りは必ず Memo 経由で行うこと。

## SemilatticeMerge trait

CRDT 統合時に反応層で安全に書き込める型の制約。フレームワークは trait 定義のみ提供し、具体的な実装（EnableWinsFlag 等）はユーザーが定義する。

実装者が保証すべき代数的性質:
- 冪等性: `join(a, a) == a`
- 可換性: `join(a, b) == join(b, a)`
- 結合律: `join(a, join(b, c)) == join(join(a, b), c)`

## ComponentStore → ReactiveComponentStore の移行

両者は同一のメソッドシグネチャ (`set`, `get`, `remove`, `has`, `entities`) を持つ。joinN の関数本体は `store.get(entity)` を呼ぶだけなので、移行時に変更するのは型注釈のみ。

MoonBit に associated types がないため、trait で両者を抽象化することはできない。代わりに、joinN を ReactiveComponentStore 向けに別途定義する（reactive_joinN）。

## CRDT 基盤

RawVersion（因果クロック）と OperationLog は ECS パッケージに含める。incr の Revision（内部論理クロック）とは異なる概念であり、incr 本体への変更は不要。

egwalker からのリモート操作は `set_with_version` を通じて ReactiveComponentStore に適用される。これにより通常の Signal バンプが発生し、Memo が再計算される。

## 参考文献

- Jane Street Incremental — `map2`〜`map6` の固定アリティコンビネータ
- Bevy ECS — archetype-based storage, change detection, observer pattern
- Aztecs — Haskell ECS with component lifecycle observers
- Core ECS 論文 (Redmond et al. 2025) — ECS の形式モデル
- Matt Weidner CRDT Survey Part 2 — Semantic Techniques
