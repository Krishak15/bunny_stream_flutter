class BunnyVideo {
  final String? guid;
  final String? title;
  final String? thumbnail;
  final int? length;
  final int? views;
  final bool? isPublished;
  final int? dateUploaded;
  final String? storageZone;
  final String? previewUrl;

  BunnyVideo({
    this.guid,
    this.title,
    this.thumbnail,
    this.length,
    this.views,
    this.isPublished,
    this.dateUploaded,
    this.storageZone,
    this.previewUrl,
  });

  factory BunnyVideo.fromJson(Map<String, dynamic> json) {
    return BunnyVideo(
      guid: json['guid'] as String?,
      title: json['title'] as String?,
      thumbnail: json['thumbnail'] as String?,
      length: json['length'] as int?,
      views: json['views'] as int?,
      isPublished: json['isPublished'] as bool?,
      dateUploaded: json['dateUploaded'] as int?,
      storageZone: json['storageZone'] as String?,
      previewUrl: json['previewUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'guid': guid,
    'title': title,
    'thumbnail': thumbnail,
    'length': length,
    'views': views,
    'isPublished': isPublished,
    'dateUploaded': dateUploaded,
    'storageZone': storageZone,
    'previewUrl': previewUrl,
  };

  String get displayTitle => title ?? 'Untitled Video';
  String get thumbnailUrl => thumbnail ?? previewUrl ?? '';
}
