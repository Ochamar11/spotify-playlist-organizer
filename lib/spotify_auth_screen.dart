import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'spotify_web_service.dart';

class SpotifyAuthScreen extends StatefulWidget {
  final Function(String) onAuthSuccess;
  
  const SpotifyAuthScreen({Key? key, required this.onAuthSuccess}) : super(key: key);

  @override
  State<SpotifyAuthScreen> createState() => _SpotifyAuthScreenState();
}

class _SpotifyAuthScreenState extends State<SpotifyAuthScreen> {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              setState(() {
                _isLoading = progress < 100;
              });
            },
            onPageStarted: (String url) {
              setState(() {
                _isLoading = true;
              });
            },
            onPageFinished: (String url) {
              setState(() {
                _isLoading = false;
              });
            },
            onNavigationRequest: (NavigationRequest request) {
              // リダイレクトURIをチェック
              if (request.url.startsWith('wolfsort://callback')) {
                final uri = Uri.parse(request.url);
                final code = uri.queryParameters['code'];
                if (code != null) {
                  widget.onAuthSuccess(code);
                  Navigator.of(context).pop();
                }
                // ここでWebViewでの遷移を止める
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(SpotifyWebService().getAuthUrl()));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Spotify認証'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Web環境ではSpotify認証はサポートされていません'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spotify認証'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
} 