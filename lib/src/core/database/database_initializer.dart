import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart';
import 'app_database.dart';

class DatabaseInitializer {
  final AppDatabase db;

  DatabaseInitializer(this.db);

  Future<void> initializeDatabase() async {
    try {
      // 1. Initialize Quran Core
      final surahsCount = await (db.select(db.surahs)..limit(1)).get();
      if (surahsCount.isEmpty) {
        await _initializeQuranCore();
      }

      // 2. Initialize Adhkar
      final adhkarCount = await (db.select(db.adhkarCategories)..limit(1)).get();
      if (adhkarCount.isEmpty) {
        await _initializeAdhkar();
      }

      // 3. Initialize Hadiths
      final hadithCount = await (db.select(db.hadiths)..limit(1)).get();
      if (hadithCount.isEmpty) {
        await db.delete(db.hadithBooks).go();
        await db.delete(db.hadithCategories).go();
        await _initializeHadiths();
      }
      
      // 4. Initialize Default Spiritual Tasks
      final taskCount = await (db.select(db.religiousTasks)..limit(1)).get();
      if (taskCount.isEmpty) {
        await _initializeDefaultTasks();
      }
    } catch (e) {
      debugPrint('DatabaseInitializer Error: Failed to initialize database: $e');
    }
  }

  Future<void> _initializeQuranCore() async {
    debugPrint('Initializing Quran database tables...');
    
    // Load Surahs JSON
    final surahsJsonStr = await rootBundle.loadString('assets/surahs.json');
    final List<dynamic> surahsList = jsonDecode(surahsJsonStr);
    
    await db.batch((batch) {
      batch.insertAll(
        db.surahs,
        surahsList.map((item) {
          return SurahsCompanion.insert(
            number: Value(item['number'] as int),
            name: item['name'] as String,
            nameArabic: item['name'] as String,
            nameEnglish: item['englishName'] as String,
            englishNameTranslation: item['englishNameTranslation'] as String,
            revelationType: item['revelationType'] as String,
            numberOfAyahs: item['numberOfAyahs'] as int,
          );
        }).toList(),
      );
    });

    // Load Quran verses JSON
    final qcfQuranJsonStr = await rootBundle.loadString('assets/qcf_quran.json');
    final Map<String, dynamic> quranMap = jsonDecode(qcfQuranJsonStr);
    final List<dynamic> versesList = quranMap['verses'] as List<dynamic>;

    // Load Juz Boundaries mapping
    final juzBoundariesJsonStr = await rootBundle.loadString('assets/juz_boundaries.json');
    final List<dynamic> juzBoundaries = jsonDecode(juzBoundariesJsonStr);

    // Chunk size for batch insertions to avoid SQLite variable limits (999 limit in older SQLite)
    const chunkSize = 250;
    for (var i = 0; i < versesList.length; i += chunkSize) {
      final end = (i + chunkSize < versesList.length) ? i + chunkSize : versesList.length;
      final chunk = versesList.sublist(i, end);

      await db.batch((batch) {
        batch.insertAll(
          db.ayahs,
          chunk.map((item) {
            final verseKey = (item['verse_key'] as String).split(':');
            final surahNumber = int.parse(verseKey[0]);
            final ayahNumber = int.parse(verseKey[1]);
            final juz = _calculateJuz(surahNumber, ayahNumber, juzBoundaries);

            return AyahsCompanion.insert(
              number: item['id'] as int,
              numberInSurah: ayahNumber,
              surahNumber: surahNumber,
              textContent: '', // To be updated from remote API or assets if text exists, Uthmani holds glyphs
              textUthmani: item['code_v1'] as String,
              juz: juz,
              hizb: 0,
              manzil: 0,
              ruku: 0,
              page: item['v1_page'] as int,
              sajda: const Value(false),
            );
          }).toList(),
        );
      });
    }
    
    debugPrint('Quran Core tables successfully populated.');
  }

