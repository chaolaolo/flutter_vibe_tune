import 'dart:math';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../data/models/song.dart';
import 'audio_player_manager.dart';

class NowPlaying extends StatelessWidget {
  const NowPlaying({
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
  const NowPlayingPage({
    super.key,
    required this.songs,
    required this.playingSong,
  });

  final List<Song> songs;
  final Song playingSong;

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> with SingleTickerProviderStateMixin {
  late AnimationController _imageAnimController;
  late AudioPlayerManager _audioPlayerManager;
  late int _selectedItemIndex;
  late Song _song;
  double _currentAnimationPosition = 0.0;
  bool _isShuffle = false;
  late LoopMode _loopMode;

  @override
  void initState() {
    super.initState();
    _song = widget.playingSong;
    _currentAnimationPosition = 0.0;
    _imageAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 12000));
    _audioPlayerManager = AudioPlayerManager();
    if (_audioPlayerManager.songUrl.compareTo(_song.source) != 0) {
      _audioPlayerManager.updateSongUrl(_song.source);
      _audioPlayerManager.prepare(isNewSong: true);
    } else {
      _audioPlayerManager.prepare(isNewSong: false);
    }
    _selectedItemIndex = widget.songs.indexOf(_song);
    _loopMode = LoopMode.off;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const delta = 64;
    final radius = (screenWidth - delta) / 2;

    return CupertinoPageScaffold(
      backgroundColor: Colors.blue.shade200,
      navigationBar: CupertinoNavigationBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            size: 26,
            CupertinoIcons.back, // Biểu tượng back
            color: Colors.blueGrey, // Đổi màu nút back tại đây
          ),
        ),
        middle: const Text(
          "Now Playing",
          style: TextStyle(
            color: Colors.blueGrey,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.more_horiz_outlined,
            color: Colors.blueGrey,
          ),
        ),
      ),
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              Text(
                _song.album,
                style: TextStyle(color: Colors.black),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text("_ __ ___ __ _"),
              const SizedBox(
                height: 20,
              ),
              RotationTransition(
                turns: Tween(begin: 0.0, end: 1.0).animate(_imageAnimController),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: FadeInImage.assetNetwork(
                      width: screenWidth - delta,
                      height: screenWidth - delta,
                      placeholder: 'assets/songLoading.png',
                      fit: BoxFit.cover,
                      image: _song.image,
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/songLoading.png',
                          width: screenWidth - delta,
                          height: screenWidth - delta,
                        );
                      }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 10),
                child: SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.share_rounded),
                      ),
                      Column(
                        children: [
                          Text(
                            _song.title,
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            _song.artist,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.favorite_border_outlined),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 20,
                  left: 24,
                  right: 24,
                  bottom: 10,
                ),
                child: _progressBar(),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 0,
                  left: 24,
                  right: 24,
                  bottom: 0,
                ),
                child: _mediaButtons(),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _imageAnimController.dispose();
    super.dispose();
  }

  // _mediaButtons
  Widget _mediaButtons() {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MediaButtonControl(
            function: _setShuffle,
            icon: Icons.shuffle,
            color: _getShuffleColor(),
            size: 24,
          ),
          MediaButtonControl(
            function: _setPreviousSong,
            icon: Icons.skip_previous,
            color: Colors.blue.shade400,
            size: 36,
          ),
          // MediaButtonControl(
          //   function: null,
          //   icon: Icons.play_arrow,
          //   color: Colors.grey,
          //   size: 46,
          // ),
          _playerButton(),
          MediaButtonControl(
            function: _setNextSong,
            icon: Icons.skip_next,
            color: Colors.blue.shade400,
            size: 36,
          ),
          MediaButtonControl(
            function: _setLoopOption,
            icon: repeatIcon(),
            color: _getRepeatColor(),
            size: 24,
          ),
        ],
      ),
    );
  }

  // _progressBar
  StreamBuilder<DurationState> _progressBar() {
    return StreamBuilder<DurationState>(
      stream: _audioPlayerManager.durationState,
      builder: (context, snapshot) {
        final durationState = snapshot.data;
        final progress = durationState?.progress ?? Duration.zero;
        final buffered = durationState?.buffered ?? Duration.zero;
        final total = durationState?.total ?? Duration.zero;
        return ProgressBar(
          progress: progress,
          total: total,
          buffered: buffered,
          onSeek: (duration) {
            _audioPlayerManager.player.seek(duration);
          },
          baseBarColor: Colors.blue.shade50,
          bufferedBarColor: Colors.blue.shade100,
          progressBarColor: Colors.blue,
          thumbColor: Colors.blue,
          barHeight: 5,
          timeLabelTextStyle: const TextStyle(
            color: Colors.blueGrey,
            fontWeight: FontWeight.w600,
          ),
        );
      },
    );
  }

  // StreamBuilder  _playerButton
  StreamBuilder<PlayerState> _playerButton() {
    return StreamBuilder(
        stream: _audioPlayerManager.player.playerStateStream,
        builder: (context, snapshot) {
          final playState = snapshot.data;
          final processingState = playState?.processingState;
          final playing = playState?.playing;
          if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
            _pauseRotateAnimation();
            return Container(
              margin: EdgeInsets.all(6),
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                color: Colors.blue.shade700,
              ),
            );
          } else if (playing != true) {
            return MediaButtonControl(
                function: () {
                  _audioPlayerManager.player.play();
                  _imageAnimController.forward(from: _currentAnimationPosition);
                  _imageAnimController.repeat();
                },
                icon: Icons.play_arrow,
                color: Colors.blue.shade700,
                size: 48);
          } else if (processingState != ProcessingState.completed) {
            _startRotateAnimation();
            return MediaButtonControl(
                function: () {
                  _audioPlayerManager.player.pause();
                  _imageAnimController.stop();
                  _currentAnimationPosition = _imageAnimController.value;
                  _pauseRotateAnimation();
                },
                icon: Icons.pause,
                color: Colors.blue.shade700,
                size: 48);
          } else {
            if (processingState == ProcessingState.completed) {
              _stopRotateAnimation();
              _resetRotateAnimation();
            }
            return MediaButtonControl(
              function: () {
                _currentAnimationPosition = 0.0;
                _imageAnimController.forward(from: _currentAnimationPosition);
                _imageAnimController.repeat();
                _audioPlayerManager.player.seek(Duration.zero); //quay lại từ đầu
                _resetRotateAnimation();
                _startRotateAnimation();
              },
              icon: Icons.replay,
              color: Colors.blue.shade700,
              size: 46,
            );
          }
        });
  }

  // void _setNextSong()
  void _setNextSong() {
    if (_isShuffle) {
      var random = Random();
      _selectedItemIndex = random.nextInt(widget.songs.length);
    } else if (_selectedItemIndex < widget.songs.length - 1) {
      ++_selectedItemIndex;
    } else if (_loopMode == LoopMode.all && _selectedItemIndex == widget.songs.length - 1) {
      _selectedItemIndex = 0;
    }
    if (_selectedItemIndex >= widget.songs.length) {
      _selectedItemIndex = _selectedItemIndex % widget.songs.length;
    }
    final nextSong = widget.songs[_selectedItemIndex];
    _audioPlayerManager.updateSongUrl(nextSong.source);
    _resetRotateAnimation();
    setState(() {
      _song = nextSong;
    });
  }

  // void _setPreviousSong()
  void _setPreviousSong() {
    if (_isShuffle) {
      var random = Random();
      _selectedItemIndex = random.nextInt(widget.songs.length);
    } else if (_selectedItemIndex > 0) {
      --_selectedItemIndex;
    } else if (_loopMode == LoopMode.all && _selectedItemIndex == 0) {
      _selectedItemIndex = widget.songs.length - 1;
    }
    if (_selectedItemIndex < 0) {
      _selectedItemIndex = (-1 * _selectedItemIndex) % widget.songs.length;
    }
    final nextSong = widget.songs[_selectedItemIndex];
    _audioPlayerManager.updateSongUrl(nextSong.source);
    _resetRotateAnimation();
    setState(() {
      _song = nextSong;
    });
  }

  Color? _getShuffleColor() {
    return _isShuffle ? Colors.blue : Colors.blueGrey;
  }

  // void _setShuffle()
  void _setShuffle() {
    setState(() {
      _isShuffle = !_isShuffle;
    });
  }

  //void repeatIcon() {}
  IconData repeatIcon() {
    return switch (_loopMode) {
      LoopMode.one => Icons.repeat_one,
      LoopMode.all => Icons.repeat_on,
      _ => Icons.repeat,
    };
  }

  // _getRepeatColor
  Color? _getRepeatColor() {
    return _loopMode == LoopMode.off ? Colors.blueGrey : Colors.blue;
  }

  // void _setLoopOption()
  void _setLoopOption() {
    if (_loopMode == LoopMode.off) {
      _loopMode = LoopMode.one;
    } else if (_loopMode == LoopMode.one) {
      _loopMode = LoopMode.all;
    } else {
      _loopMode = LoopMode.off;
    }
    setState(() {
      _audioPlayerManager.player.setLoopMode(_loopMode);
    });
  }

  void _startRotateAnimation() {
    _imageAnimController.forward(from: _currentAnimationPosition);
    _imageAnimController.repeat();
  }

  void _pauseRotateAnimation() {
    _stopRotateAnimation();
    _currentAnimationPosition = _imageAnimController.value;
  }

  void _stopRotateAnimation() {
    _imageAnimController.stop();
  }

  void _resetRotateAnimation() {
    _currentAnimationPosition = 0.0;
    _imageAnimController.value = _currentAnimationPosition;
  }
}

// class MediaButtonControl
class MediaButtonControl extends StatefulWidget {
  const MediaButtonControl({super.key, required this.function, required this.icon, required this.color, required this.size});

  final void Function()? function;
  final IconData icon;
  final double? size;
  final Color? color;

  @override
  State<StatefulWidget> createState() => MediaButtonControlState();
}

// class MediaButtonControlState
class MediaButtonControlState extends State<MediaButtonControl> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.function,
      icon: Icon(widget.icon),
      iconSize: widget.size,
      color: widget.color ?? Theme.of(context).colorScheme.primary,
    );
  }
}