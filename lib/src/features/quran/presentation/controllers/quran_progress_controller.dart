import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/shared_preferences_provider.dart';
import '../../data/repositories/quran_repository_provider.dart';
import '../../domain/entities/quran_entities.dart';
import '../../../tracker/data/repositories/tracker_repository_provider.dart';

// 1. Notifier for custom page bookmarks
class CustomBookmarksNotifier extends Notifier<List<CustomBookmark>> {
  @override
  List<CustomBookmark> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final jsonStr = prefs.getString('custom_bookmarks');
    if (jsonStr == null) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((item) => CustomBookmark.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addBookmark(CustomBookmark bookmark) async {
    final updated = [...state, bookmark];
    state = updated;
    await _saveToPrefs(updated);
  }

  Future<void> deleteBookmark(String id) async {
    final updated = state.where((b) => b.id != id).toList();
    state = updated;
    await _saveToPrefs(updated);
  }

  Future<void> moveBookmark(String id, int pageNum) async {
    final index = state.indexWhere((b) => b.id == id);
    if (index != -1) {
      final old = state[index];
      final updated = [...state];
      updated[index] = CustomBookmark(
        id: old.id,
        name: old.name,
        colorValue: old.colorValue,
        page: pageNum,
        createdAt: DateTime.now(),
      );
      state = updated;
      await _saveToPrefs(updated);
    }
  }

  Future<void> _saveToPrefs(List<CustomBookmark> list) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final jsonStr = jsonEncode(list.map((b) => b.toJson()).toList());
    await prefs.setString('custom_bookmarks', jsonStr);
  }
}

final customBookmarksNotifierProvider = NotifierProvider<CustomBookmarksNotifier, List<CustomBookmark>>(() {
  return CustomBookmarksNotifier();
});

// 2. Notifier for continue reading page progress
class LastReadPageNotifier extends Notifier<int> {
  @override
  int build() {
    _init();
    return 1;
  }

  Future<void> _init() async {
    final repo = ref.read(quranRepositoryProvider);
    final page = await repo.getLastReadPage();
    state = page;
  }

  Future<void> updatePage(int page) async {
    if (state == page) return;
    final prevPage = state;
    state = page;
    final repo = ref.read(quranRepositoryProvider);
    await repo.saveReadingProgress(page);

    // Auto-record page read in tracker stats
    try {
      final pagesDelta = (page - prevPage).abs();
      final trackerRepo = ref.read(trackerRepositoryProvider);
      await trackerRepo.recordQuranPagesRead(pagesDelta > 0 ? pagesDelta : 1);
    } catch (_) {}
  }
}

final lastReadPageNotifierProvider = NotifierProvider<LastReadPageNotifier, int>(() {
  return LastReadPageNotifier();
});
