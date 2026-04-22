# 練習日誌アプリ MVP 設計

## 1. アプリ全体の設計方針
- **目的**: 社会人アスリートの状態把握を、毎日短時間の入力で実現する。
- **MVP重視**: 朝チェックイン・練習後入力・指導者一覧・コメントの最小導線を優先。
- **構成**: SwiftUI + MVVM。
  - Model: データ構造・ルール判定
  - ViewModel: 画面からの更新処理、状態集約
  - View: 入力UI/一覧UI
  - SampleData: ダミーデータ
- **将来拡張**: `DiaryRepository` プロトコルでデータ層を抽象化し、Firebase/CloudKitへ置換しやすくする。

## 2. 画面一覧
1. 選手ホーム画面
2. 朝チェックイン画面
3. 練習後入力画面
4. 指導者ダッシュボード画面
5. 選手詳細画面
6. コメント確認画面

## 3. データモデル設計
- `Athlete`: 選手マスタ
- `MorningCheckIn`: 朝入力
- `TrainingLog`: 練習後入力
- `DailyRecord`: 1日単位の集約
- `CoachComment`: 指導者コメント
- `AlertRuleEngine`: ルールベース判定
  - 睡眠5時間未満
  - 疲労感4以上
  - 痛みあり
  - 残業あり
  - RPE8以上

## 4. ディレクトリ構成
```
TrainingDiaryApp/
  TrainingDiaryApp.swift
  Models/
    TrainingDiaryModels.swift
    AlertRuleEngine.swift
    DiaryRepository.swift
  ViewModels/
    DiaryStore.swift
  Views/
    RootTabView.swift
    Athlete/
      AthleteHomeView.swift
      MorningCheckInView.swift
      TrainingLogView.swift
      CommentListView.swift
    Coach/
      CoachDashboardView.swift
      AthleteDetailView.swift
    Common/
      AlertBadgeView.swift
      RatingInputRow.swift
  SampleData/
    SampleData.swift
```

## 5. SwiftUIコード一式
- 上記ディレクトリ配下の `.swift` ファイルに実装。

## 6. ダミーデータ
- 日本語名の3選手を定義。
- 状態良好/注意/警告が混在する当日データを投入。
- 指導者コメントの初期データを投入。

## 7. 次に改善すべき点
1. 永続化（UserDefaults/SQLite/Firebase）
2. 通知（未入力リマインド）
3. 複数日トレンド可視化（疲労・睡眠・RPE）
4. チーム/ロール別認証
5. 入力最適化（テンプレート・前日コピー）
