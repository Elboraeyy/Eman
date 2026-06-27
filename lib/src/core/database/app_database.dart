import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

// 1. Quran Tables
@DataClassName('SurahData')
class Surahs extends Table {
  IntColumn get number => integer()();
  TextColumn get name => text()();
  TextColumn get nameArabic => text()();
  TextColumn get nameEnglish => text()();
  TextColumn get englishNameTranslation => text()();
  TextColumn get revelationType => text()();
  IntColumn get numberOfAyahs => integer()();

  @override
  Set<Column> get primaryKey => {number};
}

@DataClassName('AyahData')
class Ayahs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get number => integer()();
  IntColumn get numberInSurah => integer()();
  IntColumn get surahNumber => integer().references(Surahs, #number, onDelete: KeyAction.cascade)();
  TextColumn get textContent => text().named('text')();
  TextColumn get textUthmani => text()();
  IntColumn get juz => integer()();
  IntColumn get hizb => integer()();
  IntColumn get manzil => integer()();
  IntColumn get ruku => integer()();
  IntColumn get page => integer()();
  BoolColumn get sajda => boolean().withDefault(const Constant(false))();
}

// 2. Bookmarks & Progress
@DataClassName('BookmarkData')
class Bookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get surahNumber => integer()();
  IntColumn get ayahNumber => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('ProgressData')
class Progress extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get lastReadPage => integer()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('FavoriteData')
class Favorites extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()(); // 'ayah', 'hadith'
  IntColumn get itemId => integer()();
  IntColumn get surahNumber => integer().nullable()();
  IntColumn get ayahNumber => integer().nullable()();
  IntColumn get hadithId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// 3. Adhkar Tables
@DataClassName('AdhkarCategoryData')
class AdhkarCategories extends Table {
  IntColumn get id => integer()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AdhkarItemData')
class AdhkarItems extends Table {
  IntColumn get id => integer()();
  IntColumn get categoryId => integer().references(AdhkarCategories, #id, onDelete: KeyAction.cascade)();
  TextColumn get textContent => text().named('text')();
  IntColumn get targetCount => integer()();
  TextColumn get reference => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AdhkarProgressData')
class AdhkarProgresses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get itemId => integer().references(AdhkarItems, #id, onDelete: KeyAction.cascade)();
  IntColumn get count => integer().withDefault(const Constant(0))();
  TextColumn get date => text()(); // YYYY-MM-DD
}

// 4. Tasbih Table
@DataClassName('TasbihData')
class Tasbihs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get phrase => text()();
  IntColumn get count => integer().withDefault(const Constant(0))();
  IntColumn get target => integer().withDefault(const Constant(33))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// 5. Hadith Tables
@DataClassName('HadithBookData')
class HadithBooks extends Table {
  IntColumn get id => integer()();
  TextColumn get title => text()();
  TextColumn get author => text().withDefault(const Constant(''))();
  TextColumn get description => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('HadithCategoryData')
class HadithCategories extends Table {
  IntColumn get id => integer()();
  TextColumn get title => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('HadithData')
class Hadiths extends Table {
  IntColumn get id => integer()();
  IntColumn get bookId => integer().references(HadithBooks, #id, onDelete: KeyAction.cascade)();
  IntColumn get categoryId => integer().references(HadithCategories, #id, onDelete: KeyAction.cascade)();
  TextColumn get narrator => text().withDefault(const Constant(''))();
  TextColumn get textContent => text().named('text')();
  TextColumn get source => text().withDefault(const Constant(''))();
  TextColumn get explanation => text().withDefault(const Constant(''))();
  TextColumn get vocabularyJson => text().withDefault(const Constant('[]'))(); // JSON List
  TextColumn get lifeApplicationsJson => text().withDefault(const Constant('[]'))(); // JSON List

  @override
  Set<Column> get primaryKey => {id};
}

// 6. Religious Tasks & Worship Tracker
@DataClassName('ReligiousTaskData')
class ReligiousTasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get type => text().withDefault(const Constant('default'))(); // 'default' or 'custom'
  TextColumn get frequency => text().withDefault(const Constant('daily'))(); // 'daily' or 'weekly'
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('TaskCompletionData')
class TaskCompletions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get taskId => integer().references(ReligiousTasks, #id, onDelete: KeyAction.cascade)();
  TextColumn get date => text()(); // YYYY-MM-DD
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
}

@DataClassName('UserStatData')
class UserStats extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text()(); // YYYY-MM-DD
  IntColumn get quranPagesRead => integer().withDefault(const Constant(0))();
  IntColumn get tasbihCount => integer().withDefault(const Constant(0))();
  IntColumn get adhkarCompleted => integer().withDefault(const Constant(0))();
}

@DriftDatabase(tables: [
  Surahs,
  Ayahs,
  Bookmarks,
  Progress,
  Favorites,
  AdhkarCategories,
  AdhkarItems,
  AdhkarProgresses,
  Tasbihs,
  HadithBooks,
  HadithCategories,
  Hadiths,
  ReligiousTasks,
  TaskCompletions,
  UserStats,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'zad_database'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        // Simple fallback migration for initial development
        if (from < to) {
          // Destructive migration for now to match fallbackToDestructiveMigration
          for (final table in allTables) {
            await m.deleteTable(table.entityName);
          }
          await m.createAll();
        }
      },
    );
  }
}