  Future<void> _initializeAdhkar() async {
    debugPrint('Initializing Adhkar database tables...');
    final adhkarJsonStr = await rootBundle.loadString('assets/adhkar.json');
    final Map<String, dynamic> adhkarMap = jsonDecode(adhkarJsonStr);
    final List<dynamic> categoriesList = adhkarMap['categories'] as List<dynamic>;

    for (final catItem in categoriesList) {
      final categoryId = catItem['id'] as int;
      
      await db.into(db.adhkarCategories).insert(
        AdhkarCategoriesCompanion.insert(
          id: Value(categoryId),
          title: catItem['title'] as String,
          description: Value(catItem['description'] as String? ?? ''),
        ),
      );

      final List<dynamic> itemsList = catItem['items'] as List<dynamic>;
      await db.batch((batch) {
        batch.insertAll(
          db.adhkarItems,
          itemsList.map((item) {
            return AdhkarItemsCompanion.insert(
              id: Value(item['id'] as int),
              categoryId: categoryId,
              textContent: item['text'] as String,
              targetCount: item['count'] as int,
              reference: Value(item['reference'] as String? ?? ''),
            );
          }).toList(),
        );
      });
    }
    debugPrint('Adhkar tables successfully populated.');
  }

  Future<void> _initializeHadiths() async {
    debugPrint('Initializing Hadiths database tables...');
    final hadithsJsonStr = await rootBundle.loadString('assets/hadiths.json');
    final Map<String, dynamic> hadithMap = jsonDecode(hadithsJsonStr);

    final List<dynamic> booksList = hadithMap['books'] as List<dynamic>;
    await db.batch((batch) {
      batch.insertAll(
        db.hadithBooks,
        booksList.map((item) {
          return HadithBooksCompanion.insert(
            id: Value(item['id'] as int),
            title: item['title'] as String,
            author: Value(item['author'] as String? ?? ''),
            description: Value(item['description'] as String? ?? ''),
          );
        }).toList(),
      );
    });

    final List<dynamic> categoriesList = hadithMap['categories'] as List<dynamic>;
    await db.batch((batch) {
      batch.insertAll(
        db.hadithCategories,
        categoriesList.map((item) {
          return HadithCategoriesCompanion.insert(
            id: Value(item['id'] as int),
            title: item['title'] as String,
          );
        }).toList(),
      );
    });

    final List<dynamic> hadithsList = hadithMap['hadiths'] as List<dynamic>;
    const chunkSize = 200;
    for (var i = 0; i < hadithsList.length; i += chunkSize) {
      final end = (i + chunkSize < hadithsList.length) ? i + chunkSize : hadithsList.length;
      final chunk = hadithsList.sublist(i, end);

      await db.batch((batch) {
        batch.insertAll(
          db.hadiths,
          chunk.map((item) {
            return HadithsCompanion.insert(
              id: Value(item['id'] as int),
              bookId: item['bookId'] as int,
              categoryId: item['categoryId'] as int,
              narrator: Value(item['narrator'] as String? ?? ''),
              textContent: item['text'] as String,
              source: Value(item['source'] as String? ?? ''),
              explanation: Value(item['explanation'] as String? ?? ''),
              vocabularyJson: Value(jsonEncode(item['vocabulary'] ?? [])),
              lifeApplicationsJson: Value(jsonEncode(item['lifeApplications'] ?? [])),
            );
          }).toList(),
        );
      });
    }
    debugPrint('Hadith tables successfully populated.');
  }

  Future<void> _initializeDefaultTasks() async {
    debugPrint('Initializing default religious tasks...');
    final defaultTasks = [
      'الصلوات الخمس في أوقاتها',
      'صلاة الضحى',
      'قيام الليل والوتر',
      'قراءة الورد القرآني اليومي',
      'أذكار الصباح والمساء',
      'الصدقة اليومية',
    ];

    await db.batch((batch) {
      batch.insertAll(
        db.religiousTasks,
        defaultTasks.map((title) {
          return ReligiousTasksCompanion.insert(
            title: title,
            type: const Value('default'),
            frequency: const Value('daily'),
          );
        }).toList(),
      );
    });
    debugPrint('Default religious tasks populated.');
  }

  int _calculateJuz(int surah, int ayah, List<dynamic> boundaries) {
    for (var i = boundaries.length - 1; i >= 0; i--) {
      final boundary = boundaries[i];
      final bSurah = boundary['surah'] as int;
      final bAyah = boundary['ayah'] as int;
      final bJuz = boundary['juz'] as int;
      if (surah > bSurah || (surah == bSurah && ayah >= bAyah)) {
        return bJuz;
      }
    }
    return 1;
  }
}
