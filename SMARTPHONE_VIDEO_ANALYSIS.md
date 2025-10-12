# スマートフォン向け動画解析アプリ開発ガイド

## 1. ゴールの定義
- 対象デバイス: iOS / Android
- 解析目的: 物体検出、動作認識、姿勢推定など
- オフライン解析かクラウド連携かを決める

## 2. 要求仕様
- スマートフォンのカメラ API を利用してライブ映像/録画動画を取得
- 解析結果をリアルタイムにオーバーレイ表示
- 解析ログを保存し、後で再分析できるようにする
- ユーザーインターフェースは直感的で操作が簡単

## 3. 技術スタック候補
| レイヤ | 技術候補 |
| --- | --- |
| フロントエンド | SwiftUI, Jetpack Compose, Flutter, React Native |
| ネイティブ API | AVFoundation(iOS), CameraX(Android) |
| 機械学習 | Core ML, TensorFlow Lite, MediaPipe, ONNX Runtime Mobile |
| バックエンド | Firebase, Supabase, AWS Amplify, FastAPI |

## 4. 機械学習モデルの選択
1. オープンソースモデルを転移学習 (YOLOv8, MobileNet, EfficientDet 等)
2. 自前データセットのアノテーション (LabelImg, CVAT, Roboflow)
3. TensorFlow Lite / Core ML 形式に最適化
4. 量子化や pruning で推論速度を改善

## 5. アプリアーキテクチャ
```
+-------------------------+
|        UI 層            |
| (SwiftUI / Compose)     |
+-----------+-------------+
            |
+-----------v-------------+
|     カメラ制御層        |
| (AVFoundation / CameraX)|
+-----------+-------------+
            |
+-----------v-------------+
|   ML 推論エンジン       |
| (TF Lite / Core ML)     |
+-----------+-------------+
            |
+-----------v-------------+
|   データ管理・通信層    |
| (ローカルDB / API)      |
+-------------------------+
```

## 6. プロトタイピング手順
1. PoC として TensorFlow Lite + Android CameraX で動くサンプルを作成
2. iOS に移植し、Core ML で同等の推論を実装
3. UI/UX を改善し、解析結果の可視化 (バウンディングボックス、グラフなど)
4. 性能計測 (FPS, CPU/GPU 使用率) と最適化

## 7. テスト戦略
- 単体テスト: ML 推論結果の整合性
- UI テスト: 主要操作フロー (撮影、解析、保存)
- E2E テスト: 実機での長時間連続解析
- ベンチマーク: モデル推論時間、消費電力、発熱

## 8. セキュリティ・プライバシー
- カメラ利用許可を明確に説明
- 解析データの暗号化保存
- クラウド転送時は HTTPS + 認証
- 個人情報が映り込む場合のマスキング

## 9. 運用
- クラッシュログ収集 (Firebase Crashlytics 等)
- モデル更新の配信 (App 更新 or A/B テスト)
- ユーザーからのフィードバック収集と改善

## 10. 参考リソース
- [TensorFlow Lite Examples](https://www.tensorflow.org/lite/examples)
- [Apple Developer - Vision Framework](https://developer.apple.com/documentation/vision)
- [Android CameraX](https://developer.android.com/training/camerax)
- [MediaPipe Solutions](https://developers.google.com/mediapipe)

このガイドを起点に、具体的なユースケースに合わせて要件を肉付けしてください。

## 11. Python ベースの PoC 実装例
スマートフォンアプリを実装する前に、OpenCV を使った PoC (概念実証) を PC で動かしておくと、
アルゴリズムの検証やパラメータ調整が容易です。本リポジトリには Python 製のモーション検出
ツール `analyze_video.py` とユーティリティ `mobile_video_analysis` が含まれています。

### セットアップ
1. Python 3.10 以上をインストール
2. 依存関係をインストール
   ```bash
   pip install -r requirements.txt
   ```
3. スマートフォンで IP カメラ化アプリ (IP Webcam / DroidCam / OBS Camera 等) を起動し、
   Wi-Fi 経由でアクセスできる URL を控える

### 実行方法
```bash
python analyze_video.py \
  --source "http://<smartphone-ip>:<port>/video" \
  --record-out output.mp4 \
  --save-metrics logs/session.json \
  --overlay-mask
```
- `--source` は数値を指定すると PC の USB カメラを利用、URL を渡すと IP カメラ配信を解析
- `--record-out` で解析済み映像を保存 (mp4v)
- `--save-metrics` で各フレームの検出情報を JSON で保存
- `--overlay-mask` で検出領域のヒートマップを重ねて可視化
- `--max-frames` を指定すると検証用に処理フレーム数を制限

### テスト
```bash
pytest
```
OpenCV がインストールされていない環境ではテストはスキップされます。CI や開発マシンでは
`opencv-python` の導入後にテストを実行し、モーション検出のロジックを担保してください。

### PoC の活用
- 取得した `logs/session.json` から動きが多い区間を抽出し、スマホアプリの UI 設計に反映
- `MotionAnalyzer` のパラメータ (学習率、しきい値、最小面積) を調整し、ノイズ耐性を評価
- スマホ実装では ML Kit / MediaPipe などに置き換える際の比較ベースラインとして活用
