# 推し概念弾幕プレイヤー (Oshi-Danmaku Player) 開発ロードマップ

## プロジェクト概要
ユーザーが定義したJSONと外部画像ファイルを動的に読み込み、弾幕STGを再生・作成支援するGodot 4プロジェクト。

## 技術仕様
- **Engine:** Godot Engine 4 (GDScript)
- **Target:** PC (Windows/Linux/macOS)
- **Resource Management:** 
    - `Image.load_from_file` による外部テクスチャの動的生成
    - `FileAccess` による `config.json` の解析
    - `Marshalls` を用いたBase64埋め込み対応（将来）
- **Performance:** 
    - `RenderingServer` または `MultiMeshInstance2D` による大量描画
    - Object Poolingによるメモリ最適化

---

## 実装ステップ

### 1. 基礎基盤：外部リソースローダー (Foundation)
- [x] OS上の絶対パスからデータを引き出す仕組みの構築
- [x] `ExternalLoader`: JSONと画像を読み込み、辞書と `ImageTexture` に変換
- [x] `ConfigManager`: `config.json` をパースし、グローバルに参照可能にする (Global.gdに統合)

### 2. コアエンジン：弾幕描画システム (Bullet Engine)
- [x] 画面範囲制限機能：JSON指定の解像度に基づくレターボックス表示と移動制限
- [x] 基礎実装：単発弾（independent）の生成・移動・画面外自動削除
- [ ] 大量描画方式の選定（`RenderingServer` vs `MultiMeshInstance2D` vs `Sprite2D`）
- [ ] Object Pooling の実装
- [ ] 基本的な弾の移動ロジック（n-way等）

---

## 将来的な拡張機能 (Future Enhancements)
- [ ] **複数JSON対応:** 1つのプロジェクトフォルダ内で複数の弾幕定義を切り替えて実行できる機能。
- [ ] **セレクターUI:** フォルダ選択後、利用可能なJSONファイルをリスト表示し、選択して実行するフロー。

### 3. 挙動定義：JSONパターンインタープリタ (Interpreter)
- [ ] パターンパラメータの定義（`speed`, `angle`, `acceleration`, `radial_count`, `spin`等）
- [ ] エミッター（発射装置）のロジック実装

### 4. 演出・ギミック：Tweenアニメーション (Gimmicks)
- [x] `GimmickManager`: 任意画像の動的表示の実装
- [x] `TimelinePlayer`: 時系列に沿ったイベント発火システムの構築
- [ ] `create_tween()` を用いたJSON定義アニメーション（移動・フェード・回転）の拡張

### 5. システム：当たり判定とホットリロード (System)
- [x] 自機・ボスの当たり判定：JSON指定サイズに基づいた円形当たり判定の実装
- [x] ヒットボックス視認化：デバッグ用描画機能の実装
- [ ] 弾の当たり判定：大量の弾に対する効率的な判定ロジックの実装
- [ ] ファイル監視によるホットリロード機能の実装

---

## 開発の進め方
1. 各ステップをさらに細分化し、テストを行いながら実装する。
2. パフォーマンスが重要となる弾幕描画部分は、早期にプロトタイプを作成して検証する。
3. ホットリロードは開発効率を劇的に上げるため、基盤が整い次第導入する。
