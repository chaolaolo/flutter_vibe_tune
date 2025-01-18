import 'package:flutter/material.dart';

import '../../data/models/song.dart';

class NowPlaying extends StatelessWidget {
  NowPlaying({
    super.key,
    required this.songs,
    required this.playingSong,
  });

  final List<Song> songs;
  final Song playingSong;

  @override
  Widget build(BuildContext context) {
    return NowPlayingPage(songs: songs, playingSong: playingSong);
  }
}

class NowPlayingPage extends StatefulWidget {
  NowPlayingPage({
    super.key,
    required this.songs,
    required this.playingSong,
  });

  final List<Song> songs;
  final Song playingSong;

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Now Playing"),
      ),
    );
  }
}
