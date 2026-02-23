import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class BunnyBuiltInPlayerView extends StatelessWidget {
  const BunnyBuiltInPlayerView({
    super.key,
    required this.videoId,
    required this.libraryId,
    this.accessKey,
    this.token,
    this.expires,
    this.referer,
    this.isPortrait = false,
    this.isScreenShotProtectEnable = false,
    this.playIconAsset,
  });

  final String? accessKey;
  final String videoId;
  final int libraryId;
  final String? token;
  final int? expires;
  final String? referer;
  final bool isPortrait;
  final bool isScreenShotProtectEnable;
  final String? playIconAsset;

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return _BunnyAndroidBuiltInPlayerView(
        accessKey: accessKey,
        videoId: videoId,
        libraryId: libraryId,
        token: token,
        expires: expires,
        referer: referer,
        isPortrait: isPortrait,
        isScreenShotProtectEnable: isScreenShotProtectEnable,
      );
    }

    if (Platform.isIOS) {
      return UiKitView(
        viewType: 'bunny_stream_player_view_ios',
        layoutDirection: TextDirection.ltr,
        creationParams: <String, dynamic>{
          'accessKey': accessKey,
          'videoId': videoId,
          'libraryId': libraryId,
          'token': token,
          'expires': expires,
          'referer': referer,
          'playIconAsset': playIconAsset,
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    }

    return const SizedBox.shrink();
  }
}

class _BunnyAndroidBuiltInPlayerView extends StatelessWidget {
  const _BunnyAndroidBuiltInPlayerView({
    required this.accessKey,
    required this.videoId,
    required this.libraryId,
    required this.token,
    required this.expires,
    required this.referer,
    required this.isPortrait,
    required this.isScreenShotProtectEnable,
  });

  final String? accessKey;
  final String videoId;
  final int libraryId;
  final String? token;
  final int? expires;
  final String? referer;
  final bool isPortrait;
  final bool isScreenShotProtectEnable;

  @override
  Widget build(BuildContext context) {
    const viewType = 'bunny_stream_player_view_android';

    return PlatformViewLink(
      viewType: viewType,
      surfaceFactory: (context, controller) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (params) {
        return PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            viewType: viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: <String, dynamic>{
              'accessKey': accessKey,
              'videoId': videoId,
              'libraryId': libraryId,
              'token': token,
              'expires': expires,
              'referer': referer,
              'isPortrait': isPortrait,
              'isScreenShotProtectEnable': isScreenShotProtectEnable,
            },
            creationParamsCodec: const StandardMessageCodec(),
          )
          ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
          ..create();
      },
    );
  }
}
