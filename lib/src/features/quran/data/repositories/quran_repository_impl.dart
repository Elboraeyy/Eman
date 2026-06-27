import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/quran_entities.dart';
import '../../domain/repositories/quran_repository.dart';

class QuranRepositoryImpl implements QuranRepository {
  final AppDatabase db;
  final Dio dio;

  // Memory caches
  List<Surah>? _cachedSurahs;
  List<Ayah>? _cachedJuzBoundaries;
  List<QcfVerse>? _cachedQcfVerses;
  Map<String, dynamic>? _cachedQcfLinesJson;
  Map<String, dynamic>? _cachedSurahHeadersJson;

  QuranRepositoryImpl({required this.db, required this.dio});

  // Mapper helpers
  Surah _mapSurahToDomain(SurahData s) {
    return Surah(
      number: s.number,
      name: s.name,
      nameArabic: s.nameArabic,
      nameEnglish: s.nameEnglish,
      englishNameTranslation: s.englishNameTranslation,
      revelationType: s.revelationType,
      numberOfAyahs: s.numberOfAyahs,
    );
  }

  Ayah _mapAyahToDomain(AyahData a) {
    return Ayah(
      number: a.number,
      numberInSurah: a.numberInSurah,
      surahNumber: a.surahNumber,
      text: a.textContent,
      textUthmani: a.textUthmani,
      juz: a.juz,
      page: a.page,
      sajda: a.sajda,
    );
  }

  @override
  Future<List<Surah>> getAllSurahs() async {
    if (_cachedSurahs != null) return _cachedSurahs!;

    final dbSurahs = await db.select(db.surahs).get();
    if (dbSurahs.isNotEmpty) {
      final surahs = dbSurahs.map(_mapSurahToDomain).toList();
      _cachedSurahs = surahs;
      return surahs;
    }

    // Fallback: load assets surahs
    try {
      final jsonStr = await rootBundle.loadString('assets/surahs.json');
      final List<dynamic> list = jsonDecode(jsonStr);
      final surahs = list.map((item) {
        return Surah(
          number: item['number'] as int,
          name: item['name'] as String,
          nameArabic: item['name'] as String,
          nameEnglish: item['englishName'] as String,
          englishNameTranslation: item['englishNameTranslation'] as String,
          revelationType: item['revelationType'] as String,
          numberOfAyahs: item['numberOfAyahs'] as int,
        );
      }).toList();
      _cachedSurahs = surahs;
      return surahs;
    } catch (e) {
      print('QuranRepositoryImpl: Failed to load surahs from assets fallback: $e');
      return [];
    }
  }

  @override
  Future<Surah?> getSurahByNumber(int number) async {
    final allSurahs = await getAllSurahs();
    final match = allSurahs.where((s) => s.number == number);
    return match.isNotEmpty ? match.first : null;
  }

  @override
  Future<List<Ayah>> getAyahsBySurah(int surahNumber) async {
    final localAyahs = await (db.select(db.ayahs)
          ..where((t) => t.surahNumber.equals(surahNumber))
          ..orderBy([(t) => OrderingTerm(expression: t.numberInSurah)]))
        .get();

    // If local text is empty, fetch from remote API and update database cache
    if (localAyahs.isEmpty || localAyahs.first.textContent.isEmpty) {
      try {
        final response = await dio.get('https://api.alquran.cloud/v1/surah/$surahNumber/quran-uthmani');
        if (response.statusCode == 200) {
          final data = response.data['data'];
          final List<dynamic> ayahsList = data['ayahs'];

          await db.transaction(() async {
            for (final item in ayahsList) {
              final numInSurah = item['numberInSurah'] as int;
              final text = item['text'] as String;

              await (db.update(db.ayahs)
                    ..where((t) => t.surahNumber.equals(surahNumber) & t.numberInSurah.equals(numInSurah)))
                  .write(AyahsCompanion(
                    textContent: Value(text),
                  ));
            }
          });
        }
      } catch (e) {
        print('QuranRepositoryImpl: Failed to sync plain text ayahs from remote API: $e');
      }
      
      // Fetch updated local ayahs
      final updatedLocal = await (db.select(db.ayahs)
            ..where((t) => t.surahNumber.equals(surahNumber))
            ..orderBy([(t) => OrderingTerm(expression: t.numberInSurah)]))
          .get();
      return updatedLocal.map(_mapAyahToDomain).toList();
    }

    return localAyahs.map(_mapAyahToDomain).toList();
  }

  @override
  Future<Ayah?> getAyah(int surahNumber, int ayahNumber) async {
    final result = await (db.select(db.ayahs)
          ..where((t) => t.surahNumber.equals(surahNumber) & t.numberInSurah.equals(ayahNumber))
          ..limit(1))
        .getSingleOrNull();
        
    return result != null ? _mapAyahToDomain(result) : null;
  }

