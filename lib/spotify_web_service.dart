import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SpotifyWebService {
  // 環境変数から取得
  static String get clientId => dotenv.env['SPOTIFY_CLIENT_ID'] ?? 'your_spotify_client_id';
  static String get clientSecret => dotenv.env['SPOTIFY_CLIENT_SECRET'] ?? 'your_spotify_client_secret';
  static const String redirectUri = 'wolfsort://callback';
  static const String scope =
    'user-read-private user-read-email user-read-playback-state user-modify-playback-state user-read-currently-playing playlist-read-private playlist-read-collaborative user-library-read user-read-recently-played';
  
  String? _accessToken;
  String? _refreshToken;
  
  // 認証URLを生成
  String getAuthUrl() {
    final params = {
      'client_id': clientId,
      'response_type': 'code',
      'redirect_uri': redirectUri,
      'scope': scope,
      'state': _generateRandomString(16),
    };
    
    final queryString = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    
    return 'https://accounts.spotify.com/authorize?$queryString';
  }
  
  // 認証コードからアクセストークンを取得
  Future<bool> getAccessToken(String authCode) async {
    try {
      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
        },
        body: {
          'grant_type': 'authorization_code',
          'code': authCode,
          'redirect_uri': redirectUri,
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        _refreshToken = data['refresh_token'];
        return true;
      }
    } catch (e) {
      print('トークン取得エラー: $e');
    }
    return false;
  }
  
  // 現在再生中の曲を取得
  Future<Map<String, dynamic>?> getCurrentTrack() async {
    if (_accessToken == null) return null;
    
    try {
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me/player/currently-playing'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('現在の曲取得エラー: $e');
    }
    return null;
  }
  
  // プレイリストを取得
  Future<List<Map<String, dynamic>>> getPlaylists() async {
    if (_accessToken == null) return [];
    
    try {
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me/playlists'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['items']);
      }
    } catch (e) {
      print('プレイリスト取得エラー: $e');
    }
    return [];
  }
  
  // トークンをリフレッシュ
  Future<bool> refreshToken() async {
    if (_refreshToken == null) return false;
    
    try {
      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
        },
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': _refreshToken,
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        if (data['refresh_token'] != null) {
          _refreshToken = data['refresh_token'];
        }
        return true;
      }
    } catch (e) {
      print('トークンリフレッシュエラー: $e');
    }
    return false;
  }
  
  // ランダム文字列生成
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(DateTime.now().millisecondsSinceEpoch % chars.length)
    ));
  }
  
  // プレイリスト内のトラック一覧を取得
  Future<List<Map<String, dynamic>>> getPlaylistTracks(String playlistId) async {
    if (_accessToken == null) return [];
    try {
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/playlists/$playlistId/tracks'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );
      print('playlist tracks status: \\${response.statusCode}');
      print('playlist tracks body: \\${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('playlist tracks items: \\${data['items']}');
        // 'track'がnullでないものだけ抽出
        return List<Map<String, dynamic>>.from(
          (data['items'] as List)
              .map((item) => item['track'])
              .where((track) => track != null)
              .cast<Map<String, dynamic>>()
        );
      }
    } catch (e, stack) {
      print('トラック取得エラー: $e');
      print(stack);
    }
    return [];
  }
  
  bool get isAuthenticated => _accessToken != null;
  
  // 認証情報をクリア（再認証用）
  void clearAuth() {
    _accessToken = null;
    _refreshToken = null;
    print('認証情報をクリアしました');
  }
  
  // トラックをSpotifyアプリで再生（起動）
  Future<void> launchTrackOnSpotify(String trackId) async {
    final url = 'https://open.spotify.com/track/$trackId';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      print('SpotifyアプリまたはブラウザでURLを開けません: $url');
    }
  }
  
  Future<void> aiSortTracks(List<Map<String, dynamic>> tracks, {String sortType = 'ジャンル'}) async {
    // ステップA: 曲名・アーティスト名リストを作成
    final trackDataList = <String>[];
    for (final t in tracks) {
      final name = t['name'] ?? '';
      final artists = (t['artists'] as List?)?.map((a) => a['name']).join(', ') ?? '';
      trackDataList.add('$name - $artists');
    }

    // ステップB: プロンプト生成
    String prompt;
    if (sortType == 'ジャンル') {
      prompt = '''あなたは音楽ジャンルに詳しい日本人の音楽キュレーターです。以下の曲リストをジャンルごとに3～5グループに分けてください。geniusやGoogle検索、SNSの話題も参考に、ネット上の評判や知識を活用してください。各グループには分かりやすい日本語のプレイリスト名と、その内容を説明する短い日本語の説明文をつけてください。出力は以下のJSON形式で、説明文以外の余計なテキストは含めないでください。
[
  {
    "playlist_name": "ここにAIが考えた日本語のプレイリスト名",
    "description": "このグループの日本語説明文",
    "tracks": [
      {"track_name": "曲名", "artist_name": "アーティスト名"}
    ]
  }
]
# 曲リスト\n${trackDataList.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n')}
''';
    } else if (sortType == '年代') {
      prompt = '''あなたは音楽の年代に詳しい日本人の音楽キュレーターです。以下の曲リストを年代ごと（例：1990年代、2000年代など）に3～5グループに分けてください。geniusやGoogle検索、SNSの話題も参考に、ネット上の評判や知識を活用してください。各グループには分かりやすい日本語のプレイリスト名と、その内容を説明する短い日本語の説明文をつけてください。出力は以下のJSON形式で、説明文以外の余計なテキストは含めないでください。
[
  {
    "playlist_name": "ここにAIが考えた日本語のプレイリスト名",
    "description": "このグループの日本語説明文",
    "tracks": [
      {"track_name": "曲名", "artist_name": "アーティスト名"}
    ]
  }
]
# 曲リスト\n${trackDataList.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n')}
''';
    } else {
      // シーン
      prompt = '''あなたは音楽のシーン分けに詳しい日本人の音楽キュレーターです。以下の曲リストを「睡眠」「ドライブ」「勉強」「パーティー」など多様なシーンで3～5グループに分けてください。geniusやGoogle検索、SNSの話題も参考に、ネット上の評判や知識を活用してください。各グループには分かりやすい日本語のプレイリスト名と、その内容を説明する短い日本語の説明文をつけてください。出力は以下のJSON形式で、説明文以外の余計なテキストは含めないでください。
[
  {
    "playlist_name": "ここにAIが考えた日本語のプレイリスト名",
    "description": "このグループの日本語説明文",
    "tracks": [
      {"track_name": "曲名", "artist_name": "アーティスト名"}
    ]
  }
]
# 曲リスト\n${trackDataList.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n')}
''';
    }

    // ステップC: Gemini API呼び出し
    final geminiApiKey = dotenv.env['GEMINI_API_KEY'];
    if (geminiApiKey == null || geminiApiKey.isEmpty || geminiApiKey == 'your_gemini_api_key_here') {
      throw 'GEMINI_API_KEYが設定されていません。AI機能を利用するには.envファイルでAPIキーを設定してください。';
    }
    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: geminiApiKey);
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);
    final jsonText = response.text?.trim();
    if (jsonText == null || jsonText.isEmpty) throw 'AI応答が空です';
    // コードブロック除去（複数行対応）
    final cleanedJsonText = jsonText
        .replaceAll(RegExp(r'```json', multiLine: true), '')
        .replaceAll(RegExp(r'```', multiLine: true), '')
        .trim();
    // ステップD: JSON解析
    final playlists = json.decode(cleanedJsonText) as List;
    // ステップE: Spotifyで新規プレイリスト作成
    final userResp = await http.get(
      Uri.parse('https://api.spotify.com/v1/me'),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );
    if (userResp.statusCode != 200) throw 'ユーザー情報取得失敗: ${userResp.body}';
    final userId = json.decode(userResp.body)['id'];
    for (final pl in playlists) {
      final plName = pl['playlist_name'];
      final plDesc = pl['description'] ?? '';
      // プレイリスト作成
      final createResp = await http.post(
        Uri.parse('https://api.spotify.com/v1/users/$userId/playlists'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'name': plName, 'description': plDesc, 'public': false}),
      );
      if (createResp.statusCode != 201) throw 'プレイリスト作成失敗: ${createResp.body}';
      final playlistId = json.decode(createResp.body)['id'];
      // 曲追加
      final uris = (pl['tracks'] as List)
        .map((t) => _findTrackUri(tracks, t['track_name'], t['artist_name']))
        .where((uri) => uri != null)
        .cast<String>()
        .toList();
      if (uris.isEmpty) continue;
      final addResp = await http.post(
        Uri.parse('https://api.spotify.com/v1/playlists/$playlistId/tracks'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'uris': uris}),
      );
      if (addResp.statusCode != 201) throw '曲追加失敗: ${addResp.body}';
    }
  }

  // 曲名・アーティスト名からSpotifyトラックURIを検索
  String? _findTrackUri(List<Map<String, dynamic>> tracks, String? name, String? artist) {
    for (final t in tracks) {
      final tName = t['name'] ?? '';
      final tArtists = (t['artists'] as List?)?.map((a) => a['name']).join(', ') ?? '';
      if (tName == name && tArtists == artist) {
        return t['uri'] as String?;
      }
    }
    return null;
  }

  // Gemini APIの利用可能モデル一覧を取得してprintするデバッグ関数
  Future<void> fetchGeminiModels(String apiKey) async {
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey');
    final response = await http.get(url);
    print('【DEBUG】モデル一覧: ${response.body}');
  }
}

final spotifyWebService = SpotifyWebService(); 