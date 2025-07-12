import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'playlist_screen.dart';
import 'spotify_web_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // .envファイルを読み込み
  await dotenv.load(fileName: ".env");
  
  // Geminiモデル一覧を自動取得
  final geminiApiKey = dotenv.env['GEMINI_API_KEY'];
  if (geminiApiKey != null && geminiApiKey.isNotEmpty && geminiApiKey != 'your_gemini_api_key_here') {
    await spotifyWebService.fetchGeminiModels(geminiApiKey);
  } else {
    print('警告: GEMINI_API_KEYが設定されていません。AI機能は利用できません。');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.light(),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ロゴ
            Image.asset(
              'assets/Gemini_Generated_Image_ma22y3ma22y3ma22.png',
              width: 200,
              height: 200,
            ),
            
            const SizedBox(height: 24),

            // タイトル
            const Text(
              'The Best Music Experience\n Starts with an Organized Library.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 60),

            // プレイリスト画面へのボタン
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PlaylistScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text(
                'プレイリストを見る',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 認証情報クリアボタン
            ElevatedButton(
              onPressed: () {
                spotifyWebService.clearAuth();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('認証情報をクリアしました。再度認証してください。'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text(
                '認証情報をクリア',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}