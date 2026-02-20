class BunnyCollection {
  final int videoLibraryId;
  final String? guid;
  final String? name;
  final int videoCount;
  final int totalSize;
  final String? previewVideoIds;
  final List<String>? previewImageUrls;

  BunnyCollection({
    required this.videoLibraryId,
    this.guid,
    this.name,
    required this.videoCount,
    required this.totalSize,
    this.previewVideoIds,
    this.previewImageUrls,
  });

  factory BunnyCollection.fromJson(Map<String, dynamic> json) {
    return BunnyCollection(
      videoLibraryId: json['videoLibraryId'] as int? ?? 0,
      guid: json['guid'] as String?,
      name: json['name'] as String?,
      videoCount: json['videoCount'] as int? ?? 0,
      totalSize: json['totalSize'] as int? ?? 0,
      previewVideoIds: json['previewVideoIds'] as String?,
      previewImageUrls: (json['previewImageUrls'] as List?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'videoLibraryId': videoLibraryId,
    'guid': guid,
    'name': name,
    'videoCount': videoCount,
    'totalSize': totalSize,
    'previewVideoIds': previewVideoIds,
    'previewImageUrls': previewImageUrls,
  };

  String get displayName => name ?? 'Untitled Collection';
  String get thumbnailUrl =>
      previewImageUrls?.isNotEmpty ?? false ? previewImageUrls!.first : '';

  String? get firstPreviewVideoId {
    final rawValue = previewVideoIds?.trim();
    if (rawValue == null || rawValue.isEmpty) return null;

    final ids = rawValue
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty);

    return ids.isNotEmpty ? ids.first : null;
  }
}
