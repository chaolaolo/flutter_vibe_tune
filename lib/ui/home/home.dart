import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vibe_tune/ui/discovery/discovery.dart';
import 'package:vibe_tune/ui/home/viewModel.dart';
import 'package:vibe_tune/ui/now_playing/audio_player_manager.dart';
import 'package:vibe_tune/ui/now_playing/now_playing.dart';
import 'package:vibe_tune/ui/profile/user.dart';
import 'package:vibe_tune/ui/settings/settings.dart';

import '../../data/models/song.dart';

class VibeTuneApp extends StatelessWidget {
  const VibeTuneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vibe Tune',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Widget> _tabs = [
    const HomeTab(),
    const DiscoveryTab(),
    const AccountTab(),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.menu,
              color: Colors.blueGrey,
              size: 28,
            )),
        middle: const Text(
          "Vibe Tune",
          style: TextStyle(
            color: Colors.blueGrey,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Colors.blue.shade200,
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          activeColor: Colors.blue.shade200,
          inactiveColor: Colors.white,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.my_library_music_rounded), label: "Discovery"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
          ],
          backgroundColor: Colors.black87,
        ),
        tabBuilder: (BuildContext context, int index) {
          return _tabs[index];
        },
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabPage();
  }
}

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  List<Song> songs = [];
  late VibeTuneAppViewModel _viewModel;

  @override
  void initState() {
    _viewModel = VibeTuneAppViewModel();
    _viewModel.loadSongs();
    observeData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
    );
  }

  @override
  void dispose() {
    _viewModel.songStream.close();
    AudioPlayerManager().dispose();
    super.dispose();
  }

  //getBody
  Widget getBody() {
    bool showLoading = songs.isEmpty;
    if (showLoading) {
      return getProgressBar();
    } else {
      return getListView();
    }
  }

  //getListView
  Widget getListView() {
    return ListView.separated(
      itemBuilder: (context, position) {
        return getRow(position);
      },
      separatorBuilder: (context, index) {
        return const Divider(
          color: Colors.blueGrey,
          thickness: 0.4,
          indent: 24,
          endIndent: 24,
        );
      },
      itemCount: songs.length,
      shrinkWrap: true,
    );
  }

  // getRow
  Widget getRow(int index) {
    return _SongItemSection(
      parent: this,
      song: songs[index],
    );
  }

  //getProgressBar
  Widget getProgressBar() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  // observeData
  void observeData() {
    _viewModel.songStream.stream.listen((songList) {
      setState(() {
        songs.addAll(songList);
      });
    });
  }

  // showBottomSheet
  void showBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            child: Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey[100],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text("this is bottom sheet"),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close this sheet"),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  // navigate
  void navigate(Song song) {
    Navigator.push(context, CupertinoPageRoute(builder: (context) {
      return NowPlaying(
        songs: songs,
        playingSong: song,
      );
    }));
  }
}

//_songItemSection
class _SongItemSection extends StatelessWidget {
  const _SongItemSection({
    required this.parent,
    required this.song,
  });

  final _HomeTabPageState parent;
  final Song song;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: 24, right: 12),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: FadeInImage.assetNetwork(
          width: 50,
          height: 50,
          placeholder: 'assets/songLoading.png',
          fit: BoxFit.cover,
          image: song.image,
          imageErrorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/songLoading.png',
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            );
          },
        ),
      ),
      title: Text(
        song.title,
        style: TextStyle(color: Colors.black),
      ),
      subtitle: Text(song.artist),
      trailing: IconButton(
        icon: const Icon(Icons.more_horiz_rounded,color: Colors.blueGrey,),
        onPressed: () {
          parent.showBottomSheet(context);
        },
      ),
      onTap: () {
        parent.navigate(song);
      },
    );
  }
}