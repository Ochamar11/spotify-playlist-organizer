# Spotify Playlist Organizer

Spotify APIとGoogle Gemini AIを活用した音楽プレイリスト整理アプリです。ユーザーのプレイリストをAIが分析し、ジャンル、年代、シーン別に自動で分類・整理します。

## 🎵 機能

- **Spotify認証**: 安全なOAuth2.0認証でSpotifyアカウントに接続
- **プレイリスト表示**: ユーザーの全プレイリストを一覧表示
- **トラック詳細**: 各プレイリスト内の曲を詳細表示
- **AI分類**: Google Gemini AIを使用して曲を自動分類
  - ジャンル別分類
  - 年代別分類  
  - シーン別分類
- **Spotify連携**: 整理されたプレイリストをSpotifyアプリで直接再生

## 🚀 技術スタック

- **フレームワーク**: Flutter 3.8.1
- **言語**: Dart
- **API**: Spotify Web API
- **AI**: Google Gemini AI
- **認証**: OAuth 2.0
- **UI**: Material Design

## 📱 スクリーンショット

![アプリ画面](assets/Gemini_Generated_Image_ma22y3ma22y3ma22.png)

## 🛠️ セットアップ

### 前提条件

- Flutter SDK 3.8.1以上
- Dart SDK
- Android Studio / VS Code
- Spotify Developer Account

### インストール

1. リポジトリをクローン
```bash
git clone https://github.com/your-username/spotify-playlist-organizer.git
cd spotify-playlist-organizer
```

2. 依存関係をインストール
```bash
flutter pub get
```

3. Spotify Developer Consoleでアプリケーションを作成
   - [Spotify Developer Console](https://developer.spotify.com/dashboard)にアクセス
   - 新しいアプリケーションを作成
   - リダイレクトURIを `wolfsort://callback` に設定

4. 環境変数を設定
   - `.env` ファイルを作成し、以下の内容を設定：
   ```
   SPOTIFY_CLIENT_ID=your_spotify_client_id_here
   SPOTIFY_CLIENT_SECRET=your_spotify_client_secret_here
   GEMINI_API_KEY=your_gemini_api_key_here
   ```
   - 実際のAPIキーに置き換えてください

5. アプリを実行
```bash
flutter run
```

## 🔧 設定

### Spotify API設定

1. Spotify Developer Consoleでアプリケーションを作成
2. 以下のスコープを有効化：
   - `user-read-private`
   - `user-read-email`
   - `playlist-read-private`
   - `playlist-read-collaborative`
   - `user-library-read`

### Google Gemini AI設定

1. [Google AI Studio](https://makersuite.google.com/app/apikey)でAPIキーを取得
2. `.env` ファイルの `GEMINI_API_KEY` に実際のAPIキーを設定

## 📁 プロジェクト構造

```
lib/
├── main.dart                 # アプリのエントリーポイント
├── playlist_screen.dart      # プレイリスト一覧画面
├── track_list_screen.dart    # トラック一覧画面
├── spotify_auth_screen.dart  # Spotify認証画面
└── spotify_web_service.dart  # Spotify API通信サービス
```

## 🔐 セキュリティ

- **重要**: APIキーは必ず環境変数（`.env`ファイル）で管理してください
- `.env`ファイルは`.gitignore`で除外されているため、Gitにコミットされません
- 本番環境では認証情報を適切に暗号化
- リフレッシュトークンの安全な保存
- **警告**: コード内にハードコードされたAPIキーは絶対に使用しないでください

## 🤝 貢献

1. このリポジトリをフォーク
2. 機能ブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

## 📄 ライセンス

このプロジェクトはMITライセンスの下で公開されています。詳細は [LICENSE](LICENSE) ファイルを参照してください。

## 🙏 謝辞

- [Spotify Web API](https://developer.spotify.com/documentation/web-api/)
- [Google Gemini AI](https://ai.google.dev/)
- [Flutter](https://flutter.dev/)

## 📞 サポート

問題や質問がある場合は、[Issues](https://github.com/your-username/spotify-playlist-organizer/issues) でお知らせください。

---

**注意**: このアプリは開発中です。本番環境での使用前に十分なテストを行ってください。
