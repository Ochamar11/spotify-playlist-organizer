import 'package:flutter/material.dart';
import 'spotify_web_service.dart';
import 'spotify_auth_screen.dart';
import 'track_list_screen.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  List<Map<String, dynamic>> _playlists = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    if (!spotifyWebService.isAuthenticated) {
      setState(() {
        _errorMessage = 'Spotifyにログインしてください';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final playlists = await spotifyWebService.getPlaylists();
      setState(() {
        _playlists = playlists;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'プレイリストの取得に失敗しました: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _authenticateWithSpotify() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpotifyAuthScreen(
          onAuthSuccess: (authCode) async {
            final success = await spotifyWebService.getAccessToken(authCode);
            if (success) {
              await _loadPlaylists();
            } else {
              setState(() {
                _errorMessage = '認証に失敗しました';
              });
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // ヘッダー部分
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your Playlists',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    if (!spotifyWebService.isAuthenticated)
                      ElevatedButton(
                        onPressed: _authenticateWithSpotify,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Spotify連携'),
                      ),
                  ],
                ),
              ),
              
              // エラーメッセージ
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              
              // ローディング表示
              if (_isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                // プレイリスト一覧
                Expanded(
                  child: _playlists.isEmpty
                      ? const Center(
                          child: Text(
                            'プレイリストがありません',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _playlists.length,
                          itemBuilder: (context, index) {
                            final playlist = _playlists[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 24.0),
                              child: InkWell(
                                onTap: () {
                                  print('Tapped: \\${playlist['name']} (id: \\${playlist['id']})');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TrackListScreen(
                                        playlistId: playlist['id'],
                                        playlistName: playlist['name'] ?? 'Playlist',
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      playlist['name'] ?? 'Unknown Playlist',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    AspectRatio(
                                      aspectRatio: 4 / 3,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: playlist['images'] != null &&
                                                (playlist['images'] as List).isNotEmpty
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Image.network(
                                                  playlist['images'][0]['url'],
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Container(
                                                      color: Colors.grey[200],
                                                      child: const Icon(
                                                        Icons.music_note,
                                                        size: 50,
                                                        color: Colors.grey,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              )
                                            : Container(
                                                color: Colors.grey[200],
                                                child: const Icon(
                                                  Icons.music_note,
                                                  size: 50,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}