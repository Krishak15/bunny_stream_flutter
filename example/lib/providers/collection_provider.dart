import 'package:flutter/material.dart';
import 'package:bunny_stream_flutter_example/models/bunny_collection.dart';
import 'package:bunny_stream_flutter_example/repositories/collection_repository.dart';

class CollectionProvider extends ChangeNotifier {
  final CollectionRepository repository;

  CollectionProvider({required this.repository});

  List<BunnyCollection> _collections = <BunnyCollection>[];
  BunnyCollection? _selectedCollection;
  bool _isLoading = false;
  String? _errorMessage;

  List<BunnyCollection> get collections => _collections;
  BunnyCollection? get selectedCollection => _selectedCollection;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCollections({
    int page = 0,
    int itemsPerPage = 100,
    String? search,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _collections = await repository.listCollections(
        page: page,
        itemsPerPage: itemsPerPage,
        search: search,
      );
      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString();
      _collections = <BunnyCollection>[];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCollection(String collectionId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedCollection = await repository.getCollection();
      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString();
      _selectedCollection = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCollection(BunnyCollection collection) {
    _selectedCollection = collection;
    notifyListeners();
  }

  void clearSelection() {
    _selectedCollection = null;
    notifyListeners();
  }
}
