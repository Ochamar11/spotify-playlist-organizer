import 'package:flutter/material.dart';
import 'spotify_web_service.dart';

class TrackListScreen extends StatefulWidget {
  final String playlistId;
  final String playlistName;
  const TrackListScreen({Key? key, required this.playlistId, required this.playlistName}) : super(key: key);

  @override
  State<TrackListScreen> createState() => _TrackListScreenState();
}

class _TrackListScreenState extends State<TrackListScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _tracks = [];
  bool _isAisorting = false;
  String? _aiSortMessage;
  
  // 分類方法の選択肢
  final List<String> _sortTypes = ['ジャンル', '年代', 'シーン'];
  String _selectedSortType = 'ジャンル';

  @override
  void initState() {
    super.initState();
    _fetchTracks();
  }

  Future<void> _fetchTracks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final tracks = await spotifyWebService.getPlaylistTracks(widget.playlistId);
      setState(() {
        _tracks = tracks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '曲リストの取得に失敗しました: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _aiSortTracks() async {
    setState(() {
      _isAisorting = true;
      _aiSortMessage = null;
    });
    try {
      await spotifyWebService.aiSortTracks(_tracks, sortType: _selectedSortType);
      setState(() {
        _aiSortMessage = 'AIによる新しいプレイリストを作成しました！Spotifyアプリでご確認ください。';
      });
    } catch (e) {
      setState(() {
        _aiSortMessage = 'AI整理中にエラーが発生しました: $e';
      });
    } finally {
      setState(() {
        _isAisorting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('tracks: \\$_tracks');
    print('error: \\$_errorMessage');
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlistName),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: _tracks.length,
                            itemBuilder: (context, index) {
                              final track = _tracks[index];
                              final name = track['name'] ?? 'Unknown';
                              final artists = (track['artists'] as List?)?.map((a) => a['name']).join(', ') ?? '';
                              return ListTile(
                                leading: (track['album'] != null &&
                                          track['album']['images'] != null &&
                                          (track['album']['images'] as List).isNotEmpty)
                                    ? Image.network(
                                        track['album']['images'][0]['url'],
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.music_note, size: 40, color: Colors.grey),
                                title: Text(name),
                                subtitle: Text(artists),
                                onTap: () async {
                                  final trackId = track['id'];
                                  if (trackId != null) {
                                    await spotifyWebService.launchTrackOnSpotify(trackId);
                                  }
                                },
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('分類方法: ', style: TextStyle(fontSize: 16)),
                              DropdownButton<String>(
                                value: _selectedSortType,
                                items: _sortTypes.map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                )).toList(),
                                onChanged: _isAisorting ? null : (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedSortType = val;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: ElevatedButton.icon(
                            onPressed: _isAisorting ? null : _aiSortTracks,
                            icon: const Icon(Icons.auto_awesome),
                            label: const Text('AIで整理する'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        if (_aiSortMessage != null)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              _aiSortMessage!,
                              style: TextStyle(
                                color: _aiSortMessage!.contains('エラー') ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
          if (_isAisorting)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
} 