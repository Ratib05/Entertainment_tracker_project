import '../models/media_entry.dart';

abstract class LibraryRepository {
  List<MediaEntry> getAll();

  MediaEntry add(MediaEntry entry);

  MediaEntry? update(MediaEntry entry);

  void delete(String id);
}
