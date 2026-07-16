import '../models/media_entry.dart';
import 'library_repository.dart';

class MemoryLibraryRepository implements LibraryRepository {
  final List<MediaEntry> _entries = [];
  int _nextId = 1;

  String nextId() => '${_nextId++}';

  @override
  List<MediaEntry> getAll() => List.unmodifiable(_entries);

  @override
  MediaEntry add(MediaEntry entry) {
    _entries.insert(0, entry);
    return entry;
  }

  @override
  MediaEntry? update(MediaEntry entry) {
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index == -1) return null;
    _entries[index] = entry;
    return entry;
  }

  @override
  void delete(String id) {
    _entries.removeWhere((e) => e.id == id);
  }
}
