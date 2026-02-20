import 'dart:developer' as developer;
import 'package:bunny_stream_flutter_example/models/bunny_collection.dart';
import 'package:bunny_stream_flutter_example/services/dio_client.dart';

class CollectionRepository {
  final DioClient dioClient;
  final int libraryId;
  final String collectionId;

  CollectionRepository({
    required this.dioClient,
    required this.libraryId,
    required this.collectionId,
  });

  /// Fetch a single collection by ID
  Future<BunnyCollection> getCollection() async {
    try {
      // developer.log(
      //   'Fetching collection: /library/$libraryId/collections/$collectionId',
      //   name: 'CollectionRepository',
      // );

      final data = await dioClient.get(
        '/library/$libraryId/collections/$collectionId',
      );

      developer.log('Collection response: $data', name: 'CollectionRepository');

      return BunnyCollection.fromJson(data);
    } catch (e) {
      developer.log(
        'Failed to fetch collection: $e',
        name: 'CollectionRepository',
        error: e,
      );
      throw Exception('Failed to fetch collection: $e');
    }
  }

  /// Get single collection (the only available API endpoint)
  /// Note: Bunny Stream API only provides single collection retrieval,
  /// not a list endpoint. This method wraps getCollection() for consistency.
  Future<List<BunnyCollection>> listCollections({
    int page = 0,
    int itemsPerPage = 100,
    String? search,
  }) async {
    try {
      developer.log(
        'Note: Bunny API only supports single collection fetch. Using collection ID: $collectionId',
        name: 'CollectionRepository',
      );

      // Since there's only a single collection endpoint, fetch it and return as list
      final collection = await getCollection();
      return [collection];
    } catch (e) {
      developer.log(
        'Failed to fetch collection: $e',
        name: 'CollectionRepository',
        error: e,
      );
      throw Exception('Failed to fetch collection: $e');
    }
  }
}
