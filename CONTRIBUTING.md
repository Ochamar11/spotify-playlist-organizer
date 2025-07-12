# 貢献ガイドライン

Spotify Playlist Organizerプロジェクトへの貢献をありがとうございます！

## 🚀 始め方

### 1. リポジトリをフォーク

GitHubでこのリポジトリをフォークしてください。

### 2. ローカルにクローン

```bash
git clone https://github.com/your-username/spotify-playlist-organizer.git
cd spotify-playlist-organizer
```

### 3. 依存関係をインストール

```bash
flutter pub get
```

### 4. 開発ブランチを作成

```bash
git checkout -b feature/your-feature-name
```

## 📝 開発ガイドライン

### コードスタイル

- Dartの公式コーディング規約に従ってください
- `flutter analyze` でコードの品質をチェックしてください
- 適切なコメントを追加してください

### コミットメッセージ

以下の形式でコミットメッセージを書いてください：

```
type(scope): description

feat: 新機能
fix: バグ修正
docs: ドキュメント更新
style: コードスタイル修正
refactor: リファクタリング
test: テスト追加
chore: その他の変更
```

例：
```
feat(auth): Spotify認証機能を追加
fix(playlist): プレイリスト取得エラーを修正
docs(readme): セットアップ手順を更新
```

### プルリクエスト

1. 変更をコミット
```bash
git add .
git commit -m "feat: 新機能を追加"
```

2. ブランチをプッシュ
```bash
git push origin feature/your-feature-name
```

3. プルリクエストを作成
   - タイトルは簡潔に
   - 説明には変更内容を詳しく記載
   - 関連するIssueがあればリンク

## 🐛 バグ報告

バグを発見した場合は、以下の情報を含めてIssueを作成してください：

- バグの詳細な説明
- 再現手順
- 期待される動作
- 実際の動作
- 環境情報（OS、Flutterバージョンなど）
- スクリーンショット（可能であれば）

## 💡 機能リクエスト

新しい機能の提案も歓迎します。以下の情報を含めてIssueを作成してください：

- 機能の詳細な説明
- 使用例
- 実装の提案（可能であれば）
- 優先度

## 🔧 開発環境

### 必要なツール

- Flutter SDK 3.8.1以上
- Dart SDK
- Android Studio / VS Code
- Git

### 推奨設定

- Flutter拡張機能をインストール
- Dart拡張機能をインストール
- コードフォーマッターを設定

## 📋 チェックリスト

プルリクエストを送信する前に、以下を確認してください：

- [ ] コードがFlutterのコーディング規約に従っている
- [ ] 新しいテストを追加した（必要に応じて）
- [ ] 既存のテストが通る
- [ ] ドキュメントを更新した（必要に応じて）
- [ ] コミットメッセージが適切
- [ ] 機密情報が含まれていない

## 🎉 貢献者の方へ

貢献していただいた方々の名前をREADMEに記載させていただきます。ご希望の場合は、プルリクエストのコメントでお知らせください。

## 📞 サポート

質問や問題がある場合は、[Issues](https://github.com/your-username/spotify-playlist-organizer/issues) でお知らせください。

---

皆様の貢献を心よりお待ちしています！ 