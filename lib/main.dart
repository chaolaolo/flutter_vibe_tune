import 'package:flutter/material.dart';
import 'package:vibe_tune/data/repositorys/repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var repository = DefaultRepository();
  var songs = await repository.loadData();
  if (songs != null) {
    for (var song in songs) {
      debugPrint(song.toString());
    }
  }
  // runApp(const VibeTuneApp());
}

class VibeTuneApp extends StatelessWidget {
  const VibeTuneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