  @override
  Future<List<Surah>> searchSurahs(String query) async {
    final allSurahs = await getAllSurahs();
    return allSurahs.where((s) {
      return s.nameArabic.contains(query) ||
             s.nameEnglish.toLowerCase().contains(query.toLowerCase()) ||
             s.name.contains(query);
    }).toList();
  }

  @override
  Future<List<Ayah>> searchAyat(String query) async {
    // Queries local SQLite text using LIKE syntax
    final matches = await (db.select(db.ayahs)
          ..where((t) => t.textContent.like('%$query%'))
          ..orderBy([(t) => OrderingTerm(expression: t.number)]))
        .get();
    return matches.map(_mapAyahToDomain).toList();
  }

  @override
  Future<List<Ayah>> getAyatByPage(int page) async {
    final matches = await (db.select(db.ayahs)
          ..where((t) => t.page.equals(page))
          ..orderBy([(t) => OrderingTerm(expression: t.number)]))
        .get();
    return matches.map(_mapAyahToDomain).toList();
  }

  @override
  Future<List<Ayah>> getAyatByJuz(int juz) async {
    final matches = await (db.select(db.ayahs)
          ..where((t) => t.juz.equals(juz))
          ..orderBy([(t) => OrderingTerm(expression: t.number)]))
        .get();
    return matches.map(_mapAyahToDomain).toList();
  }

  @override
  Future<List<Ayah>> getJuzBoundaries() async {
    if (_cachedJuzBoundaries != null) return _cachedJuzBoundaries!;

    try {
      final jsonStr = await rootBundle.loadString('assets/juz_boundaries.json');
      final List<dynamic> list = jsonDecode(jsonStr);
      final boundaries = list.map((item) {
        final juzNum = item['juz'] as int;
        return Ayah(
          number: 0,
          numberInSurah: item['ayah'] as int,
          surahNumber: item['surah'] as int,
          text: 'بداية الجزء $juzNum',
          textUthmani: '',
          juz: juzNum,
          page: 0,
          sajda: false,
        );
      }).toList();
      _cachedJuzBoundaries = boundaries;
      return boundaries;
    } catch (e) {
      print('QuranRepositoryImpl: Failed to load juz boundaries: $e');
      return [];
    }
  }

  @override
  Future<QcfPage> getQcfPage(int pageNumber) async {
    final headerLines = await _getSurahHeadersForPage(pageNumber);
    final headerLineNumbers = headerLines.map((h) => h.lineNumber).toSet();

    final linesMap = await _getQcfLinesForPage(pageNumber);
    final textLines = linesMap.entries
        .where((entry) => !headerLineNumbers.contains(int.tryParse(entry.key) ?? -1))
        .map((entry) => QcfLine(
              lineNumber: int.tryParse(entry.key) ?? 0,
              text: entry.value as String,
            ))
        .toList();

    final allLines = [...textLines, ...headerLines]..sort((a, b) => a.lineNumber.compareTo(b.lineNumber));

    // Get mapped verse positions for character highlights
    final allVerses = await _getQcfVerses();
    final pageVerses = allVerses.where((v) => v.page == pageNumber).toList();

    return QcfPage(
      pageNumber: pageNumber,
      lines: allLines,
      verses: pageVerses,
    );
  }

  @override
  Future<Map<int, int>> getSurahStartPages() async {
    final verses = await _getQcfVerses();
    if (verses.isEmpty) return {};

    final pageMap = <int, int>{};
    for (final verse in verses) {
      if (verse.ayahNumber == 1 && !pageMap.containsKey(verse.surahNumber)) {
        pageMap[verse.surahNumber] = verse.page;
      }
    }
    return pageMap;
  }

  @override
  Stream<List<Surah>> getSurahsStream() {
    return db.select(db.surahs).watch().map((list) => list.map<Surah>(_mapSurahToDomain).toList());
  }

  // Inner helpers
  Future<Map<String, dynamic>> _getQcfLinesForPage(int pageNumber) async {
    if (_cachedQcfLinesJson == null) {
      try {
        final jsonStr = await rootBundle.loadString('assets/qcf_lines.json');
        _cachedQcfLinesJson = jsonDecode(jsonStr) as Map<String, dynamic>;
      } catch (e) {
        print('QuranRepositoryImpl: Failed to load qcf_lines.json: $e');
        return {};
      }
    }

    final pageObj = _cachedQcfLinesJson?[pageNumber.toString()] as Map<String, dynamic>?;
    return pageObj ?? {};
  }

  Future<List<QcfLine>> _getSurahHeadersForPage(int pageNumber) async {
    if (_cachedSurahHeadersJson == null) {
      try {
        final jsonStr = await rootBundle.loadString('assets/surah_headers.json');
        _cachedSurahHeadersJson = jsonDecode(jsonStr) as Map<String, dynamic>;
      } catch (e) {
        print('QuranRepositoryImpl: Failed to load surah_headers.json: $e');
        return [];
      }
    }

    final pageArray = _cachedSurahHeadersJson?[pageNumber.toString()] as List<dynamic>?;
    if (pageArray == null) return [];

    return pageArray.map((item) {
      return QcfLine(
        lineNumber: item['lineNumber'] as int,
        text: '',
        surahNumber: item['surahNumber'] as int,
        isBismillah: item['isBismillah'] as bool,
      );
    }).toList();
  }

