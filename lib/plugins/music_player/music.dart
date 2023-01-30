/// Class to create instance of music to play using MusicPlayer
export 'player.dart';

class Music {
  Music({
    String? id,
    required this.url,
    required this.artist,
    required this.title,
    required this.image,
    this.album,
    this.duration,
  }) : this.id = id ?? url;

  /// Music ID
  final String id;

  /// Music File URL
  final String url;

  /// Music Singer
  final String artist;

  /// Music Album Name
  final String? album;

  /// Music Title
  final String title;

  /// Music Cover URL
  final String? image;

  /// Music Duration
  final Duration? duration;
}
