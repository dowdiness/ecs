# ecs

MoonBit 向け Entity-Component-System フレームワークの設計ドキュメントと実装スキャフォールド。

## 現在の実装状況

2026年2月16日時点で、このリポジトリはスキャフォールド段階:

- ルートパッケージは ECS API をまだ公開していない
- `cmd/main` は `Hello` を出力するテンプレート実行ファイル
- `EntityManager`、`ComponentStore`、`joinN`、リアクティブ API、CRDT API は設計段階で未実装

## 目標アーキテクチャ（設計）

- **型消去なし**: ComponentStore を独立した型付きフィールドで保持
- **リアクティブ変更検出**: [incr](https://github.com/dowdiness/incr) との統合を想定
- **CRDT 拡張**: 因果クロックと操作ログの導入を想定

## インストール

```bash
moon add dowdiness/ecs
```

追加は可能だが、現時点では安定した公開 ECS API はない。

## ドキュメント

- [Design (English)](./docs/DESIGN.en.md)
- [Design (Japanese)](./docs/DESIGN.ja.md)
- [Roadmap (English)](./docs/ROADMAP.en.md)
- [Roadmap (Japanese)](./docs/ROADMAP.ja.md)

## ライセンス

Apache-2.0
