//{
//       "id": "1121429554",
//       "title": "Chạy Về Khóc Với Anh",
//       "album": "Chạy Về Khóc Với Anh(Single)",
//       "artist": "ERIK",
//       "source": "https://thantrieu.com/resources/music/1121429554.mp3",
//       "image": "https://thantrieu.com/resources/arts/1121429554.webp",
//       "duration": 224,
//       "favorite": "false",
//       "counter": 20,
//       "replay": 0
//     },

class Song {
  String id;
  String title;
  String album;
  String artist;
  String source;
  String image;
  int duration;

  Song({
    required this.id,
    required this.title,
    required this.album,
    required this.artist,
    required this.source,
    required this.image,
    required this.duration,
  });

  factory Song.fromJson(Map<String, dynamic> map) {
    return Song(
      id: map['id'],
      title: map['title'],
      album: map['album'],
      artist: map['artist'],
      source: map['source'],
      image: map['image'],
      duration: int.tryParse(map['duration'].toString()) ?? 0,
    );
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is Song && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Song{id: $id, title: $title, album: $album, artist: $artist, source: $source, image: $image, duration: $duration}';
  }
}
