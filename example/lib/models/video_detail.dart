class VideoDetailsModel {
  final int? videoLibraryId;
  final String? guid;
  final String? title;
  final String? description;
  final DateTime? dateUploaded;
  final int? views;
  final bool? isPublic;
  final int? length;
  final int? status;
  final double? framerate;
  final int? rotation;
  final int? width;
  final int? height;
  final String? availableResolutions;
  final String? outputCodecs;
  final int? thumbnailCount;
  final int? encodeProgress;
  final int? storageSize;
  final List<dynamic>? captions;
  final bool? hasMP4Fallback;
  final String? collectionId;
  final String? thumbnailFileName;
  final String? thumbnailBlurhash;
  final int? averageWatchTime;
  final int? totalWatchTime;
  final String? category;
  final List<dynamic>? chapters;
  final List<dynamic>? moments;
  final List<dynamic>? metaTags;
  final List<TranscodingMessage>? transcodingMessages;
  final bool? jitEncodingEnabled;
  final String? smartGenerateStatus;
  final bool? hasOriginal;
  final String? originalHash;
  final bool? hasHighQualityPreview;

  VideoDetailsModel({
    this.videoLibraryId,
    this.guid,
    this.title,
    this.description,
    this.dateUploaded,
    this.views,
    this.isPublic,
    this.length,
    this.status,
    this.framerate,
    this.rotation,
    this.width,
    this.height,
    this.availableResolutions,
    this.outputCodecs,
    this.thumbnailCount,
    this.encodeProgress,
    this.storageSize,
    this.captions,
    this.hasMP4Fallback,
    this.collectionId,
    this.thumbnailFileName,
    this.thumbnailBlurhash,
    this.averageWatchTime,
    this.totalWatchTime,
    this.category,
    this.chapters,
    this.moments,
    this.metaTags,
    this.transcodingMessages,
    this.jitEncodingEnabled,
    this.smartGenerateStatus,
    this.hasOriginal,
    this.originalHash,
    this.hasHighQualityPreview,
  });

  factory VideoDetailsModel.fromJson(Map<String, dynamic> json) {
    return VideoDetailsModel(
      videoLibraryId: json['videoLibraryId'] as int?,
      guid: json['guid'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      dateUploaded: json['dateUploaded'] != null
          ? DateTime.tryParse(json['dateUploaded'] as String)
          : null,
      views: json['views'] as int?,
      isPublic: json['isPublic'] as bool?,
      length: json['length'] as int?,
      status: json['status'] as int?,
      framerate: (json['framerate'] as num?)?.toDouble(),
      rotation: json['rotation'] as int?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      availableResolutions: json['availableResolutions'] as String?,
      outputCodecs: json['outputCodecs'] as String?,
      thumbnailCount: json['thumbnailCount'] as int?,
      encodeProgress: json['encodeProgress'] as int?,
      storageSize: json['storageSize'] as int?,
      captions: json['captions'] as List<dynamic>?,
      hasMP4Fallback: json['hasMP4Fallback'] as bool?,
      collectionId: json['collectionId'] as String?,
      thumbnailFileName: json['thumbnailFileName'] as String?,
      thumbnailBlurhash: json['thumbnailBlurhash'] as String?,
      averageWatchTime: json['averageWatchTime'] as int?,
      totalWatchTime: json['totalWatchTime'] as int?,
      category: json['category'] as String?,
      chapters: json['chapters'] as List<dynamic>?,
      moments: json['moments'] as List<dynamic>?,
      metaTags: json['metaTags'] as List<dynamic>?,
      transcodingMessages: (json['transcodingMessages'] as List<dynamic>?)
          ?.map(
            (item) => TranscodingMessage.fromJson(_toStringDynamicMap(item)),
          )
          .toList(),
      jitEncodingEnabled: json['jitEncodingEnabled'] as bool?,
      smartGenerateStatus: json['smartGenerateStatus'] as String?,
      hasOriginal: json['hasOriginal'] as bool?,
      originalHash: json['originalHash'] as String?,
      hasHighQualityPreview: json['hasHighQualityPreview'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
    'videoLibraryId': videoLibraryId,
    'guid': guid,
    'title': title,
    'description': description,
    'dateUploaded': dateUploaded?.toIso8601String(),
    'views': views,
    'isPublic': isPublic,
    'length': length,
    'status': status,
    'framerate': framerate,
    'rotation': rotation,
    'width': width,
    'height': height,
    'availableResolutions': availableResolutions,
    'outputCodecs': outputCodecs,
    'thumbnailCount': thumbnailCount,
    'encodeProgress': encodeProgress,
    'storageSize': storageSize,
    'captions': captions,
    'hasMP4Fallback': hasMP4Fallback,
    'collectionId': collectionId,
    'thumbnailFileName': thumbnailFileName,
    'thumbnailBlurhash': thumbnailBlurhash,
    'averageWatchTime': averageWatchTime,
    'totalWatchTime': totalWatchTime,
    'category': category,
    'chapters': chapters,
    'moments': moments,
    'metaTags': metaTags,
    'transcodingMessages': transcodingMessages
        ?.map((item) => item.toJson())
        .toList(),
    'jitEncodingEnabled': jitEncodingEnabled,
    'smartGenerateStatus': smartGenerateStatus,
    'hasOriginal': hasOriginal,
    'originalHash': originalHash,
    'hasHighQualityPreview': hasHighQualityPreview,
  };

  /// Get video title, falls back to guid if title is empty/null
  String get displayTitle =>
      (title?.isNotEmpty == true) ? title! : (guid ?? 'Untitled');

  /// Get duration in minutes as string (e.g., "1.8 min")
  String? get durationMinutes =>
      length != null ? '${(length! / 60).toStringAsFixed(1)} min' : null;

  /// Get resolution list from availableResolutions string (e.g., ['360p', '720p', '1080p'])
  List<String> get resolutionList {
    if (availableResolutions?.isEmpty != false) return [];
    return availableResolutions!
        .split(',')
        .map((r) => r.trim())
        .where((r) => r.isNotEmpty)
        .toList();
  }

  /// Check the quality/profile of the video
  String get qualityProfile {
    final resolution = '$width x $height';
    if (width == null || height == null) return 'Unknown';
    return resolution;
  }
}

/// Safe conversion from dynamic object to Map<String, dynamic>
Map<String, dynamic> _toStringDynamicMap(dynamic obj) {
  if (obj is Map<String, dynamic>) return obj;
  if (obj is Map) {
    return Map<String, dynamic>.from(
      obj.map((key, value) => MapEntry(key.toString(), value)),
    );
  }
  return {};
}

class TranscodingMessage {
  final DateTime? timeStamp;
  final int? level;
  final int? issueCode;
  final String? message;
  final String? value;

  TranscodingMessage({
    this.timeStamp,
    this.level,
    this.issueCode,
    this.message,
    this.value,
  });

  factory TranscodingMessage.fromJson(Map<String, dynamic> json) {
    return TranscodingMessage(
      timeStamp: json['timeStamp'] != null
          ? DateTime.tryParse(json['timeStamp'] as String)
          : null,
      level: json['level'] as int?,
      issueCode: json['issueCode'] as int?,
      message: json['message'] as String?,
      value: json['value'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'timeStamp': timeStamp?.toIso8601String(),
    'level': level,
    'issueCode': issueCode,
    'message': message,
    'value': value,
  };
}
