# Roadmap

言語: [English](./ROADMAP.en.md) | 日本語

## 現在の実装状況

2026年2月16日時点:

- リポジトリはスキャフォールド/テンプレート段階
- ルートパッケージは ECS API をまだ公開していない
- このロードマップに記載された API はすべて設計上の目標で、現時点の実装ではない

## 概要

```
Phase 1: コア ECS          incr 依存なし
Phase 2: incr 統合         incr に依存
Phase 3: CRDT 基盤         incr に依存
```

incr ライブラリ (https://github.com/dowdiness/incr) の `on_change` 通知連携は計画中であり、このリポジトリでは未実装。

---

## Phase 1: コア ECS

incr に依存しない純粋な ECS。`Map[EntityId, T]` ベース。

### 提供する型と関数

| 型 / 関数 | 概要 |
|-----------|------|
| `EntityId` | index + generation のペア |
| `EntityManager` | spawn, despawn, is_alive, alive_entities, register_store |
| `ComponentStore[T]` | set, get, remove, has, entities, join_set |
| `ComponentRemover` | trait object。despawn 時の自動クリーンアップ |
| `SemilatticeMerge` | trait 定義のみ。具体実装はユーザー側 |
| `join2` 〜 `join5` | inner join。最小ストア起点で反復。Array を返す |
| `each2` 〜 `each5` | inner join。最小ストア起点で反復。クロージャでイテレート |

### テスト項目

- Entity の spawn / despawn / 世代再利用
- stale EntityId での despawn が false を返す
- alive_entities が生存 Entity のみ返す
- ComponentStore の CRUD
- despawn 時の Component 自動クリーンアップ
- join2 の inner join
- join2 が最小ストアを起点に反復する（疎な Component で効率的）
- each2 のイテレーション
- join_set の半束マージ（テスト用ローカル型で検証）

---

## Phase 2: incr 統合

incr の Signal/Memo で変更検出とリアクティブクエリを実現する。

### 提供する型と関数

| 型 / 関数 | 概要 |
|-----------|------|
| `ReactiveComponentStore[T]` | version Signal + data Map (案C) |
| `reactive_join2` 〜 `reactive_join5` | Memo でラップした joinN |
| `ReactivePipeline` | 反応的派生 Memo の flush 機構 |
| `on_change_derived` | source → target の SemilatticeMerge 派生 |
| `Scheduler` | startup / update の実行順序保証 |

### ReactiveComponentStore の追加メソッド

- `drain_changes` — 変更された Entity の集合を取得してクリア
- `join_set` — SemilatticeMerge 制約付き書き込み（リアクティブ版）

### テスト項目

- set で version Signal がバンプされ Memo が再計算される
- same-value set で Memo が再計算されない
- reactive_join2 が変更後に再計算される
- Backdating で下流の不要な再計算が抑制される
- batch で複数 store の更新が原子的に行われる
- on_change で外部スケジューラに通知される
- on_change_derived が flush 後に反映される
- Scheduler が flush → systems の順序を保証する

### 実行モデルの契約

- `on_change` コールバック内で `Memo.get()` を同期呼び出ししない
- Batch 中の読み取りは Memo 経由でのみトランザクショナル
- 実行順序: Signal 変更 → flush → System 実行

---

## Phase 3: CRDT 基盤

egwalker 統合のための操作ログと因果クロック。

### 提供する型と関数

| 型 / 関数 | 概要 |
|-----------|------|
| `RawVersion` | 因果クロック（incr の Revision とは別概念） |
| `OpKind` | Set / Remove |
| `Operation` | entity, component, kind, version |
| `OperationLog` | 操作の記録 |
| `ReactiveComponentStore::set_with_version` | リモート操作の適用 + ログ記録 |

### テスト項目

- set_with_version が操作ログに記録される
- リモート操作 → Signal バンプ → Memo 再計算のフロー

---

## 将来の検討事項

- **incr Subscriber Links → 案A 移行**: incr に GC 付き Subscriber Links が実装され、かつ単一 Store の Entity 数増加で Memo 検証コストが支配的になった場合、案A（Entity×Component ごとの Signal）に移行可能。外部 API は不変。移行基準の詳細は `DESIGN.ja.md` を参照
- **System 間の依存グラフ解析と並列実行**: 初期は順次実行。必要になった段階で追加
- **egwalker パッケージとの本格統合**: Phase 3 は ECS 側の受け口のみ。egwalker 側のプロトコル実装は別リポジトリ
