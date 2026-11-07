import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/hadith_entities.dart';
import '../../domain/repositories/hadith_repository.dart';

class HadithRepositoryImpl implements HadithRepository {
  final AppDatabase db;

  HadithRepositoryImpl({required this.db});

  // Mapper helpers
  HadithBook _mapBookToDomain(HadithBookData b) {
    return HadithBook(
      id: b.id,
      title: b.title,
      author: b.author,
      description: b.description,
    );
  }

  HadithCategory _mapCategoryToDomain(HadithCategoryData c) {
    return HadithCategory(
      id: c.id,
      title: c.title,
    );
  }

  Hadith _mapHadithToDomain(HadithData h) {
    List<HadithVocab> vocabList = [];
    try {
      final List<dynamic> parsed = jsonDecode(h.vocabularyJson);
      vocabList = parsed.map((item) => HadithVocab.fromJson(item)).toList();
    } catch (e) {
      debugPrint('HadithRepositoryImpl: Failed to parse vocabulary JSON: $e');
    }

    List<String> lifeApps = [];
    try {
      final List<dynamic> parsed = jsonDecode(h.lifeApplicationsJson);
      lifeApps = parsed.cast<String>();
    } catch (e) {
      debugPrint('HadithRepositoryImpl: Failed to parse life applications JSON: $e');
    }

    return Hadith(
      id: h.id,
      bookId: h.bookId,
      categoryId: h.categoryId,
      narrator: h.narrator,
      text: h.textContent,
      source: h.source,
      explanation: h.explanation,
      vocabulary: vocabList,
      lifeApplications: lifeApps,
    );
  }

  @override
  Future<List<HadithBook>> getAllBooks() async {
    final books = await db.select(db.hadithBooks).get();
    return books.map(_mapBookToDomain).toList();
  }

  @override
  Future<List<HadithCategory>> getAllCategories() async {
    final categories = await db.select(db.hadithCategories).get();
    return categories.map(_mapCategoryToDomain).toList();
  }

  @override
  Future<List<Hadith>> getHadithsByBook(int bookId) async {
    final hadiths = await (db.select(db.hadiths)
          ..where((t) => t.bookId.equals(bookId))
          ..orderBy([(t) => OrderingTerm(expression: t.id)]))
        .get();
    return hadiths.map(_mapHadithToDomain).toList();
  }

  @override
  Future<List<Hadith>> getHadithsByCategory(int categoryId) async {
    final hadiths = await (db.select(db.hadiths)
          ..where((t) => t.categoryId.equals(categoryId))
          ..orderBy([(t) => OrderingTerm(expression: t.id)]))
        .get();
    return hadiths.map(_mapHadithToDomain).toList();
  }

  @override
  Future<Hadith?> getHadithById(int id) async {
    final result = await (db.select(db.hadiths)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
    return result != null ? _mapHadithToDomain(result) : null;
  }

  @override
  Future<List<Hadith>> searchHadiths(String query) async {
    final matches = await (db.select(db.hadiths)
          ..where((t) => t.textContent.like('%$query%') |
                         t.narrator.like('%$query%') |
                         t.explanation.like('%$query%'))
          ..orderBy([(t) => OrderingTerm(expression: t.id)]))
        .get();
    return matches.map(_mapHadithToDomain).toList();
  }

  @override
  Future<void> toggleBookmark(int hadithId) async {
    final match = await (db.select(db.favorites)
          ..where((t) => t.type.equals('hadith') & t.hadithId.equals(hadithId))
          ..limit(1))
        .getSingleOrNull();

    if (match != null) {
      await (db.delete(db.favorites)..where((t) => t.id.equals(match.id))).go();
    } else {
      await db.into(db.favorites).insert(
        FavoritesCompanion.insert(
          type: 'hadith',
          itemId: hadithId,
          hadithId: Value(hadithId),
        ),
      );
    }
  }

  @override
  Future<bool> isBookmarked(int hadithId) async {
    final match = await (db.select(db.favorites)
          ..where((t) => t.type.equals('hadith') & t.hadithId.equals(hadithId))
          ..limit(1))
        .getSingleOrNull();
    return match != null;
  }

  @override
  Future<List<Hadith>> getBookmarkedHadiths() async {
    final bookmarkedFavorites = await (db.select(db.favorites)
          ..where((t) => t.type.equals('hadith')))
        .get();
        
    if (bookmarkedFavorites.isEmpty) return [];
    
    final ids = bookmarkedFavorites.map((f) => f.hadithId).whereType<int>().toList();
    
    final matches = await (db.select(db.hadiths)
          ..where((t) => t.id.isIn(ids))
          ..orderBy([(t) => OrderingTerm(expression: t.id)]))
        .get();
        
    return matches.map(_mapHadithToDomain).toList();
  }
}
