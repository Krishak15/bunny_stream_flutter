import 'package:bunny_stream_flutter/bunny_stream_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config_extended.dart';
import 'models/player_mode.dart';
import 'providers/collection_provider.dart';
import 'repositories/collection_repository.dart';
import 'screens/collections_screen.dart';
import 'services/dio_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BunnyConfig.load();
  runApp(const BunnyExampleApp());
}

class BunnyExampleApp extends StatefulWidget {
  const BunnyExampleApp({super.key});

  @override
  State<BunnyExampleApp> createState() => _BunnyExampleAppState();
}

class _BunnyExampleAppState extends State<BunnyExampleApp> {
  PlayerMode _selectedPlayerMode = PlayerMode.custom;

  @override
  Widget build(BuildContext context) {
    final bunny = BunnyStreamFlutter();

    return MaterialApp(
      title: 'Bunny Stream Flutter Example',
      home: _buildHome(bunny),
      theme: ThemeData(useMaterial3: true),
    );
  }

  Widget _buildHome(BunnyStreamFlutter bunny) {
    if (!BunnyConfig.isConfigured) {
      return const ConfigErrorScreen();
    }

    final dioClient = DioClient(accessKey: BunnyConfig.accessKey);
    final repository = CollectionRepository(
      dioClient: dioClient,
      libraryId: BunnyConfig.libraryId,
      collectionId: BunnyConfig.collectionId,
    );

    return ChangeNotifierProvider<CollectionProvider>(
      create: (_) => CollectionProvider(repository: repository),
      child: CollectionsScreen(
        playerMode: _selectedPlayerMode,
        onPlayerModeChanged: (mode) {
          if (mode == _selectedPlayerMode) return;
          setState(() {
            _selectedPlayerMode = mode;
          });
        },
      ),
    );
  }
}

class ConfigErrorScreen extends StatelessWidget {
  const ConfigErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuration Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Missing configuration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please ensure .env file is set up with:\n'
              '- BUNNY_LIBRARY_ID\n'
              '- BUNNY_ACCESS_KEY',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SelectableText(
              BunnyConfig.debugStatus(),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
