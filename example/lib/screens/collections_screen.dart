import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bunny_stream_flutter_example/providers/collection_provider.dart';
import 'package:bunny_stream_flutter_example/screens/collection_videos_screen.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CollectionProvider>().fetchCollections();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bunny Collections'), centerTitle: true),
      body: Consumer<CollectionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${provider.errorMessage}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchCollections(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.collections.isEmpty) {
            return const Center(child: Text('No collections found'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchCollections(),
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: provider.collections.length,
              itemBuilder: (context, index) {
                final collection = provider.collections[index];
                return _CollectionCard(
                  collection: collection,
                  onTap: () {
                    provider.selectCollection(collection);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            CollectionVideosScreen(collection: collection),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final dynamic collection;
  final VoidCallback onTap;

  const _CollectionCard({required this.collection, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                color: Colors.grey[300],
                width: double.infinity,
                child: collection.thumbnailUrl.isNotEmpty
                    ? Image.network(
                        collection.thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[400],
                            child: const Center(
                              child: Icon(Icons.image, size: 48),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[400],
                        child: const Center(
                          child: Icon(Icons.library_add, size: 48),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collection.displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${collection.videoCount} videos',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