  Future<List<QcfVerse>> _getQcfVerses() async {
    if (_cachedQcfVerses != null) return _cachedQcfVerses!;

    // Load from database if populated
    final dbAyahs = await db.select(db.ayahs).get();
    if (dbAyahs.isNotEmpty) {
      final verses = dbAyahs.map((a) {
        return QcfVerse(
          id: a.number,
          surahNumber: a.surahNumber,
          ayahNumber: a.numberInSurah,
          codeV1: a.textUthmani,
          page: a.page,
        );
      }).toList();
      _cachedQcfVerses = verses;
      return verses;
    }

    // Fallback: parse assets qcf_quran.json
    try {
      final jsonStr = await rootBundle.loadString('assets/qcf_quran.json');
      final Map<String, dynamic> quranMap = jsonDecode(jsonStr);
      final List<dynamic> list = quranMap['verses'];
      final verses = list.map((item) {
        final verseKey = (item['verse_key'] as String).split(':');
        return QcfVerse(
          id: item['id'] as int,
          surahNumber: int.parse(verseKey[0]),
          ayahNumber: int.parse(verseKey[1]),
          codeV1: item['code_v1'] as String,
          page: item['v1_page'] as int,
        );
      }).toList();
      _cachedQcfVerses = verses;
      return verses;
    } catch (e) {
      print('QuranRepositoryImpl: Failed to load QCF mapping fallback: $e');
      return [];
    }
  }

  // Reading Progress Implementation
  @override
  Future<void> saveReadingProgress(int page) async {
    try {
      final match = await db.select(db.progress).getSingleOrNull();
      if (match == null) {
        await db.into(db.progress).insert(
          ProgressCompanion.insert(
            lastReadPage: page,
            updatedAt: Value(DateTime.now()),
          ),
        );
      } else {
        await (db.update(db.progress)..where((t) => t.id.equals(match.id)))
            .write(ProgressCompanion(
              lastReadPage: Value(page),
              updatedAt: Value(DateTime.now()),
            ));
      }
    } catch (e) {
      print('QuranRepositoryImpl: Failed to save reading progress: $e');
    }
  }

  @override
  Future<int> getLastReadPage() async {
    try {
      final match = await db.select(db.progress).getSingleOrNull();
      return match?.lastReadPage ?? 1;
    } catch (e) {
      print('QuranRepositoryImpl: Failed to get last read page: $e');
      return 1;
    }
  }

  // Verse Favorites Implementation
  @override
  Future<void> toggleVerseFavorite(int surahNumber, int ayahNumber) async {
    try {
      final match = await (db.select(db.favorites)
            ..where((t) => t.type.equals('ayah') & 
                           t.surahNumber.equals(surahNumber) & 
                           t.ayahNumber.equals(ayahNumber))
            ..limit(1))
          .getSingleOrNull();

      if (match != null) {
        await (db.delete(db.favorites)..where((t) => t.id.equals(match.id))).go();
      } else {
        final ayah = await getAyah(surahNumber, ayahNumber);
        final itemId = ayah?.number ?? (surahNumber * 1000 + ayahNumber);
        
        await db.into(db.favorites).insert(
          FavoritesCompanion.insert(
            type: 'ayah',
            itemId: itemId,
            surahNumber: Value(surahNumber),
            ayahNumber: Value(ayahNumber),
          ),
        );
      }
    } catch (e) {
      print('QuranRepositoryImpl: Failed to toggle verse favorite: $e');
    }
  }

  @override
  Future<bool> isVerseFavorite(int surahNumber, int ayahNumber) async {
    try {
      final match = await (db.select(db.favorites)
            ..where((t) => t.type.equals('ayah') & 
                           t.surahNumber.equals(surahNumber) & 
                           t.ayahNumber.equals(ayahNumber))
            ..limit(1))
          .getSingleOrNull();
      return match != null;
    } catch (e) {
      print('QuranRepositoryImpl: Failed to check verse favorite: $e');
      return false;
    }
  }

  @override
  Future<List<Ayah>> getFavoriteVerses() async {
    try {
      final list = await (db.select(db.favorites)..where((t) => t.type.equals('ayah'))).get();
      if (list.isEmpty) return [];

      final results = <Ayah>[];
      for (final fav in list) {
        if (fav.surahNumber != null && fav.ayahNumber != null) {
          final ayah = await getAyah(fav.surahNumber!, fav.ayahNumber!);
          if (ayah != null) {
            results.add(ayah);
          }
        }
      }
      return results;
    } catch (e) {
      print('QuranRepositoryImpl: Failed to get favorite verses: $e');
      return [];
    }
  }
}

