# 推し概念弾幕プレイヤー (Oshi-Danmaku Player) プロジェクト仕様書

## 1. プロジェクト概要
ユーザーが自身の「推し」や特定の「概念」を弾幕パターンとして表現し、それを再生・鑑賞・テストするための軽量な弾幕STG作成支援ツール兼プレイヤーです。

### ターゲット環境
- **Engine:** Godot Engine 4 (GDScript 2.0)
- **Platform:** Windows / macOS / Linux (PC向け)

## 2. コアコンセプト
- **外部リソースの動的読み込み:** Godotのプロジェクト内にアセットを持たず、OS上の任意のフォルダから画像やJSONを読み込んで動作する。
- **データ主導の設計:** 弾幕の動き、画像、ギミックのすべてをJSONファイルで定義する。
- **軽量・高パフォーマンス:** 大量の弾幕をストレスなく表示し、作成者が試行錯誤しやすい環境を提供する。

## 3. 主要機能仕様 (Status: 開発中)

### 3.1 リソース管理 (Resource Management) - [実装済]
- **外部パス指定:** 起動時にダイアログで「コンセプトフォルダ」を選択。
- **動的ローダー:** `ExternalLoader.gd` により、実行時にJSONと画像をテクスチャ化。
- **JSON解析:** `config.json` を読み込み、`Global.gd` にデータを保持。
- **自動画像ロード:** JSON内の `texture` キーを自動検出しロード。

### 3.2 弾幕エンジン (Bullet Engine) - [設計中]
- **描画方式:** RenderingServer を採用予定。
- **オブジェクトプール:** 大量の弾を再利用する仕組み。


### 3.3 ギミック・演出 (Visuals & Gimmicks)
- **動的表示:** 指定された画像を任意の座標・スケールで表示。
- **画面範囲制限:** JSON指定の解像度でプレイ領域を制限し、領域外を黒塗りでマスク。
- **アニメーション:** `SceneTreeTween` を用いたフェード、移動、回転等の演出。
- **当たり判定:** 
    - JSONの `collision_radius` に基づく円形当たり判定 (`Area2D` + `CircleShape2D`)。
    - 自機 (Layer 1, Mask 2|4), ボス (Layer 2, Mask 1|8) の物理レイヤー構成。
    - 視認用デバッグ描画（`_draw` による円フレーム表示）。

### 3.4 開発支援 (Development Support)
- **ホットリロード:** 実行中に外部ファイルが変更された際の自動再読み込み。
- **テスト実行:** 1つのプロジェクトフォルダ内で複数のJSON（テスト用など）を切り替えて実行。

## 4. JSON定義仕様 (v1.0)

プロジェクト内の `.json` ファイルは以下の構造を持つ必要があります。

### 4.1 基本構造
```json
{
  "metadata": { "project_name": "String", "version": "1.0" },
  "settings": {
    "player": { "texture": "path", "speed": float, "collision_radius": float, "initial_position": [x, y], "scale": [x, y] },
    "boss": { "texture": "path", "collision_radius": float, "initial_position": [x, y], "scale": [x, y] },
    "screen": { "width": int, "height": int }
  },
  "timeline": [
    { "time": float, "type": "gimmick/pattern", ...イベント詳細 }
  ],
  "bullet_types": {
    "type_id": { "texture": "path", "collision_radius": float }
  }
}
```

### 4.2 Gimmickイベント
- `type`: `"gimmick"`
- `action`: `"display"` (現在は表示のみ)
- `name`: 識別名
- `texture`: `Global.textures` に登録されているキー
- `position`: `[x, y]`
- `fade_in`: 秒数 (オプション)
- `scale`: `[x, y]` (オプション)

### 4.3 Independentイベント (単発弾生成)
- `type`: `"independent"`
- `params`:
    - `texture`: 使用するテクスチャのキー
    - `position`: 発射座標 `[x, y]`
    - `speed`: 移動速度 (pixel/sec)
    - `direction_type`: 基準となる角度の決定方式
        - `"fixed"`: `angle` で指定した固定角 (デフォルト)
        - `"aim"`: 自機を狙う角度
    - `angle`: 発射角度 (度、0=右, 90=下)。`direction_type` が `"fixed"` の時に使用。
    - `aim_offset`: `"aim"` の際の固定角度オフセット (度)。
    - `random_range`: 基準角度からのランダムな振れ幅 (度)。
        - 基準角度を `base` とすると、`base ± (random_range / 2)` の範囲でランダムに決定されます。
        - 360 を指定すると全方位ランダムになります。

    - `scale`: 描画スケール `[x, y]` (オプション)
    - `collision_radius`: 当たり判定半径 (オプション)

### 4.4 Patternイベント (弾幕パターン生成)
- `type`: `"pattern"`
- `template`: `"n-way"`, `"circle"` 等
- `params`:
    - `direction_type`: `"fixed"`, `"aim"`, `"random"` (Independentと同様)
    - `angle`: 基本となる発射角度
    - `aim_offset`: `"aim"` の際の角度オフセット
    - その他テンプレート固有のパラメータ (今後追加)

## 5. 今後の拡張性
- 複数のJSONファイルを選択できるセレクターUI。
- 作成した弾幕をパッケージ化して配布する機能。
- 音声ファイルの動的読み込みと再生。
