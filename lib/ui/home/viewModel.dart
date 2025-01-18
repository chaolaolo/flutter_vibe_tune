import 'dart:async';

import 'package:vibe_tune/data/repositorys/repository.dart';

import '../../data/models/song.dart';

class VibeTuneAppViewModel {
  StreamController<List<Song>> songStream = StreamController();

  void loadSongs() {
    final repository = DefaultRepository();
    repository.loadData().then((value) => songStream.add(value!));
  }
}
