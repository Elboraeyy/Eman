// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SurahsTable extends Surahs with TableInfo<$SurahsTable, SurahData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SurahsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameArabicMeta = const VerificationMeta(
    'nameArabic',
  );
  @override
  late final GeneratedColumn<String> nameArabic = GeneratedColumn<String>(
    'name_arabic',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameEnglishMeta = const VerificationMeta(
    'nameEnglish',
  );
  @override
  late final GeneratedColumn<String> nameEnglish = GeneratedColumn<String>(
    'name_english',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _englishNameTranslationMeta =
      const VerificationMeta('englishNameTranslation');
  @override
  late final GeneratedColumn<String> englishNameTranslation =
      GeneratedColumn<String>(
        'english_name_translation',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _revelationTypeMeta = const VerificationMeta(
    'revelationType',
  );
  @override
  late final GeneratedColumn<String> revelationType = GeneratedColumn<String>(
    'revelation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberOfAyahsMeta = const VerificationMeta(
    'numberOfAyahs',
  );
  @override
  late final GeneratedColumn<int> numberOfAyahs = GeneratedColumn<int>(
    'number_of_ayahs',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    number,
    name,
    nameArabic,
    nameEnglish,
    englishNameTranslation,
    revelationType,
    numberOfAyahs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'surahs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SurahData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_arabic')) {
      context.handle(
        _nameArabicMeta,
        nameArabic.isAcceptableOrUnknown(data['name_arabic']!, _nameArabicMeta),
      );
    } else if (isInserting) {
      context.missing(_nameArabicMeta);
    }
    if (data.containsKey('name_english')) {
      context.handle(
        _nameEnglishMeta,
        nameEnglish.isAcceptableOrUnknown(
          data['name_english']!,
          _nameEnglishMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nameEnglishMeta);
    }
    if (data.containsKey('english_name_translation')) {
      context.handle(
        _englishNameTranslationMeta,
        englishNameTranslation.isAcceptableOrUnknown(
          data['english_name_translation']!,
          _englishNameTranslationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_englishNameTranslationMeta);
    }
    if (data.containsKey('revelation_type')) {
      context.handle(
        _revelationTypeMeta,
        revelationType.isAcceptableOrUnknown(
          data['revelation_type']!,
          _revelationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_revelationTypeMeta);
    }
    if (data.containsKey('number_of_ayahs')) {
      context.handle(
        _numberOfAyahsMeta,
        numberOfAyahs.isAcceptableOrUnknown(
          data['number_of_ayahs']!,
          _numberOfAyahsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_numberOfAyahsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {number};
  @override
  SurahData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SurahData(
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameArabic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_arabic'],
      )!,
      nameEnglish: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_english'],
      )!,
      englishNameTranslation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}english_name_translation'],
      )!,
      revelationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}revelation_type'],
      )!,
      numberOfAyahs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number_of_ayahs'],
      )!,
    );
  }

  @override
  $SurahsTable createAlias(String alias) {
    return $SurahsTable(attachedDatabase, alias);
  }
}

class SurahData extends DataClass implements Insertable<SurahData> {
  final int number;
  final String name;
  final String nameArabic;
  final String nameEnglish;
  final String englishNameTranslation;
  final String revelationType;
  final int numberOfAyahs;
  const SurahData({
    required this.number,
    required this.name,
    required this.nameArabic,
    required this.nameEnglish,
    required this.englishNameTranslation,
    required this.revelationType,
    required this.numberOfAyahs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['number'] = Variable<int>(number);
    map['name'] = Variable<String>(name);
    map['name_arabic'] = Variable<String>(nameArabic);
    map['name_english'] = Variable<String>(nameEnglish);
    map['english_name_translation'] = Variable<String>(englishNameTranslation);
    map['revelation_type'] = Variable<String>(revelationType);
    map['number_of_ayahs'] = Variable<int>(numberOfAyahs);
    return map;
  }

  SurahsCompanion toCompanion(bool nullToAbsent) {
    return SurahsCompanion(
      number: Value(number),
      name: Value(name),
      nameArabic: Value(nameArabic),
      nameEnglish: Value(nameEnglish),
      englishNameTranslation: Value(englishNameTranslation),
      revelationType: Value(revelationType),
      numberOfAyahs: Value(numberOfAyahs),
    );
  }

  factory SurahData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SurahData(
      number: serializer.fromJson<int>(json['number']),
      name: serializer.fromJson<String>(json['name']),
      nameArabic: serializer.fromJson<String>(json['nameArabic']),
      nameEnglish: serializer.fromJson<String>(json['nameEnglish']),
      englishNameTranslation: serializer.fromJson<String>(
        json['englishNameTranslation'],
      ),
      revelationType: serializer.fromJson<String>(json['revelationType']),
      numberOfAyahs: serializer.fromJson<int>(json['numberOfAyahs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'number': serializer.toJson<int>(number),
      'name': serializer.toJson<String>(name),
      'nameArabic': serializer.toJson<String>(nameArabic),
      'nameEnglish': serializer.toJson<String>(nameEnglish),
      'englishNameTranslation': serializer.toJson<String>(
        englishNameTranslation,
      ),
      'revelationType': serializer.toJson<String>(revelationType),
      'numberOfAyahs': serializer.toJson<int>(numberOfAyahs),
    };
  }

  SurahData copyWith({
    int? number,
    String? name,
    String? nameArabic,
    String? nameEnglish,
    String? englishNameTranslation,
    String? revelationType,
    int? numberOfAyahs,
  }) => SurahData(
    number: number ?? this.number,
    name: name ?? this.name,
    nameArabic: nameArabic ?? this.nameArabic,
    nameEnglish: nameEnglish ?? this.nameEnglish,
    englishNameTranslation:
        englishNameTranslation ?? this.englishNameTranslation,
    revelationType: revelationType ?? this.revelationType,
    numberOfAyahs: numberOfAyahs ?? this.numberOfAyahs,
  );
  SurahData copyWithCompanion(SurahsCompanion data) {
    return SurahData(
      number: data.number.present ? data.number.value : this.number,
      name: data.name.present ? data.name.value : this.name,
      nameArabic: data.nameArabic.present
          ? data.nameArabic.value
          : this.nameArabic,
      nameEnglish: data.nameEnglish.present
          ? data.nameEnglish.value
          : this.nameEnglish,
      englishNameTranslation: data.englishNameTranslation.present
          ? data.englishNameTranslation.value
          : this.englishNameTranslation,
      revelationType: data.revelationType.present
          ? data.revelationType.value
          : this.revelationType,
      numberOfAyahs: data.numberOfAyahs.present
          ? data.numberOfAyahs.value
          : this.numberOfAyahs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SurahData(')
          ..write('number: $number, ')
          ..write('name: $name, ')
          ..write('nameArabic: $nameArabic, ')
          ..write('nameEnglish: $nameEnglish, ')
          ..write('englishNameTranslation: $englishNameTranslation, ')
          ..write('revelationType: $revelationType, ')
          ..write('numberOfAyahs: $numberOfAyahs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    number,
    name,
    nameArabic,
    nameEnglish,
    englishNameTranslation,
    revelationType,
    numberOfAyahs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SurahData &&
          other.number == this.number &&
          other.name == this.name &&
          other.nameArabic == this.nameArabic &&
          other.nameEnglish == this.nameEnglish &&
          other.englishNameTranslation == this.englishNameTranslation &&
          other.revelationType == this.revelationType &&
          other.numberOfAyahs == this.numberOfAyahs);
}

class SurahsCompanion extends UpdateCompanion<SurahData> {
  final Value<int> number;
  final Value<String> name;
  final Value<String> nameArabic;
  final Value<String> nameEnglish;
  final Value<String> englishNameTranslation;
  final Value<String> revelationType;
  final Value<int> numberOfAyahs;
  const SurahsCompanion({
    this.number = const Value.absent(),
    this.name = const Value.absent(),
    this.nameArabic = const Value.absent(),
    this.nameEnglish = const Value.absent(),
    this.englishNameTranslation = const Value.absent(),
    this.revelationType = const Value.absent(),
    this.numberOfAyahs = const Value.absent(),
  });
  SurahsCompanion.insert({
    this.number = const Value.absent(),
    required String name,
    required String nameArabic,
    required String nameEnglish,
    required String englishNameTranslation,
    required String revelationType,
    required int numberOfAyahs,
  }) : name = Value(name),
       nameArabic = Value(nameArabic),
       nameEnglish = Value(nameEnglish),
       englishNameTranslation = Value(englishNameTranslation),
       revelationType = Value(revelationType),
       numberOfAyahs = Value(numberOfAyahs);
  static Insertable<SurahData> custom({
    Expression<int>? number,
    Expression<String>? name,
    Expression<String>? nameArabic,
    Expression<String>? nameEnglish,
    Expression<String>? englishNameTranslation,
    Expression<String>? revelationType,
    Expression<int>? numberOfAyahs,
  }) {
    return RawValuesInsertable({
      if (number != null) 'number': number,
      if (name != null) 'name': name,
      if (nameArabic != null) 'name_arabic': nameArabic,
      if (nameEnglish != null) 'name_english': nameEnglish,
      if (englishNameTranslation != null)
        'english_name_translation': englishNameTranslation,
      if (revelationType != null) 'revelation_type': revelationType,
      if (numberOfAyahs != null) 'number_of_ayahs': numberOfAyahs,
    });
  }

  SurahsCompanion copyWith({
    Value<int>? number,
    Value<String>? name,
    Value<String>? nameArabic,
    Value<String>? nameEnglish,
    Value<String>? englishNameTranslation,
    Value<String>? revelationType,
    Value<int>? numberOfAyahs,
  }) {
    return SurahsCompanion(
      number: number ?? this.number,
      name: name ?? this.name,
      nameArabic: nameArabic ?? this.nameArabic,
      nameEnglish: nameEnglish ?? this.nameEnglish,
      englishNameTranslation:
          englishNameTranslation ?? this.englishNameTranslation,
      revelationType: revelationType ?? this.revelationType,
      numberOfAyahs: numberOfAyahs ?? this.numberOfAyahs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameArabic.present) {
      map['name_arabic'] = Variable<String>(nameArabic.value);
    }
    if (nameEnglish.present) {
      map['name_english'] = Variable<String>(nameEnglish.value);
    }
    if (englishNameTranslation.present) {
      map['english_name_translation'] = Variable<String>(
        englishNameTranslation.value,
      );
    }
    if (revelationType.present) {
      map['revelation_type'] = Variable<String>(revelationType.value);
    }
    if (numberOfAyahs.present) {
      map['number_of_ayahs'] = Variable<int>(numberOfAyahs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SurahsCompanion(')
          ..write('number: $number, ')
          ..write('name: $name, ')
          ..write('nameArabic: $nameArabic, ')
          ..write('nameEnglish: $nameEnglish, ')
          ..write('englishNameTranslation: $englishNameTranslation, ')
          ..write('revelationType: $revelationType, ')
          ..write('numberOfAyahs: $numberOfAyahs')
          ..write(')'))
        .toString();
  }
}

class $AyahsTable extends Ayahs with TableInfo<$AyahsTable, AyahData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AyahsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberInSurahMeta = const VerificationMeta(
    'numberInSurah',
  );
  @override
  late final GeneratedColumn<int> numberInSurah = GeneratedColumn<int>(
    'number_in_surah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _surahNumberMeta = const VerificationMeta(
    'surahNumber',
  );
  @override
  late final GeneratedColumn<int> surahNumber = GeneratedColumn<int>(
    'surah_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES surahs (number) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _textContentMeta = const VerificationMeta(
    'textContent',
  );
  @override
  late final GeneratedColumn<String> textContent = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textUthmaniMeta = const VerificationMeta(
    'textUthmani',
  );
  @override
  late final GeneratedColumn<String> textUthmani = GeneratedColumn<String>(
    'text_uthmani',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _juzMeta = const VerificationMeta('juz');
  @override
  late final GeneratedColumn<int> juz = GeneratedColumn<int>(
    'juz',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hizbMeta = const VerificationMeta('hizb');
  @override
  late final GeneratedColumn<int> hizb = GeneratedColumn<int>(
    'hizb',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _manzilMeta = const VerificationMeta('manzil');
  @override
  late final GeneratedColumn<int> manzil = GeneratedColumn<int>(
    'manzil',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rukuMeta = const VerificationMeta('ruku');
  @override
  late final GeneratedColumn<int> ruku = GeneratedColumn<int>(
    'ruku',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageMeta = const VerificationMeta('page');
  @override
  late final GeneratedColumn<int> page = GeneratedColumn<int>(
    'page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sajdaMeta = const VerificationMeta('sajda');
  @override
  late final GeneratedColumn<bool> sajda = GeneratedColumn<bool>(
    'sajda',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sajda" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    number,
    numberInSurah,
    surahNumber,
    textContent,
    textUthmani,
    juz,
    hizb,
    manzil,
    ruku,
    page,
    sajda,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ayahs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AyahData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('number_in_surah')) {
      context.handle(
        _numberInSurahMeta,
        numberInSurah.isAcceptableOrUnknown(
          data['number_in_surah']!,
          _numberInSurahMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_numberInSurahMeta);
    }
    if (data.containsKey('surah_number')) {
      context.handle(
        _surahNumberMeta,
        surahNumber.isAcceptableOrUnknown(
          data['surah_number']!,
          _surahNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_surahNumberMeta);
    }
    if (data.containsKey('text')) {
      context.handle(
        _textContentMeta,
        textContent.isAcceptableOrUnknown(data['text']!, _textContentMeta),
      );
    } else if (isInserting) {
      context.missing(_textContentMeta);
    }
    if (data.containsKey('text_uthmani')) {
      context.handle(
        _textUthmaniMeta,
        textUthmani.isAcceptableOrUnknown(
          data['text_uthmani']!,
          _textUthmaniMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_textUthmaniMeta);
    }
    if (data.containsKey('juz')) {
      context.handle(
        _juzMeta,
        juz.isAcceptableOrUnknown(data['juz']!, _juzMeta),
      );
    } else if (isInserting) {
      context.missing(_juzMeta);
    }
    if (data.containsKey('hizb')) {
      context.handle(
        _hizbMeta,
        hizb.isAcceptableOrUnknown(data['hizb']!, _hizbMeta),
      );
    } else if (isInserting) {
      context.missing(_hizbMeta);
    }
    if (data.containsKey('manzil')) {
      context.handle(
        _manzilMeta,
        manzil.isAcceptableOrUnknown(data['manzil']!, _manzilMeta),
      );
    } else if (isInserting) {
      context.missing(_manzilMeta);
    }
    if (data.containsKey('ruku')) {
      context.handle(
        _rukuMeta,
        ruku.isAcceptableOrUnknown(data['ruku']!, _rukuMeta),
      );
    } else if (isInserting) {
      context.missing(_rukuMeta);
    }
    if (data.containsKey('page')) {
      context.handle(
        _pageMeta,
        page.isAcceptableOrUnknown(data['page']!, _pageMeta),
      );
    } else if (isInserting) {
      context.missing(_pageMeta);
    }
    if (data.containsKey('sajda')) {
      context.handle(
        _sajdaMeta,
        sajda.isAcceptableOrUnknown(data['sajda']!, _sajdaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AyahData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AyahData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      numberInSurah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number_in_surah'],
      )!,
      surahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah_number'],
      )!,
      textContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      textUthmani: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_uthmani'],
      )!,
      juz: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}juz'],
      )!,
      hizb: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hizb'],
      )!,
      manzil: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}manzil'],
      )!,
      ruku: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ruku'],
      )!,
      page: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page'],
      )!,
      sajda: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sajda'],
      )!,
    );
  }

  @override
  $AyahsTable createAlias(String alias) {
    return $AyahsTable(attachedDatabase, alias);
  }
}

class AyahData extends DataClass implements Insertable<AyahData> {
  final int id;
  final int number;
  final int numberInSurah;
  final int surahNumber;
  final String textContent;
  final String textUthmani;
  final int juz;
  final int hizb;
  final int manzil;
  final int ruku;
  final int page;
  final bool sajda;
  const AyahData({
    required this.id,
    required this.number,
    required this.numberInSurah,
    required this.surahNumber,
    required this.textContent,
    required this.textUthmani,
    required this.juz,
    required this.hizb,
    required this.manzil,
    required this.ruku,
    required this.page,
    required this.sajda,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['number'] = Variable<int>(number);
    map['number_in_surah'] = Variable<int>(numberInSurah);
    map['surah_number'] = Variable<int>(surahNumber);
    map['text'] = Variable<String>(textContent);
    map['text_uthmani'] = Variable<String>(textUthmani);
    map['juz'] = Variable<int>(juz);
    map['hizb'] = Variable<int>(hizb);
    map['manzil'] = Variable<int>(manzil);
    map['ruku'] = Variable<int>(ruku);
    map['page'] = Variable<int>(page);
    map['sajda'] = Variable<bool>(sajda);
    return map;
  }

  AyahsCompanion toCompanion(bool nullToAbsent) {
    return AyahsCompanion(
      id: Value(id),
      number: Value(number),
      numberInSurah: Value(numberInSurah),
      surahNumber: Value(surahNumber),
      textContent: Value(textContent),
      textUthmani: Value(textUthmani),
      juz: Value(juz),
      hizb: Value(hizb),
      manzil: Value(manzil),
      ruku: Value(ruku),
      page: Value(page),
      sajda: Value(sajda),
    );
  }

  factory AyahData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AyahData(
      id: serializer.fromJson<int>(json['id']),
      number: serializer.fromJson<int>(json['number']),
      numberInSurah: serializer.fromJson<int>(json['numberInSurah']),
      surahNumber: serializer.fromJson<int>(json['surahNumber']),
      textContent: serializer.fromJson<String>(json['textContent']),
      textUthmani: serializer.fromJson<String>(json['textUthmani']),
      juz: serializer.fromJson<int>(json['juz']),
      hizb: serializer.fromJson<int>(json['hizb']),
      manzil: serializer.fromJson<int>(json['manzil']),
      ruku: serializer.fromJson<int>(json['ruku']),
      page: serializer.fromJson<int>(json['page']),
      sajda: serializer.fromJson<bool>(json['sajda']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'number': serializer.toJson<int>(number),
      'numberInSurah': serializer.toJson<int>(numberInSurah),
      'surahNumber': serializer.toJson<int>(surahNumber),
      'textContent': serializer.toJson<String>(textContent),
      'textUthmani': serializer.toJson<String>(textUthmani),
      'juz': serializer.toJson<int>(juz),
      'hizb': serializer.toJson<int>(hizb),
      'manzil': serializer.toJson<int>(manzil),
      'ruku': serializer.toJson<int>(ruku),
      'page': serializer.toJson<int>(page),
      'sajda': serializer.toJson<bool>(sajda),
    };
  }

  AyahData copyWith({
    int? id,
    int? number,
    int? numberInSurah,
    int? surahNumber,
    String? textContent,
    String? textUthmani,
    int? juz,
    int? hizb,
    int? manzil,
    int? ruku,
    int? page,
    bool? sajda,
  }) => AyahData(
    id: id ?? this.id,
    number: number ?? this.number,
    numberInSurah: numberInSurah ?? this.numberInSurah,
    surahNumber: surahNumber ?? this.surahNumber,
    textContent: textContent ?? this.textContent,
    textUthmani: textUthmani ?? this.textUthmani,
    juz: juz ?? this.juz,
    hizb: hizb ?? this.hizb,
    manzil: manzil ?? this.manzil,
    ruku: ruku ?? this.ruku,
    page: page ?? this.page,
    sajda: sajda ?? this.sajda,
  );
  AyahData copyWithCompanion(AyahsCompanion data) {
    return AyahData(
      id: data.id.present ? data.id.value : this.id,
      number: data.number.present ? data.number.value : this.number,
      numberInSurah: data.numberInSurah.present
          ? data.numberInSurah.value
          : this.numberInSurah,
      surahNumber: data.surahNumber.present
          ? data.surahNumber.value
          : this.surahNumber,
      textContent: data.textContent.present
          ? data.textContent.value
          : this.textContent,
      textUthmani: data.textUthmani.present
          ? data.textUthmani.value
          : this.textUthmani,
      juz: data.juz.present ? data.juz.value : this.juz,
      hizb: data.hizb.present ? data.hizb.value : this.hizb,
      manzil: data.manzil.present ? data.manzil.value : this.manzil,
      ruku: data.ruku.present ? data.ruku.value : this.ruku,
      page: data.page.present ? data.page.value : this.page,
      sajda: data.sajda.present ? data.sajda.value : this.sajda,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AyahData(')
          ..write('id: $id, ')
          ..write('number: $number, ')
          ..write('numberInSurah: $numberInSurah, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('textContent: $textContent, ')
          ..write('textUthmani: $textUthmani, ')
          ..write('juz: $juz, ')
          ..write('hizb: $hizb, ')
          ..write('manzil: $manzil, ')
          ..write('ruku: $ruku, ')
          ..write('page: $page, ')
          ..write('sajda: $sajda')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    number,
    numberInSurah,
    surahNumber,
    textContent,
    textUthmani,
    juz,
    hizb,
    manzil,
    ruku,
    page,
    sajda,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AyahData &&
          other.id == this.id &&
          other.number == this.number &&
          other.numberInSurah == this.numberInSurah &&
          other.surahNumber == this.surahNumber &&
          other.textContent == this.textContent &&
          other.textUthmani == this.textUthmani &&
          other.juz == this.juz &&
          other.hizb == this.hizb &&
          other.manzil == this.manzil &&
          other.ruku == this.ruku &&
          other.page == this.page &&
          other.sajda == this.sajda);
}

class AyahsCompanion extends UpdateCompanion<AyahData> {
  final Value<int> id;
  final Value<int> number;
  final Value<int> numberInSurah;
  final Value<int> surahNumber;
  final Value<String> textContent;
  final Value<String> textUthmani;
  final Value<int> juz;
  final Value<int> hizb;
  final Value<int> manzil;
  final Value<int> ruku;
  final Value<int> page;
  final Value<bool> sajda;
  const AyahsCompanion({
    this.id = const Value.absent(),
    this.number = const Value.absent(),
    this.numberInSurah = const Value.absent(),
    this.surahNumber = const Value.absent(),
    this.textContent = const Value.absent(),
    this.textUthmani = const Value.absent(),
    this.juz = const Value.absent(),
    this.hizb = const Value.absent(),
    this.manzil = const Value.absent(),
    this.ruku = const Value.absent(),
    this.page = const Value.absent(),
    this.sajda = const Value.absent(),
  });
  AyahsCompanion.insert({
    this.id = const Value.absent(),
    required int number,
    required int numberInSurah,
    required int surahNumber,
    required String textContent,
    required String textUthmani,
    required int juz,
    required int hizb,
    required int manzil,
    required int ruku,
    required int page,
    this.sajda = const Value.absent(),
  }) : number = Value(number),
       numberInSurah = Value(numberInSurah),
       surahNumber = Value(surahNumber),
       textContent = Value(textContent),
       textUthmani = Value(textUthmani),
       juz = Value(juz),
       hizb = Value(hizb),
       manzil = Value(manzil),
       ruku = Value(ruku),
       page = Value(page);
  static Insertable<AyahData> custom({
    Expression<int>? id,
    Expression<int>? number,
    Expression<int>? numberInSurah,
    Expression<int>? surahNumber,
    Expression<String>? textContent,
    Expression<String>? textUthmani,
    Expression<int>? juz,
    Expression<int>? hizb,
    Expression<int>? manzil,
    Expression<int>? ruku,
    Expression<int>? page,
    Expression<bool>? sajda,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (number != null) 'number': number,
      if (numberInSurah != null) 'number_in_surah': numberInSurah,
      if (surahNumber != null) 'surah_number': surahNumber,
      if (textContent != null) 'text': textContent,
      if (textUthmani != null) 'text_uthmani': textUthmani,
      if (juz != null) 'juz': juz,
      if (hizb != null) 'hizb': hizb,
      if (manzil != null) 'manzil': manzil,
      if (ruku != null) 'ruku': ruku,
      if (page != null) 'page': page,
      if (sajda != null) 'sajda': sajda,
    });
  }

  AyahsCompanion copyWith({
    Value<int>? id,
    Value<int>? number,
    Value<int>? numberInSurah,
    Value<int>? surahNumber,
    Value<String>? textContent,
    Value<String>? textUthmani,
    Value<int>? juz,
    Value<int>? hizb,
    Value<int>? manzil,
    Value<int>? ruku,
    Value<int>? page,
    Value<bool>? sajda,
  }) {
    return AyahsCompanion(
      id: id ?? this.id,
      number: number ?? this.number,
      numberInSurah: numberInSurah ?? this.numberInSurah,
      surahNumber: surahNumber ?? this.surahNumber,
      textContent: textContent ?? this.textContent,
      textUthmani: textUthmani ?? this.textUthmani,
      juz: juz ?? this.juz,
      hizb: hizb ?? this.hizb,
      manzil: manzil ?? this.manzil,
      ruku: ruku ?? this.ruku,
      page: page ?? this.page,
      sajda: sajda ?? this.sajda,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (numberInSurah.present) {
      map['number_in_surah'] = Variable<int>(numberInSurah.value);
    }
    if (surahNumber.present) {
      map['surah_number'] = Variable<int>(surahNumber.value);
    }
    if (textContent.present) {
      map['text'] = Variable<String>(textContent.value);
    }
    if (textUthmani.present) {
      map['text_uthmani'] = Variable<String>(textUthmani.value);
    }
    if (juz.present) {
      map['juz'] = Variable<int>(juz.value);
    }
    if (hizb.present) {
      map['hizb'] = Variable<int>(hizb.value);
    }
    if (manzil.present) {
      map['manzil'] = Variable<int>(manzil.value);
    }
    if (ruku.present) {
      map['ruku'] = Variable<int>(ruku.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (sajda.present) {
      map['sajda'] = Variable<bool>(sajda.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AyahsCompanion(')
          ..write('id: $id, ')
          ..write('number: $number, ')
          ..write('numberInSurah: $numberInSurah, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('textContent: $textContent, ')
          ..write('textUthmani: $textUthmani, ')
          ..write('juz: $juz, ')
          ..write('hizb: $hizb, ')
          ..write('manzil: $manzil, ')
          ..write('ruku: $ruku, ')
          ..write('page: $page, ')
          ..write('sajda: $sajda')
          ..write(')'))
        .toString();
  }
}

class $BookmarksTable extends Bookmarks
    with TableInfo<$BookmarksTable, BookmarkData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _surahNumberMeta = const VerificationMeta(
    'surahNumber',
  );
  @override
  late final GeneratedColumn<int> surahNumber = GeneratedColumn<int>(
    'surah_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ayahNumberMeta = const VerificationMeta(
    'ayahNumber',
  );
  @override
  late final GeneratedColumn<int> ayahNumber = GeneratedColumn<int>(
    'ayah_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    surahNumber,
    ayahNumber,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookmarkData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('surah_number')) {
      context.handle(
        _surahNumberMeta,
        surahNumber.isAcceptableOrUnknown(
          data['surah_number']!,
          _surahNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_surahNumberMeta);
    }
    if (data.containsKey('ayah_number')) {
      context.handle(
        _ayahNumberMeta,
        ayahNumber.isAcceptableOrUnknown(data['ayah_number']!, _ayahNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_ayahNumberMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookmarkData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookmarkData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      surahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah_number'],
      )!,
      ayahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_number'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BookmarksTable createAlias(String alias) {
    return $BookmarksTable(attachedDatabase, alias);
  }
}

class BookmarkData extends DataClass implements Insertable<BookmarkData> {
  final int id;
  final int surahNumber;
  final int ayahNumber;
  final DateTime createdAt;
  const BookmarkData({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['surah_number'] = Variable<int>(surahNumber);
    map['ayah_number'] = Variable<int>(ayahNumber);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BookmarksCompanion toCompanion(bool nullToAbsent) {
    return BookmarksCompanion(
      id: Value(id),
      surahNumber: Value(surahNumber),
      ayahNumber: Value(ayahNumber),
      createdAt: Value(createdAt),
    );
  }

  factory BookmarkData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookmarkData(
      id: serializer.fromJson<int>(json['id']),
      surahNumber: serializer.fromJson<int>(json['surahNumber']),
      ayahNumber: serializer.fromJson<int>(json['ayahNumber']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'surahNumber': serializer.toJson<int>(surahNumber),
      'ayahNumber': serializer.toJson<int>(ayahNumber),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BookmarkData copyWith({
    int? id,
    int? surahNumber,
    int? ayahNumber,
    DateTime? createdAt,
  }) => BookmarkData(
    id: id ?? this.id,
    surahNumber: surahNumber ?? this.surahNumber,
    ayahNumber: ayahNumber ?? this.ayahNumber,
    createdAt: createdAt ?? this.createdAt,
  );
  BookmarkData copyWithCompanion(BookmarksCompanion data) {
    return BookmarkData(
      id: data.id.present ? data.id.value : this.id,
      surahNumber: data.surahNumber.present
          ? data.surahNumber.value
          : this.surahNumber,
      ayahNumber: data.ayahNumber.present
          ? data.ayahNumber.value
          : this.ayahNumber,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkData(')
          ..write('id: $id, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, surahNumber, ayahNumber, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookmarkData &&
          other.id == this.id &&
          other.surahNumber == this.surahNumber &&
          other.ayahNumber == this.ayahNumber &&
          other.createdAt == this.createdAt);
}

class BookmarksCompanion extends UpdateCompanion<BookmarkData> {
  final Value<int> id;
  final Value<int> surahNumber;
  final Value<int> ayahNumber;
  final Value<DateTime> createdAt;
  const BookmarksCompanion({
    this.id = const Value.absent(),
    this.surahNumber = const Value.absent(),
    this.ayahNumber = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BookmarksCompanion.insert({
    this.id = const Value.absent(),
    required int surahNumber,
    required int ayahNumber,
    this.createdAt = const Value.absent(),
  }) : surahNumber = Value(surahNumber),
       ayahNumber = Value(ayahNumber);
  static Insertable<BookmarkData> custom({
    Expression<int>? id,
    Expression<int>? surahNumber,
    Expression<int>? ayahNumber,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (surahNumber != null) 'surah_number': surahNumber,
      if (ayahNumber != null) 'ayah_number': ayahNumber,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BookmarksCompanion copyWith({
    Value<int>? id,
    Value<int>? surahNumber,
    Value<int>? ayahNumber,
    Value<DateTime>? createdAt,
  }) {
    return BookmarksCompanion(
      id: id ?? this.id,
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (surahNumber.present) {
      map['surah_number'] = Variable<int>(surahNumber.value);
    }
    if (ayahNumber.present) {
      map['ayah_number'] = Variable<int>(ayahNumber.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksCompanion(')
          ..write('id: $id, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ProgressTable extends Progress
    with TableInfo<$ProgressTable, ProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _lastReadPageMeta = const VerificationMeta(
    'lastReadPage',
  );
  @override
  late final GeneratedColumn<int> lastReadPage = GeneratedColumn<int>(
    'last_read_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, lastReadPage, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('last_read_page')) {
      context.handle(
        _lastReadPageMeta,
        lastReadPage.isAcceptableOrUnknown(
          data['last_read_page']!,
          _lastReadPageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastReadPageMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgressData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lastReadPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_read_page'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProgressTable createAlias(String alias) {
    return $ProgressTable(attachedDatabase, alias);
  }
}

class ProgressData extends DataClass implements Insertable<ProgressData> {
  final int id;
  final int lastReadPage;
  final DateTime updatedAt;
  const ProgressData({
    required this.id,
    required this.lastReadPage,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['last_read_page'] = Variable<int>(lastReadPage);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProgressCompanion toCompanion(bool nullToAbsent) {
    return ProgressCompanion(
      id: Value(id),
      lastReadPage: Value(lastReadPage),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgressData(
      id: serializer.fromJson<int>(json['id']),
      lastReadPage: serializer.fromJson<int>(json['lastReadPage']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lastReadPage': serializer.toJson<int>(lastReadPage),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProgressData copyWith({int? id, int? lastReadPage, DateTime? updatedAt}) =>
      ProgressData(
        id: id ?? this.id,
        lastReadPage: lastReadPage ?? this.lastReadPage,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ProgressData copyWithCompanion(ProgressCompanion data) {
    return ProgressData(
      id: data.id.present ? data.id.value : this.id,
      lastReadPage: data.lastReadPage.present
          ? data.lastReadPage.value
          : this.lastReadPage,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgressData(')
          ..write('id: $id, ')
          ..write('lastReadPage: $lastReadPage, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, lastReadPage, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgressData &&
          other.id == this.id &&
          other.lastReadPage == this.lastReadPage &&
          other.updatedAt == this.updatedAt);
}

class ProgressCompanion extends UpdateCompanion<ProgressData> {
  final Value<int> id;
  final Value<int> lastReadPage;
  final Value<DateTime> updatedAt;
  const ProgressCompanion({
    this.id = const Value.absent(),
    this.lastReadPage = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ProgressCompanion.insert({
    this.id = const Value.absent(),
    required int lastReadPage,
    this.updatedAt = const Value.absent(),
  }) : lastReadPage = Value(lastReadPage);
  static Insertable<ProgressData> custom({
    Expression<int>? id,
    Expression<int>? lastReadPage,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lastReadPage != null) 'last_read_page': lastReadPage,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ProgressCompanion copyWith({
    Value<int>? id,
    Value<int>? lastReadPage,
    Value<DateTime>? updatedAt,
  }) {
    return ProgressCompanion(
      id: id ?? this.id,
      lastReadPage: lastReadPage ?? this.lastReadPage,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lastReadPage.present) {
      map['last_read_page'] = Variable<int>(lastReadPage.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgressCompanion(')
          ..write('id: $id, ')
          ..write('lastReadPage: $lastReadPage, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $FavoritesTable extends Favorites
    with TableInfo<$FavoritesTable, FavoriteData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _surahNumberMeta = const VerificationMeta(
    'surahNumber',
  );
  @override
  late final GeneratedColumn<int> surahNumber = GeneratedColumn<int>(
    'surah_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ayahNumberMeta = const VerificationMeta(
    'ayahNumber',
  );
  @override
  late final GeneratedColumn<int> ayahNumber = GeneratedColumn<int>(
    'ayah_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hadithIdMeta = const VerificationMeta(
    'hadithId',
  );
  @override
  late final GeneratedColumn<int> hadithId = GeneratedColumn<int>(
    'hadith_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    itemId,
    surahNumber,
    ayahNumber,
    hadithId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorites';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('surah_number')) {
      context.handle(
        _surahNumberMeta,
        surahNumber.isAcceptableOrUnknown(
          data['surah_number']!,
          _surahNumberMeta,
        ),
      );
    }
    if (data.containsKey('ayah_number')) {
      context.handle(
        _ayahNumberMeta,
        ayahNumber.isAcceptableOrUnknown(data['ayah_number']!, _ayahNumberMeta),
      );
    }
    if (data.containsKey('hadith_id')) {
      context.handle(
        _hadithIdMeta,
        hadithId.isAcceptableOrUnknown(data['hadith_id']!, _hadithIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FavoriteData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_id'],
      )!,
      surahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah_number'],
      ),
      ayahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_number'],
      ),
      hadithId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hadith_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FavoritesTable createAlias(String alias) {
    return $FavoritesTable(attachedDatabase, alias);
  }
}

class FavoriteData extends DataClass implements Insertable<FavoriteData> {
  final int id;
  final String type;
  final int itemId;
  final int? surahNumber;
  final int? ayahNumber;
  final int? hadithId;
  final DateTime createdAt;
  const FavoriteData({
    required this.id,
    required this.type,
    required this.itemId,
    this.surahNumber,
    this.ayahNumber,
    this.hadithId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['item_id'] = Variable<int>(itemId);
    if (!nullToAbsent || surahNumber != null) {
      map['surah_number'] = Variable<int>(surahNumber);
    }
    if (!nullToAbsent || ayahNumber != null) {
      map['ayah_number'] = Variable<int>(ayahNumber);
    }
    if (!nullToAbsent || hadithId != null) {
      map['hadith_id'] = Variable<int>(hadithId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FavoritesCompanion toCompanion(bool nullToAbsent) {
    return FavoritesCompanion(
      id: Value(id),
      type: Value(type),
      itemId: Value(itemId),
      surahNumber: surahNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(surahNumber),
      ayahNumber: ayahNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(ayahNumber),
      hadithId: hadithId == null && nullToAbsent
          ? const Value.absent()
          : Value(hadithId),
      createdAt: Value(createdAt),
    );
  }

  factory FavoriteData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteData(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      itemId: serializer.fromJson<int>(json['itemId']),
      surahNumber: serializer.fromJson<int?>(json['surahNumber']),
      ayahNumber: serializer.fromJson<int?>(json['ayahNumber']),
      hadithId: serializer.fromJson<int?>(json['hadithId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'itemId': serializer.toJson<int>(itemId),
      'surahNumber': serializer.toJson<int?>(surahNumber),
      'ayahNumber': serializer.toJson<int?>(ayahNumber),
      'hadithId': serializer.toJson<int?>(hadithId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FavoriteData copyWith({
    int? id,
    String? type,
    int? itemId,
    Value<int?> surahNumber = const Value.absent(),
    Value<int?> ayahNumber = const Value.absent(),
    Value<int?> hadithId = const Value.absent(),
    DateTime? createdAt,
  }) => FavoriteData(
    id: id ?? this.id,
    type: type ?? this.type,
    itemId: itemId ?? this.itemId,
    surahNumber: surahNumber.present ? surahNumber.value : this.surahNumber,
    ayahNumber: ayahNumber.present ? ayahNumber.value : this.ayahNumber,
    hadithId: hadithId.present ? hadithId.value : this.hadithId,
    createdAt: createdAt ?? this.createdAt,
  );
  FavoriteData copyWithCompanion(FavoritesCompanion data) {
    return FavoriteData(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      surahNumber: data.surahNumber.present
          ? data.surahNumber.value
          : this.surahNumber,
      ayahNumber: data.ayahNumber.present
          ? data.ayahNumber.value
          : this.ayahNumber,
      hadithId: data.hadithId.present ? data.hadithId.value : this.hadithId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteData(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('itemId: $itemId, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('hadithId: $hadithId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    itemId,
    surahNumber,
    ayahNumber,
    hadithId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteData &&
          other.id == this.id &&
          other.type == this.type &&
          other.itemId == this.itemId &&
          other.surahNumber == this.surahNumber &&
          other.ayahNumber == this.ayahNumber &&
          other.hadithId == this.hadithId &&
          other.createdAt == this.createdAt);
}

class FavoritesCompanion extends UpdateCompanion<FavoriteData> {
  final Value<int> id;
  final Value<String> type;
  final Value<int> itemId;
  final Value<int?> surahNumber;
  final Value<int?> ayahNumber;
  final Value<int?> hadithId;
  final Value<DateTime> createdAt;
  const FavoritesCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.itemId = const Value.absent(),
    this.surahNumber = const Value.absent(),
    this.ayahNumber = const Value.absent(),
    this.hadithId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FavoritesCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required int itemId,
    this.surahNumber = const Value.absent(),
    this.ayahNumber = const Value.absent(),
    this.hadithId = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : type = Value(type),
       itemId = Value(itemId);
  static Insertable<FavoriteData> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<int>? itemId,
    Expression<int>? surahNumber,
    Expression<int>? ayahNumber,
    Expression<int>? hadithId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (itemId != null) 'item_id': itemId,
      if (surahNumber != null) 'surah_number': surahNumber,
      if (ayahNumber != null) 'ayah_number': ayahNumber,
      if (hadithId != null) 'hadith_id': hadithId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FavoritesCompanion copyWith({
    Value<int>? id,
    Value<String>? type,
    Value<int>? itemId,
    Value<int?>? surahNumber,
    Value<int?>? ayahNumber,
    Value<int?>? hadithId,
    Value<DateTime>? createdAt,
  }) {
    return FavoritesCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      itemId: itemId ?? this.itemId,
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      hadithId: hadithId ?? this.hadithId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    if (surahNumber.present) {
      map['surah_number'] = Variable<int>(surahNumber.value);
    }
    if (ayahNumber.present) {
      map['ayah_number'] = Variable<int>(ayahNumber.value);
    }
    if (hadithId.present) {
      map['hadith_id'] = Variable<int>(hadithId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoritesCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('itemId: $itemId, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('hadithId: $hadithId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AdhkarCategoriesTable extends AdhkarCategories
    with TableInfo<$AdhkarCategoriesTable, AdhkarCategoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdhkarCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, description];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'adhkar_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<AdhkarCategoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AdhkarCategoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdhkarCategoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
    );
  }

  @override
  $AdhkarCategoriesTable createAlias(String alias) {
    return $AdhkarCategoriesTable(attachedDatabase, alias);
  }
}

class AdhkarCategoryData extends DataClass
    implements Insertable<AdhkarCategoryData> {
  final int id;
  final String title;
  final String description;
  const AdhkarCategoryData({
    required this.id,
    required this.title,
    required this.description,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    return map;
  }

  AdhkarCategoriesCompanion toCompanion(bool nullToAbsent) {
    return AdhkarCategoriesCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
    );
  }

  factory AdhkarCategoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdhkarCategoryData(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
    };
  }

  AdhkarCategoryData copyWith({int? id, String? title, String? description}) =>
      AdhkarCategoryData(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
      );
  AdhkarCategoryData copyWithCompanion(AdhkarCategoriesCompanion data) {
    return AdhkarCategoryData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdhkarCategoryData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdhkarCategoryData &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description);
}

class AdhkarCategoriesCompanion extends UpdateCompanion<AdhkarCategoryData> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> description;
  const AdhkarCategoriesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
  });
  AdhkarCategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
  }) : title = Value(title);
  static Insertable<AdhkarCategoryData> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
    });
  }

  AdhkarCategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? description,
  }) {
    return AdhkarCategoriesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdhkarCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }
}

class $AdhkarItemsTable extends AdhkarItems
    with TableInfo<$AdhkarItemsTable, AdhkarItemData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdhkarItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES adhkar_categories (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _textContentMeta = const VerificationMeta(
    'textContent',
  );
  @override
  late final GeneratedColumn<String> textContent = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetCountMeta = const VerificationMeta(
    'targetCount',
  );
  @override
  late final GeneratedColumn<int> targetCount = GeneratedColumn<int>(
    'target_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    categoryId,
    textContent,
    targetCount,
    reference,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'adhkar_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<AdhkarItemData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('text')) {
      context.handle(
        _textContentMeta,
        textContent.isAcceptableOrUnknown(data['text']!, _textContentMeta),
      );
    } else if (isInserting) {
      context.missing(_textContentMeta);
    }
    if (data.containsKey('target_count')) {
      context.handle(
        _targetCountMeta,
        targetCount.isAcceptableOrUnknown(
          data['target_count']!,
          _targetCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetCountMeta);
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AdhkarItemData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdhkarItemData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      textContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      targetCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_count'],
      )!,
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      )!,
    );
  }

  @override
  $AdhkarItemsTable createAlias(String alias) {
    return $AdhkarItemsTable(attachedDatabase, alias);
  }
}

class AdhkarItemData extends DataClass implements Insertable<AdhkarItemData> {
  final int id;
  final int categoryId;
  final String textContent;
  final int targetCount;
  final String reference;
  const AdhkarItemData({
    required this.id,
    required this.categoryId,
    required this.textContent,
    required this.targetCount,
    required this.reference,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category_id'] = Variable<int>(categoryId);
    map['text'] = Variable<String>(textContent);
    map['target_count'] = Variable<int>(targetCount);
    map['reference'] = Variable<String>(reference);
    return map;
  }

  AdhkarItemsCompanion toCompanion(bool nullToAbsent) {
    return AdhkarItemsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      textContent: Value(textContent),
      targetCount: Value(targetCount),
      reference: Value(reference),
    );
  }

  factory AdhkarItemData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdhkarItemData(
      id: serializer.fromJson<int>(json['id']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      textContent: serializer.fromJson<String>(json['textContent']),
      targetCount: serializer.fromJson<int>(json['targetCount']),
      reference: serializer.fromJson<String>(json['reference']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoryId': serializer.toJson<int>(categoryId),
      'textContent': serializer.toJson<String>(textContent),
      'targetCount': serializer.toJson<int>(targetCount),
      'reference': serializer.toJson<String>(reference),
    };
  }

  AdhkarItemData copyWith({
    int? id,
    int? categoryId,
    String? textContent,
    int? targetCount,
    String? reference,
  }) => AdhkarItemData(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    textContent: textContent ?? this.textContent,
    targetCount: targetCount ?? this.targetCount,
    reference: reference ?? this.reference,
  );
  AdhkarItemData copyWithCompanion(AdhkarItemsCompanion data) {
    return AdhkarItemData(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      textContent: data.textContent.present
          ? data.textContent.value
          : this.textContent,
      targetCount: data.targetCount.present
          ? data.targetCount.value
          : this.targetCount,
      reference: data.reference.present ? data.reference.value : this.reference,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdhkarItemData(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('textContent: $textContent, ')
          ..write('targetCount: $targetCount, ')
          ..write('reference: $reference')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, categoryId, textContent, targetCount, reference);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdhkarItemData &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.textContent == this.textContent &&
          other.targetCount == this.targetCount &&
          other.reference == this.reference);
}

class AdhkarItemsCompanion extends UpdateCompanion<AdhkarItemData> {
  final Value<int> id;
  final Value<int> categoryId;
  final Value<String> textContent;
  final Value<int> targetCount;
  final Value<String> reference;
  const AdhkarItemsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.textContent = const Value.absent(),
    this.targetCount = const Value.absent(),
    this.reference = const Value.absent(),
  });
  AdhkarItemsCompanion.insert({
    this.id = const Value.absent(),
    required int categoryId,
    required String textContent,
    required int targetCount,
    this.reference = const Value.absent(),
  }) : categoryId = Value(categoryId),
       textContent = Value(textContent),
       targetCount = Value(targetCount);
  static Insertable<AdhkarItemData> custom({
    Expression<int>? id,
    Expression<int>? categoryId,
    Expression<String>? textContent,
    Expression<int>? targetCount,
    Expression<String>? reference,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (textContent != null) 'text': textContent,
      if (targetCount != null) 'target_count': targetCount,
      if (reference != null) 'reference': reference,
    });
  }

  AdhkarItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? categoryId,
    Value<String>? textContent,
    Value<int>? targetCount,
    Value<String>? reference,
  }) {
    return AdhkarItemsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      textContent: textContent ?? this.textContent,
      targetCount: targetCount ?? this.targetCount,
      reference: reference ?? this.reference,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (textContent.present) {
      map['text'] = Variable<String>(textContent.value);
    }
    if (targetCount.present) {
      map['target_count'] = Variable<int>(targetCount.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdhkarItemsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('textContent: $textContent, ')
          ..write('targetCount: $targetCount, ')
          ..write('reference: $reference')
          ..write(')'))
        .toString();
  }
}

class $AdhkarProgressesTable extends AdhkarProgresses
    with TableInfo<$AdhkarProgressesTable, AdhkarProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdhkarProgressesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES adhkar_items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, itemId, count, date];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'adhkar_progresses';
  @override
  VerificationContext validateIntegrity(
    Insertable<AdhkarProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AdhkarProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdhkarProgressData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_id'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
    );
  }

  @override
  $AdhkarProgressesTable createAlias(String alias) {
    return $AdhkarProgressesTable(attachedDatabase, alias);
  }
}

class AdhkarProgressData extends DataClass
    implements Insertable<AdhkarProgressData> {
  final int id;
  final int itemId;
  final int count;
  final String date;
  const AdhkarProgressData({
    required this.id,
    required this.itemId,
    required this.count,
    required this.date,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['item_id'] = Variable<int>(itemId);
    map['count'] = Variable<int>(count);
    map['date'] = Variable<String>(date);
    return map;
  }

  AdhkarProgressesCompanion toCompanion(bool nullToAbsent) {
    return AdhkarProgressesCompanion(
      id: Value(id),
      itemId: Value(itemId),
      count: Value(count),
      date: Value(date),
    );
  }

  factory AdhkarProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdhkarProgressData(
      id: serializer.fromJson<int>(json['id']),
      itemId: serializer.fromJson<int>(json['itemId']),
      count: serializer.fromJson<int>(json['count']),
      date: serializer.fromJson<String>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'itemId': serializer.toJson<int>(itemId),
      'count': serializer.toJson<int>(count),
      'date': serializer.toJson<String>(date),
    };
  }

  AdhkarProgressData copyWith({
    int? id,
    int? itemId,
    int? count,
    String? date,
  }) => AdhkarProgressData(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    count: count ?? this.count,
    date: date ?? this.date,
  );
  AdhkarProgressData copyWithCompanion(AdhkarProgressesCompanion data) {
    return AdhkarProgressData(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      count: data.count.present ? data.count.value : this.count,
      date: data.date.present ? data.date.value : this.date,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdhkarProgressData(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('count: $count, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, itemId, count, date);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdhkarProgressData &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.count == this.count &&
          other.date == this.date);
}

class AdhkarProgressesCompanion extends UpdateCompanion<AdhkarProgressData> {
  final Value<int> id;
  final Value<int> itemId;
  final Value<int> count;
  final Value<String> date;
  const AdhkarProgressesCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.count = const Value.absent(),
    this.date = const Value.absent(),
  });
  AdhkarProgressesCompanion.insert({
    this.id = const Value.absent(),
    required int itemId,
    this.count = const Value.absent(),
    required String date,
  }) : itemId = Value(itemId),
       date = Value(date);
  static Insertable<AdhkarProgressData> custom({
    Expression<int>? id,
    Expression<int>? itemId,
    Expression<int>? count,
    Expression<String>? date,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (count != null) 'count': count,
      if (date != null) 'date': date,
    });
  }

  AdhkarProgressesCompanion copyWith({
    Value<int>? id,
    Value<int>? itemId,
    Value<int>? count,
    Value<String>? date,
  }) {
    return AdhkarProgressesCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      count: count ?? this.count,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdhkarProgressesCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('count: $count, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }
}

class $TasbihsTable extends Tasbihs with TableInfo<$TasbihsTable, TasbihData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasbihsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _phraseMeta = const VerificationMeta('phrase');
  @override
  late final GeneratedColumn<String> phrase = GeneratedColumn<String>(
    'phrase',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<int> target = GeneratedColumn<int>(
    'target',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(33),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, phrase, count, target, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasbihs';
  @override
  VerificationContext validateIntegrity(
    Insertable<TasbihData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('phrase')) {
      context.handle(
        _phraseMeta,
        phrase.isAcceptableOrUnknown(data['phrase']!, _phraseMeta),
      );
    } else if (isInserting) {
      context.missing(_phraseMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TasbihData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TasbihData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      phrase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phrase'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TasbihsTable createAlias(String alias) {
    return $TasbihsTable(attachedDatabase, alias);
  }
}

class TasbihData extends DataClass implements Insertable<TasbihData> {
  final int id;
  final String phrase;
  final int count;
  final int target;
  final DateTime updatedAt;
  const TasbihData({
    required this.id,
    required this.phrase,
    required this.count,
    required this.target,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['phrase'] = Variable<String>(phrase);
    map['count'] = Variable<int>(count);
    map['target'] = Variable<int>(target);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TasbihsCompanion toCompanion(bool nullToAbsent) {
    return TasbihsCompanion(
      id: Value(id),
      phrase: Value(phrase),
      count: Value(count),
      target: Value(target),
      updatedAt: Value(updatedAt),
    );
  }

  factory TasbihData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TasbihData(
      id: serializer.fromJson<int>(json['id']),
      phrase: serializer.fromJson<String>(json['phrase']),
      count: serializer.fromJson<int>(json['count']),
      target: serializer.fromJson<int>(json['target']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'phrase': serializer.toJson<String>(phrase),
      'count': serializer.toJson<int>(count),
      'target': serializer.toJson<int>(target),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TasbihData copyWith({
    int? id,
    String? phrase,
    int? count,
    int? target,
    DateTime? updatedAt,
  }) => TasbihData(
    id: id ?? this.id,
    phrase: phrase ?? this.phrase,
    count: count ?? this.count,
    target: target ?? this.target,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TasbihData copyWithCompanion(TasbihsCompanion data) {
    return TasbihData(
      id: data.id.present ? data.id.value : this.id,
      phrase: data.phrase.present ? data.phrase.value : this.phrase,
      count: data.count.present ? data.count.value : this.count,
      target: data.target.present ? data.target.value : this.target,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TasbihData(')
          ..write('id: $id, ')
          ..write('phrase: $phrase, ')
          ..write('count: $count, ')
          ..write('target: $target, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, phrase, count, target, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TasbihData &&
          other.id == this.id &&
          other.phrase == this.phrase &&
          other.count == this.count &&
          other.target == this.target &&
          other.updatedAt == this.updatedAt);
}

class TasbihsCompanion extends UpdateCompanion<TasbihData> {
  final Value<int> id;
  final Value<String> phrase;
  final Value<int> count;
  final Value<int> target;
  final Value<DateTime> updatedAt;
  const TasbihsCompanion({
    this.id = const Value.absent(),
    this.phrase = const Value.absent(),
    this.count = const Value.absent(),
    this.target = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TasbihsCompanion.insert({
    this.id = const Value.absent(),
    required String phrase,
    this.count = const Value.absent(),
    this.target = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : phrase = Value(phrase);
  static Insertable<TasbihData> custom({
    Expression<int>? id,
    Expression<String>? phrase,
    Expression<int>? count,
    Expression<int>? target,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (phrase != null) 'phrase': phrase,
      if (count != null) 'count': count,
      if (target != null) 'target': target,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TasbihsCompanion copyWith({
    Value<int>? id,
    Value<String>? phrase,
    Value<int>? count,
    Value<int>? target,
    Value<DateTime>? updatedAt,
  }) {
    return TasbihsCompanion(
      id: id ?? this.id,
      phrase: phrase ?? this.phrase,
      count: count ?? this.count,
      target: target ?? this.target,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (phrase.present) {
      map['phrase'] = Variable<String>(phrase.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (target.present) {
      map['target'] = Variable<int>(target.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasbihsCompanion(')
          ..write('id: $id, ')
          ..write('phrase: $phrase, ')
          ..write('count: $count, ')
          ..write('target: $target, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $HadithBooksTable extends HadithBooks
    with TableInfo<$HadithBooksTable, HadithBookData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HadithBooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, author, description];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hadith_books';
  @override
  VerificationContext validateIntegrity(
    Insertable<HadithBookData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HadithBookData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HadithBookData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
    );
  }

  @override
  $HadithBooksTable createAlias(String alias) {
    return $HadithBooksTable(attachedDatabase, alias);
  }
}

class HadithBookData extends DataClass implements Insertable<HadithBookData> {
  final int id;
  final String title;
  final String author;
  final String description;
  const HadithBookData({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['author'] = Variable<String>(author);
    map['description'] = Variable<String>(description);
    return map;
  }

  HadithBooksCompanion toCompanion(bool nullToAbsent) {
    return HadithBooksCompanion(
      id: Value(id),
      title: Value(title),
      author: Value(author),
      description: Value(description),
    );
  }

  factory HadithBookData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HadithBookData(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      author: serializer.fromJson<String>(json['author']),
      description: serializer.fromJson<String>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'author': serializer.toJson<String>(author),
      'description': serializer.toJson<String>(description),
    };
  }

  HadithBookData copyWith({
    int? id,
    String? title,
    String? author,
    String? description,
  }) => HadithBookData(
    id: id ?? this.id,
    title: title ?? this.title,
    author: author ?? this.author,
    description: description ?? this.description,
  );
  HadithBookData copyWithCompanion(HadithBooksCompanion data) {
    return HadithBookData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      author: data.author.present ? data.author.value : this.author,
      description: data.description.present
          ? data.description.value
          : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HadithBookData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, author, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HadithBookData &&
          other.id == this.id &&
          other.title == this.title &&
          other.author == this.author &&
          other.description == this.description);
}

class HadithBooksCompanion extends UpdateCompanion<HadithBookData> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> author;
  final Value<String> description;
  const HadithBooksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.description = const Value.absent(),
  });
  HadithBooksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.author = const Value.absent(),
    this.description = const Value.absent(),
  }) : title = Value(title);
  static Insertable<HadithBookData> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? author,
    Expression<String>? description,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (description != null) 'description': description,
    });
  }

  HadithBooksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? author,
    Value<String>? description,
  }) {
    return HadithBooksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HadithBooksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }
}

class $HadithCategoriesTable extends HadithCategories
    with TableInfo<$HadithCategoriesTable, HadithCategoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HadithCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, title];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hadith_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<HadithCategoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HadithCategoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HadithCategoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
    );
  }

  @override
  $HadithCategoriesTable createAlias(String alias) {
    return $HadithCategoriesTable(attachedDatabase, alias);
  }
}

class HadithCategoryData extends DataClass
    implements Insertable<HadithCategoryData> {
  final int id;
  final String title;
  const HadithCategoryData({required this.id, required this.title});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    return map;
  }

  HadithCategoriesCompanion toCompanion(bool nullToAbsent) {
    return HadithCategoriesCompanion(id: Value(id), title: Value(title));
  }

  factory HadithCategoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HadithCategoryData(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
    };
  }

  HadithCategoryData copyWith({int? id, String? title}) =>
      HadithCategoryData(id: id ?? this.id, title: title ?? this.title);
  HadithCategoryData copyWithCompanion(HadithCategoriesCompanion data) {
    return HadithCategoryData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HadithCategoryData(')
          ..write('id: $id, ')
          ..write('title: $title')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HadithCategoryData &&
          other.id == this.id &&
          other.title == this.title);
}

class HadithCategoriesCompanion extends UpdateCompanion<HadithCategoryData> {
  final Value<int> id;
  final Value<String> title;
  const HadithCategoriesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
  });
  HadithCategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
  }) : title = Value(title);
  static Insertable<HadithCategoryData> custom({
    Expression<int>? id,
    Expression<String>? title,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
    });
  }

  HadithCategoriesCompanion copyWith({Value<int>? id, Value<String>? title}) {
    return HadithCategoriesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HadithCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title')
          ..write(')'))
        .toString();
  }
}

class $HadithsTable extends Hadiths with TableInfo<$HadithsTable, HadithData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HadithsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES hadith_books (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES hadith_categories (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _narratorMeta = const VerificationMeta(
    'narrator',
  );
  @override
  late final GeneratedColumn<String> narrator = GeneratedColumn<String>(
    'narrator',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _textContentMeta = const VerificationMeta(
    'textContent',
  );
  @override
  late final GeneratedColumn<String> textContent = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _explanationMeta = const VerificationMeta(
    'explanation',
  );
  @override
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
    'explanation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _vocabularyJsonMeta = const VerificationMeta(
    'vocabularyJson',
  );
  @override
  late final GeneratedColumn<String> vocabularyJson = GeneratedColumn<String>(
    'vocabulary_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _lifeApplicationsJsonMeta =
      const VerificationMeta('lifeApplicationsJson');
  @override
  late final GeneratedColumn<String> lifeApplicationsJson =
      GeneratedColumn<String>(
        'life_applications_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    categoryId,
    narrator,
    textContent,
    source,
    explanation,
    vocabularyJson,
    lifeApplicationsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hadiths';
  @override
  VerificationContext validateIntegrity(
    Insertable<HadithData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('narrator')) {
      context.handle(
        _narratorMeta,
        narrator.isAcceptableOrUnknown(data['narrator']!, _narratorMeta),
      );
    }
    if (data.containsKey('text')) {
      context.handle(
        _textContentMeta,
        textContent.isAcceptableOrUnknown(data['text']!, _textContentMeta),
      );
    } else if (isInserting) {
      context.missing(_textContentMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('explanation')) {
      context.handle(
        _explanationMeta,
        explanation.isAcceptableOrUnknown(
          data['explanation']!,
          _explanationMeta,
        ),
      );
    }
    if (data.containsKey('vocabulary_json')) {
      context.handle(
        _vocabularyJsonMeta,
        vocabularyJson.isAcceptableOrUnknown(
          data['vocabulary_json']!,
          _vocabularyJsonMeta,
        ),
      );
    }
    if (data.containsKey('life_applications_json')) {
      context.handle(
        _lifeApplicationsJsonMeta,
        lifeApplicationsJson.isAcceptableOrUnknown(
          data['life_applications_json']!,
          _lifeApplicationsJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HadithData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HadithData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      narrator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}narrator'],
      )!,
      textContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      explanation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explanation'],
      )!,
      vocabularyJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vocabulary_json'],
      )!,
      lifeApplicationsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}life_applications_json'],
      )!,
    );
  }

  @override
  $HadithsTable createAlias(String alias) {
    return $HadithsTable(attachedDatabase, alias);
  }
}

class HadithData extends DataClass implements Insertable<HadithData> {
  final int id;
  final int bookId;
  final int categoryId;
  final String narrator;
  final String textContent;
  final String source;
  final String explanation;
  final String vocabularyJson;
  final String lifeApplicationsJson;
  const HadithData({
    required this.id,
    required this.bookId,
    required this.categoryId,
    required this.narrator,
    required this.textContent,
    required this.source,
    required this.explanation,
    required this.vocabularyJson,
    required this.lifeApplicationsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    map['category_id'] = Variable<int>(categoryId);
    map['narrator'] = Variable<String>(narrator);
    map['text'] = Variable<String>(textContent);
    map['source'] = Variable<String>(source);
    map['explanation'] = Variable<String>(explanation);
    map['vocabulary_json'] = Variable<String>(vocabularyJson);
    map['life_applications_json'] = Variable<String>(lifeApplicationsJson);
    return map;
  }

  HadithsCompanion toCompanion(bool nullToAbsent) {
    return HadithsCompanion(
      id: Value(id),
      bookId: Value(bookId),
      categoryId: Value(categoryId),
      narrator: Value(narrator),
      textContent: Value(textContent),
      source: Value(source),
      explanation: Value(explanation),
      vocabularyJson: Value(vocabularyJson),
      lifeApplicationsJson: Value(lifeApplicationsJson),
    );
  }

  factory HadithData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HadithData(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      narrator: serializer.fromJson<String>(json['narrator']),
      textContent: serializer.fromJson<String>(json['textContent']),
      source: serializer.fromJson<String>(json['source']),
      explanation: serializer.fromJson<String>(json['explanation']),
      vocabularyJson: serializer.fromJson<String>(json['vocabularyJson']),
      lifeApplicationsJson: serializer.fromJson<String>(
        json['lifeApplicationsJson'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'categoryId': serializer.toJson<int>(categoryId),
      'narrator': serializer.toJson<String>(narrator),
      'textContent': serializer.toJson<String>(textContent),
      'source': serializer.toJson<String>(source),
      'explanation': serializer.toJson<String>(explanation),
      'vocabularyJson': serializer.toJson<String>(vocabularyJson),
      'lifeApplicationsJson': serializer.toJson<String>(lifeApplicationsJson),
    };
  }

  HadithData copyWith({
    int? id,
    int? bookId,
    int? categoryId,
    String? narrator,
    String? textContent,
    String? source,
    String? explanation,
    String? vocabularyJson,
    String? lifeApplicationsJson,
  }) => HadithData(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    categoryId: categoryId ?? this.categoryId,
    narrator: narrator ?? this.narrator,
    textContent: textContent ?? this.textContent,
    source: source ?? this.source,
    explanation: explanation ?? this.explanation,
    vocabularyJson: vocabularyJson ?? this.vocabularyJson,
    lifeApplicationsJson: lifeApplicationsJson ?? this.lifeApplicationsJson,
  );
  HadithData copyWithCompanion(HadithsCompanion data) {
    return HadithData(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      narrator: data.narrator.present ? data.narrator.value : this.narrator,
      textContent: data.textContent.present
          ? data.textContent.value
          : this.textContent,
      source: data.source.present ? data.source.value : this.source,
      explanation: data.explanation.present
          ? data.explanation.value
          : this.explanation,
      vocabularyJson: data.vocabularyJson.present
          ? data.vocabularyJson.value
          : this.vocabularyJson,
      lifeApplicationsJson: data.lifeApplicationsJson.present
          ? data.lifeApplicationsJson.value
          : this.lifeApplicationsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HadithData(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('categoryId: $categoryId, ')
          ..write('narrator: $narrator, ')
          ..write('textContent: $textContent, ')
          ..write('source: $source, ')
          ..write('explanation: $explanation, ')
          ..write('vocabularyJson: $vocabularyJson, ')
          ..write('lifeApplicationsJson: $lifeApplicationsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookId,
    categoryId,
    narrator,
    textContent,
    source,
    explanation,
    vocabularyJson,
    lifeApplicationsJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HadithData &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.categoryId == this.categoryId &&
          other.narrator == this.narrator &&
          other.textContent == this.textContent &&
          other.source == this.source &&
          other.explanation == this.explanation &&
          other.vocabularyJson == this.vocabularyJson &&
          other.lifeApplicationsJson == this.lifeApplicationsJson);
}

class HadithsCompanion extends UpdateCompanion<HadithData> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<int> categoryId;
  final Value<String> narrator;
  final Value<String> textContent;
  final Value<String> source;
  final Value<String> explanation;
  final Value<String> vocabularyJson;
  final Value<String> lifeApplicationsJson;
  const HadithsCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.narrator = const Value.absent(),
    this.textContent = const Value.absent(),
    this.source = const Value.absent(),
    this.explanation = const Value.absent(),
    this.vocabularyJson = const Value.absent(),
    this.lifeApplicationsJson = const Value.absent(),
  });
  HadithsCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    required int categoryId,
    this.narrator = const Value.absent(),
    required String textContent,
    this.source = const Value.absent(),
    this.explanation = const Value.absent(),
    this.vocabularyJson = const Value.absent(),
    this.lifeApplicationsJson = const Value.absent(),
  }) : bookId = Value(bookId),
       categoryId = Value(categoryId),
       textContent = Value(textContent);
  static Insertable<HadithData> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<int>? categoryId,
    Expression<String>? narrator,
    Expression<String>? textContent,
    Expression<String>? source,
    Expression<String>? explanation,
    Expression<String>? vocabularyJson,
    Expression<String>? lifeApplicationsJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (categoryId != null) 'category_id': categoryId,
      if (narrator != null) 'narrator': narrator,
      if (textContent != null) 'text': textContent,
      if (source != null) 'source': source,
      if (explanation != null) 'explanation': explanation,
      if (vocabularyJson != null) 'vocabulary_json': vocabularyJson,
      if (lifeApplicationsJson != null)
        'life_applications_json': lifeApplicationsJson,
    });
  }

  HadithsCompanion copyWith({
    Value<int>? id,
    Value<int>? bookId,
    Value<int>? categoryId,
    Value<String>? narrator,
    Value<String>? textContent,
    Value<String>? source,
    Value<String>? explanation,
    Value<String>? vocabularyJson,
    Value<String>? lifeApplicationsJson,
  }) {
    return HadithsCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      categoryId: categoryId ?? this.categoryId,
      narrator: narrator ?? this.narrator,
      textContent: textContent ?? this.textContent,
      source: source ?? this.source,
      explanation: explanation ?? this.explanation,
      vocabularyJson: vocabularyJson ?? this.vocabularyJson,
      lifeApplicationsJson: lifeApplicationsJson ?? this.lifeApplicationsJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (narrator.present) {
      map['narrator'] = Variable<String>(narrator.value);
    }
    if (textContent.present) {
      map['text'] = Variable<String>(textContent.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    if (vocabularyJson.present) {
      map['vocabulary_json'] = Variable<String>(vocabularyJson.value);
    }
    if (lifeApplicationsJson.present) {
      map['life_applications_json'] = Variable<String>(
        lifeApplicationsJson.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HadithsCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('categoryId: $categoryId, ')
          ..write('narrator: $narrator, ')
          ..write('textContent: $textContent, ')
          ..write('source: $source, ')
          ..write('explanation: $explanation, ')
          ..write('vocabularyJson: $vocabularyJson, ')
          ..write('lifeApplicationsJson: $lifeApplicationsJson')
          ..write(')'))
        .toString();
  }
}

class $ReligiousTasksTable extends ReligiousTasks
    with TableInfo<$ReligiousTasksTable, ReligiousTaskData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReligiousTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('default'),
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('daily'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, type, frequency, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'religious_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReligiousTaskData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReligiousTaskData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReligiousTaskData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ReligiousTasksTable createAlias(String alias) {
    return $ReligiousTasksTable(attachedDatabase, alias);
  }
}

class ReligiousTaskData extends DataClass
    implements Insertable<ReligiousTaskData> {
  final int id;
  final String title;
  final String type;
  final String frequency;
  final DateTime createdAt;
  const ReligiousTaskData({
    required this.id,
    required this.title,
    required this.type,
    required this.frequency,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['type'] = Variable<String>(type);
    map['frequency'] = Variable<String>(frequency);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ReligiousTasksCompanion toCompanion(bool nullToAbsent) {
    return ReligiousTasksCompanion(
      id: Value(id),
      title: Value(title),
      type: Value(type),
      frequency: Value(frequency),
      createdAt: Value(createdAt),
    );
  }

  factory ReligiousTaskData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReligiousTaskData(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      type: serializer.fromJson<String>(json['type']),
      frequency: serializer.fromJson<String>(json['frequency']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'type': serializer.toJson<String>(type),
      'frequency': serializer.toJson<String>(frequency),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ReligiousTaskData copyWith({
    int? id,
    String? title,
    String? type,
    String? frequency,
    DateTime? createdAt,
  }) => ReligiousTaskData(
    id: id ?? this.id,
    title: title ?? this.title,
    type: type ?? this.type,
    frequency: frequency ?? this.frequency,
    createdAt: createdAt ?? this.createdAt,
  );
  ReligiousTaskData copyWithCompanion(ReligiousTasksCompanion data) {
    return ReligiousTaskData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      type: data.type.present ? data.type.value : this.type,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReligiousTaskData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('frequency: $frequency, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, type, frequency, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReligiousTaskData &&
          other.id == this.id &&
          other.title == this.title &&
          other.type == this.type &&
          other.frequency == this.frequency &&
          other.createdAt == this.createdAt);
}

class ReligiousTasksCompanion extends UpdateCompanion<ReligiousTaskData> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> type;
  final Value<String> frequency;
  final Value<DateTime> createdAt;
  const ReligiousTasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.type = const Value.absent(),
    this.frequency = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ReligiousTasksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.type = const Value.absent(),
    this.frequency = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : title = Value(title);
  static Insertable<ReligiousTaskData> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? type,
    Expression<String>? frequency,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (type != null) 'type': type,
      if (frequency != null) 'frequency': frequency,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ReligiousTasksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? type,
    Value<String>? frequency,
    Value<DateTime>? createdAt,
  }) {
    return ReligiousTasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReligiousTasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('frequency: $frequency, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TaskCompletionsTable extends TaskCompletions
    with TableInfo<$TaskCompletionsTable, TaskCompletionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskCompletionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES religious_tasks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, taskId, date, completed];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_completions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskCompletionData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskCompletionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskCompletionData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}task_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
    );
  }

  @override
  $TaskCompletionsTable createAlias(String alias) {
    return $TaskCompletionsTable(attachedDatabase, alias);
  }
}

class TaskCompletionData extends DataClass
    implements Insertable<TaskCompletionData> {
  final int id;
  final int taskId;
  final String date;
  final bool completed;
  const TaskCompletionData({
    required this.id,
    required this.taskId,
    required this.date,
    required this.completed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['task_id'] = Variable<int>(taskId);
    map['date'] = Variable<String>(date);
    map['completed'] = Variable<bool>(completed);
    return map;
  }

  TaskCompletionsCompanion toCompanion(bool nullToAbsent) {
    return TaskCompletionsCompanion(
      id: Value(id),
      taskId: Value(taskId),
      date: Value(date),
      completed: Value(completed),
    );
  }

  factory TaskCompletionData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskCompletionData(
      id: serializer.fromJson<int>(json['id']),
      taskId: serializer.fromJson<int>(json['taskId']),
      date: serializer.fromJson<String>(json['date']),
      completed: serializer.fromJson<bool>(json['completed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'taskId': serializer.toJson<int>(taskId),
      'date': serializer.toJson<String>(date),
      'completed': serializer.toJson<bool>(completed),
    };
  }

  TaskCompletionData copyWith({
    int? id,
    int? taskId,
    String? date,
    bool? completed,
  }) => TaskCompletionData(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    date: date ?? this.date,
    completed: completed ?? this.completed,
  );
  TaskCompletionData copyWithCompanion(TaskCompletionsCompanion data) {
    return TaskCompletionData(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      date: data.date.present ? data.date.value : this.date,
      completed: data.completed.present ? data.completed.value : this.completed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskCompletionData(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('date: $date, ')
          ..write('completed: $completed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, taskId, date, completed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskCompletionData &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.date == this.date &&
          other.completed == this.completed);
}

class TaskCompletionsCompanion extends UpdateCompanion<TaskCompletionData> {
  final Value<int> id;
  final Value<int> taskId;
  final Value<String> date;
  final Value<bool> completed;
  const TaskCompletionsCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.date = const Value.absent(),
    this.completed = const Value.absent(),
  });
  TaskCompletionsCompanion.insert({
    this.id = const Value.absent(),
    required int taskId,
    required String date,
    this.completed = const Value.absent(),
  }) : taskId = Value(taskId),
       date = Value(date);
  static Insertable<TaskCompletionData> custom({
    Expression<int>? id,
    Expression<int>? taskId,
    Expression<String>? date,
    Expression<bool>? completed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (date != null) 'date': date,
      if (completed != null) 'completed': completed,
    });
  }

  TaskCompletionsCompanion copyWith({
    Value<int>? id,
    Value<int>? taskId,
    Value<String>? date,
    Value<bool>? completed,
  }) {
    return TaskCompletionsCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      date: date ?? this.date,
      completed: completed ?? this.completed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskCompletionsCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('date: $date, ')
          ..write('completed: $completed')
          ..write(')'))
        .toString();
  }
}

class $UserStatsTable extends UserStats
    with TableInfo<$UserStatsTable, UserStatData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserStatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quranPagesReadMeta = const VerificationMeta(
    'quranPagesRead',
  );
  @override
  late final GeneratedColumn<int> quranPagesRead = GeneratedColumn<int>(
    'quran_pages_read',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _tasbihCountMeta = const VerificationMeta(
    'tasbihCount',
  );
  @override
  late final GeneratedColumn<int> tasbihCount = GeneratedColumn<int>(
    'tasbih_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _adhkarCompletedMeta = const VerificationMeta(
    'adhkarCompleted',
  );
  @override
  late final GeneratedColumn<int> adhkarCompleted = GeneratedColumn<int>(
    'adhkar_completed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    quranPagesRead,
    tasbihCount,
    adhkarCompleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_stats';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserStatData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('quran_pages_read')) {
      context.handle(
        _quranPagesReadMeta,
        quranPagesRead.isAcceptableOrUnknown(
          data['quran_pages_read']!,
          _quranPagesReadMeta,
        ),
      );
    }
    if (data.containsKey('tasbih_count')) {
      context.handle(
        _tasbihCountMeta,
        tasbihCount.isAcceptableOrUnknown(
          data['tasbih_count']!,
          _tasbihCountMeta,
        ),
      );
    }
    if (data.containsKey('adhkar_completed')) {
      context.handle(
        _adhkarCompletedMeta,
        adhkarCompleted.isAcceptableOrUnknown(
          data['adhkar_completed']!,
          _adhkarCompletedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserStatData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserStatData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      quranPagesRead: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quran_pages_read'],
      )!,
      tasbihCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tasbih_count'],
      )!,
      adhkarCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}adhkar_completed'],
      )!,
    );
  }

  @override
  $UserStatsTable createAlias(String alias) {
    return $UserStatsTable(attachedDatabase, alias);
  }
}

class UserStatData extends DataClass implements Insertable<UserStatData> {
  final int id;
  final String date;
  final int quranPagesRead;
  final int tasbihCount;
  final int adhkarCompleted;
  const UserStatData({
    required this.id,
    required this.date,
    required this.quranPagesRead,
    required this.tasbihCount,
    required this.adhkarCompleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['quran_pages_read'] = Variable<int>(quranPagesRead);
    map['tasbih_count'] = Variable<int>(tasbihCount);
    map['adhkar_completed'] = Variable<int>(adhkarCompleted);
    return map;
  }

  UserStatsCompanion toCompanion(bool nullToAbsent) {
    return UserStatsCompanion(
      id: Value(id),
      date: Value(date),
      quranPagesRead: Value(quranPagesRead),
      tasbihCount: Value(tasbihCount),
      adhkarCompleted: Value(adhkarCompleted),
    );
  }

  factory UserStatData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserStatData(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      quranPagesRead: serializer.fromJson<int>(json['quranPagesRead']),
      tasbihCount: serializer.fromJson<int>(json['tasbihCount']),
      adhkarCompleted: serializer.fromJson<int>(json['adhkarCompleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'quranPagesRead': serializer.toJson<int>(quranPagesRead),
      'tasbihCount': serializer.toJson<int>(tasbihCount),
      'adhkarCompleted': serializer.toJson<int>(adhkarCompleted),
    };
  }

  UserStatData copyWith({
    int? id,
    String? date,
    int? quranPagesRead,
    int? tasbihCount,
    int? adhkarCompleted,
  }) => UserStatData(
    id: id ?? this.id,
    date: date ?? this.date,
    quranPagesRead: quranPagesRead ?? this.quranPagesRead,
    tasbihCount: tasbihCount ?? this.tasbihCount,
    adhkarCompleted: adhkarCompleted ?? this.adhkarCompleted,
  );
  UserStatData copyWithCompanion(UserStatsCompanion data) {
    return UserStatData(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      quranPagesRead: data.quranPagesRead.present
          ? data.quranPagesRead.value
          : this.quranPagesRead,
      tasbihCount: data.tasbihCount.present
          ? data.tasbihCount.value
          : this.tasbihCount,
      adhkarCompleted: data.adhkarCompleted.present
          ? data.adhkarCompleted.value
          : this.adhkarCompleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserStatData(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('quranPagesRead: $quranPagesRead, ')
          ..write('tasbihCount: $tasbihCount, ')
          ..write('adhkarCompleted: $adhkarCompleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, date, quranPagesRead, tasbihCount, adhkarCompleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserStatData &&
          other.id == this.id &&
          other.date == this.date &&
          other.quranPagesRead == this.quranPagesRead &&
          other.tasbihCount == this.tasbihCount &&
          other.adhkarCompleted == this.adhkarCompleted);
}

class UserStatsCompanion extends UpdateCompanion<UserStatData> {
  final Value<int> id;
  final Value<String> date;
  final Value<int> quranPagesRead;
  final Value<int> tasbihCount;
  final Value<int> adhkarCompleted;
  const UserStatsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.quranPagesRead = const Value.absent(),
    this.tasbihCount = const Value.absent(),
    this.adhkarCompleted = const Value.absent(),
  });
  UserStatsCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    this.quranPagesRead = const Value.absent(),
    this.tasbihCount = const Value.absent(),
    this.adhkarCompleted = const Value.absent(),
  }) : date = Value(date);
  static Insertable<UserStatData> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<int>? quranPagesRead,
    Expression<int>? tasbihCount,
    Expression<int>? adhkarCompleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (quranPagesRead != null) 'quran_pages_read': quranPagesRead,
      if (tasbihCount != null) 'tasbih_count': tasbihCount,
      if (adhkarCompleted != null) 'adhkar_completed': adhkarCompleted,
    });
  }

  UserStatsCompanion copyWith({
    Value<int>? id,
    Value<String>? date,
    Value<int>? quranPagesRead,
    Value<int>? tasbihCount,
    Value<int>? adhkarCompleted,
  }) {
    return UserStatsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      quranPagesRead: quranPagesRead ?? this.quranPagesRead,
      tasbihCount: tasbihCount ?? this.tasbihCount,
      adhkarCompleted: adhkarCompleted ?? this.adhkarCompleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (quranPagesRead.present) {
      map['quran_pages_read'] = Variable<int>(quranPagesRead.value);
    }
    if (tasbihCount.present) {
      map['tasbih_count'] = Variable<int>(tasbihCount.value);
    }
    if (adhkarCompleted.present) {
      map['adhkar_completed'] = Variable<int>(adhkarCompleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserStatsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('quranPagesRead: $quranPagesRead, ')
          ..write('tasbihCount: $tasbihCount, ')
          ..write('adhkarCompleted: $adhkarCompleted')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SurahsTable surahs = $SurahsTable(this);
  late final $AyahsTable ayahs = $AyahsTable(this);
  late final $BookmarksTable bookmarks = $BookmarksTable(this);
  late final $ProgressTable progress = $ProgressTable(this);
  late final $FavoritesTable favorites = $FavoritesTable(this);
  late final $AdhkarCategoriesTable adhkarCategories = $AdhkarCategoriesTable(
    this,
  );
  late final $AdhkarItemsTable adhkarItems = $AdhkarItemsTable(this);
  late final $AdhkarProgressesTable adhkarProgresses = $AdhkarProgressesTable(
    this,
  );
  late final $TasbihsTable tasbihs = $TasbihsTable(this);
  late final $HadithBooksTable hadithBooks = $HadithBooksTable(this);
  late final $HadithCategoriesTable hadithCategories = $HadithCategoriesTable(
    this,
  );
  late final $HadithsTable hadiths = $HadithsTable(this);
  late final $ReligiousTasksTable religiousTasks = $ReligiousTasksTable(this);
  late final $TaskCompletionsTable taskCompletions = $TaskCompletionsTable(
    this,
  );
  late final $UserStatsTable userStats = $UserStatsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    surahs,
    ayahs,
    bookmarks,
    progress,
    favorites,
    adhkarCategories,
    adhkarItems,
    adhkarProgresses,
    tasbihs,
    hadithBooks,
    hadithCategories,
    hadiths,
    religiousTasks,
    taskCompletions,
    userStats,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'surahs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('ayahs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'adhkar_categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('adhkar_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'adhkar_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('adhkar_progresses', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'hadith_books',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('hadiths', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'hadith_categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('hadiths', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'religious_tasks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('task_completions', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$SurahsTableCreateCompanionBuilder =
    SurahsCompanion Function({
      Value<int> number,
      required String name,
      required String nameArabic,
      required String nameEnglish,
      required String englishNameTranslation,
      required String revelationType,
      required int numberOfAyahs,
    });
typedef $$SurahsTableUpdateCompanionBuilder =
    SurahsCompanion Function({
      Value<int> number,
      Value<String> name,
      Value<String> nameArabic,
      Value<String> nameEnglish,
      Value<String> englishNameTranslation,
      Value<String> revelationType,
      Value<int> numberOfAyahs,
    });

final class $$SurahsTableReferences
    extends BaseReferences<_$AppDatabase, $SurahsTable, SurahData> {
  $$SurahsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AyahsTable, List<AyahData>> _ayahsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.ayahs,
    aliasName: $_aliasNameGenerator(db.surahs.number, db.ayahs.surahNumber),
  );

  $$AyahsTableProcessedTableManager get ayahsRefs {
    final manager = $$AyahsTableTableManager($_db, $_db.ayahs).filter(
      (f) => f.surahNumber.number.sqlEquals($_itemColumn<int>('number')!),
    );

    final cache = $_typedResult.readTableOrNull(_ayahsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SurahsTableFilterComposer
    extends Composer<_$AppDatabase, $SurahsTable> {
  $$SurahsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameArabic => $composableBuilder(
    column: $table.nameArabic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEnglish => $composableBuilder(
    column: $table.nameEnglish,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get englishNameTranslation => $composableBuilder(
    column: $table.englishNameTranslation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get revelationType => $composableBuilder(
    column: $table.revelationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get numberOfAyahs => $composableBuilder(
    column: $table.numberOfAyahs,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> ayahsRefs(
    Expression<bool> Function($$AyahsTableFilterComposer f) f,
  ) {
    final $$AyahsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.number,
      referencedTable: $db.ayahs,
      getReferencedColumn: (t) => t.surahNumber,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AyahsTableFilterComposer(
            $db: $db,
            $table: $db.ayahs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SurahsTableOrderingComposer
    extends Composer<_$AppDatabase, $SurahsTable> {
  $$SurahsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameArabic => $composableBuilder(
    column: $table.nameArabic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEnglish => $composableBuilder(
    column: $table.nameEnglish,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get englishNameTranslation => $composableBuilder(
    column: $table.englishNameTranslation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get revelationType => $composableBuilder(
    column: $table.revelationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get numberOfAyahs => $composableBuilder(
    column: $table.numberOfAyahs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SurahsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SurahsTable> {
  $$SurahsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameArabic => $composableBuilder(
    column: $table.nameArabic,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nameEnglish => $composableBuilder(
    column: $table.nameEnglish,
    builder: (column) => column,
  );

  GeneratedColumn<String> get englishNameTranslation => $composableBuilder(
    column: $table.englishNameTranslation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get revelationType => $composableBuilder(
    column: $table.revelationType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get numberOfAyahs => $composableBuilder(
    column: $table.numberOfAyahs,
    builder: (column) => column,
  );

  Expression<T> ayahsRefs<T extends Object>(
    Expression<T> Function($$AyahsTableAnnotationComposer a) f,
  ) {
    final $$AyahsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.number,
      referencedTable: $db.ayahs,
      getReferencedColumn: (t) => t.surahNumber,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AyahsTableAnnotationComposer(
            $db: $db,
            $table: $db.ayahs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SurahsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SurahsTable,
          SurahData,
          $$SurahsTableFilterComposer,
          $$SurahsTableOrderingComposer,
          $$SurahsTableAnnotationComposer,
          $$SurahsTableCreateCompanionBuilder,
          $$SurahsTableUpdateCompanionBuilder,
          (SurahData, $$SurahsTableReferences),
          SurahData,
          PrefetchHooks Function({bool ayahsRefs})
        > {
  $$SurahsTableTableManager(_$AppDatabase db, $SurahsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SurahsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SurahsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SurahsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> number = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> nameArabic = const Value.absent(),
                Value<String> nameEnglish = const Value.absent(),
                Value<String> englishNameTranslation = const Value.absent(),
                Value<String> revelationType = const Value.absent(),
                Value<int> numberOfAyahs = const Value.absent(),
              }) => SurahsCompanion(
                number: number,
                name: name,
                nameArabic: nameArabic,
                nameEnglish: nameEnglish,
                englishNameTranslation: englishNameTranslation,
                revelationType: revelationType,
                numberOfAyahs: numberOfAyahs,
              ),
          createCompanionCallback:
              ({
                Value<int> number = const Value.absent(),
                required String name,
                required String nameArabic,
                required String nameEnglish,
                required String englishNameTranslation,
                required String revelationType,
                required int numberOfAyahs,
              }) => SurahsCompanion.insert(
                number: number,
                name: name,
                nameArabic: nameArabic,
                nameEnglish: nameEnglish,
                englishNameTranslation: englishNameTranslation,
                revelationType: revelationType,
                numberOfAyahs: numberOfAyahs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$SurahsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({ayahsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (ayahsRefs) db.ayahs],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (ayahsRefs)
                    await $_getPrefetchedData<
                      SurahData,
                      $SurahsTable,
                      AyahData
                    >(
                      currentTable: table,
                      referencedTable: $$SurahsTableReferences._ayahsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$SurahsTableReferences(db, table, p0).ayahsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.surahNumber == item.number,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SurahsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SurahsTable,
      SurahData,
      $$SurahsTableFilterComposer,
      $$SurahsTableOrderingComposer,
      $$SurahsTableAnnotationComposer,
      $$SurahsTableCreateCompanionBuilder,
      $$SurahsTableUpdateCompanionBuilder,
      (SurahData, $$SurahsTableReferences),
      SurahData,
      PrefetchHooks Function({bool ayahsRefs})
    >;
typedef $$AyahsTableCreateCompanionBuilder =
    AyahsCompanion Function({
      Value<int> id,
      required int number,
      required int numberInSurah,
      required int surahNumber,
      required String textContent,
      required String textUthmani,
      required int juz,
      required int hizb,
      required int manzil,
      required int ruku,
      required int page,
      Value<bool> sajda,
    });
typedef $$AyahsTableUpdateCompanionBuilder =
    AyahsCompanion Function({
      Value<int> id,
      Value<int> number,
      Value<int> numberInSurah,
      Value<int> surahNumber,
      Value<String> textContent,
      Value<String> textUthmani,
      Value<int> juz,
      Value<int> hizb,
      Value<int> manzil,
      Value<int> ruku,
      Value<int> page,
      Value<bool> sajda,
    });

final class $$AyahsTableReferences
    extends BaseReferences<_$AppDatabase, $AyahsTable, AyahData> {
  $$AyahsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SurahsTable _surahNumberTable(_$AppDatabase db) =>
      db.surahs.createAlias(
        $_aliasNameGenerator(db.ayahs.surahNumber, db.surahs.number),
      );

  $$SurahsTableProcessedTableManager get surahNumber {
    final $_column = $_itemColumn<int>('surah_number')!;

    final manager = $$SurahsTableTableManager(
      $_db,
      $_db.surahs,
    ).filter((f) => f.number.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_surahNumberTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AyahsTableFilterComposer extends Composer<_$AppDatabase, $AyahsTable> {
  $$AyahsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get numberInSurah => $composableBuilder(
    column: $table.numberInSurah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textUthmani => $composableBuilder(
    column: $table.textUthmani,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get juz => $composableBuilder(
    column: $table.juz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hizb => $composableBuilder(
    column: $table.hizb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get manzil => $composableBuilder(
    column: $table.manzil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ruku => $composableBuilder(
    column: $table.ruku,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get sajda => $composableBuilder(
    column: $table.sajda,
    builder: (column) => ColumnFilters(column),
  );

  $$SurahsTableFilterComposer get surahNumber {
    final $$SurahsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.surahNumber,
      referencedTable: $db.surahs,
      getReferencedColumn: (t) => t.number,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SurahsTableFilterComposer(
            $db: $db,
            $table: $db.surahs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AyahsTableOrderingComposer
    extends Composer<_$AppDatabase, $AyahsTable> {
  $$AyahsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get numberInSurah => $composableBuilder(
    column: $table.numberInSurah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textUthmani => $composableBuilder(
    column: $table.textUthmani,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get juz => $composableBuilder(
    column: $table.juz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hizb => $composableBuilder(
    column: $table.hizb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get manzil => $composableBuilder(
    column: $table.manzil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ruku => $composableBuilder(
    column: $table.ruku,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get sajda => $composableBuilder(
    column: $table.sajda,
    builder: (column) => ColumnOrderings(column),
  );

  $$SurahsTableOrderingComposer get surahNumber {
    final $$SurahsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.surahNumber,
      referencedTable: $db.surahs,
      getReferencedColumn: (t) => t.number,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SurahsTableOrderingComposer(
            $db: $db,
            $table: $db.surahs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AyahsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AyahsTable> {
  $$AyahsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<int> get numberInSurah => $composableBuilder(
    column: $table.numberInSurah,
    builder: (column) => column,
  );

  GeneratedColumn<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get textUthmani => $composableBuilder(
    column: $table.textUthmani,
    builder: (column) => column,
  );

  GeneratedColumn<int> get juz =>
      $composableBuilder(column: $table.juz, builder: (column) => column);

  GeneratedColumn<int> get hizb =>
      $composableBuilder(column: $table.hizb, builder: (column) => column);

  GeneratedColumn<int> get manzil =>
      $composableBuilder(column: $table.manzil, builder: (column) => column);

  GeneratedColumn<int> get ruku =>
      $composableBuilder(column: $table.ruku, builder: (column) => column);

  GeneratedColumn<int> get page =>
      $composableBuilder(column: $table.page, builder: (column) => column);

  GeneratedColumn<bool> get sajda =>
      $composableBuilder(column: $table.sajda, builder: (column) => column);

  $$SurahsTableAnnotationComposer get surahNumber {
    final $$SurahsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.surahNumber,
      referencedTable: $db.surahs,
      getReferencedColumn: (t) => t.number,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SurahsTableAnnotationComposer(
            $db: $db,
            $table: $db.surahs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AyahsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AyahsTable,
          AyahData,
          $$AyahsTableFilterComposer,
          $$AyahsTableOrderingComposer,
          $$AyahsTableAnnotationComposer,
          $$AyahsTableCreateCompanionBuilder,
          $$AyahsTableUpdateCompanionBuilder,
          (AyahData, $$AyahsTableReferences),
          AyahData,
          PrefetchHooks Function({bool surahNumber})
        > {
  $$AyahsTableTableManager(_$AppDatabase db, $AyahsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AyahsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AyahsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AyahsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> number = const Value.absent(),
                Value<int> numberInSurah = const Value.absent(),
                Value<int> surahNumber = const Value.absent(),
                Value<String> textContent = const Value.absent(),
                Value<String> textUthmani = const Value.absent(),
                Value<int> juz = const Value.absent(),
                Value<int> hizb = const Value.absent(),
                Value<int> manzil = const Value.absent(),
                Value<int> ruku = const Value.absent(),
                Value<int> page = const Value.absent(),
                Value<bool> sajda = const Value.absent(),
              }) => AyahsCompanion(
                id: id,
                number: number,
                numberInSurah: numberInSurah,
                surahNumber: surahNumber,
                textContent: textContent,
                textUthmani: textUthmani,
                juz: juz,
                hizb: hizb,
                manzil: manzil,
                ruku: ruku,
                page: page,
                sajda: sajda,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int number,
                required int numberInSurah,
                required int surahNumber,
                required String textContent,
                required String textUthmani,
                required int juz,
                required int hizb,
                required int manzil,
                required int ruku,
                required int page,
                Value<bool> sajda = const Value.absent(),
              }) => AyahsCompanion.insert(
                id: id,
                number: number,
                numberInSurah: numberInSurah,
                surahNumber: surahNumber,
                textContent: textContent,
                textUthmani: textUthmani,
                juz: juz,
                hizb: hizb,
                manzil: manzil,
                ruku: ruku,
                page: page,
                sajda: sajda,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$AyahsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({surahNumber = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (surahNumber) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.surahNumber,
                                referencedTable: $$AyahsTableReferences
                                    ._surahNumberTable(db),
                                referencedColumn: $$AyahsTableReferences
                                    ._surahNumberTable(db)
                                    .number,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AyahsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AyahsTable,
      AyahData,
      $$AyahsTableFilterComposer,
      $$AyahsTableOrderingComposer,
      $$AyahsTableAnnotationComposer,
      $$AyahsTableCreateCompanionBuilder,
      $$AyahsTableUpdateCompanionBuilder,
      (AyahData, $$AyahsTableReferences),
      AyahData,
      PrefetchHooks Function({bool surahNumber})
    >;
typedef $$BookmarksTableCreateCompanionBuilder =
    BookmarksCompanion Function({
      Value<int> id,
      required int surahNumber,
      required int ayahNumber,
      Value<DateTime> createdAt,
    });
typedef $$BookmarksTableUpdateCompanionBuilder =
    BookmarksCompanion Function({
      Value<int> id,
      Value<int> surahNumber,
      Value<int> ayahNumber,
      Value<DateTime> createdAt,
    });

class $$BookmarksTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookmarksTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookmarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BookmarksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookmarksTable,
          BookmarkData,
          $$BookmarksTableFilterComposer,
          $$BookmarksTableOrderingComposer,
          $$BookmarksTableAnnotationComposer,
          $$BookmarksTableCreateCompanionBuilder,
          $$BookmarksTableUpdateCompanionBuilder,
          (
            BookmarkData,
            BaseReferences<_$AppDatabase, $BookmarksTable, BookmarkData>,
          ),
          BookmarkData,
          PrefetchHooks Function()
        > {
  $$BookmarksTableTableManager(_$AppDatabase db, $BookmarksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> surahNumber = const Value.absent(),
                Value<int> ayahNumber = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BookmarksCompanion(
                id: id,
                surahNumber: surahNumber,
                ayahNumber: ayahNumber,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int surahNumber,
                required int ayahNumber,
                Value<DateTime> createdAt = const Value.absent(),
              }) => BookmarksCompanion.insert(
                id: id,
                surahNumber: surahNumber,
                ayahNumber: ayahNumber,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookmarksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookmarksTable,
      BookmarkData,
      $$BookmarksTableFilterComposer,
      $$BookmarksTableOrderingComposer,
      $$BookmarksTableAnnotationComposer,
      $$BookmarksTableCreateCompanionBuilder,
      $$BookmarksTableUpdateCompanionBuilder,
      (
        BookmarkData,
        BaseReferences<_$AppDatabase, $BookmarksTable, BookmarkData>,
      ),
      BookmarkData,
      PrefetchHooks Function()
    >;
typedef $$ProgressTableCreateCompanionBuilder =
    ProgressCompanion Function({
      Value<int> id,
      required int lastReadPage,
      Value<DateTime> updatedAt,
    });
typedef $$ProgressTableUpdateCompanionBuilder =
    ProgressCompanion Function({
      Value<int> id,
      Value<int> lastReadPage,
      Value<DateTime> updatedAt,
    });

class $$ProgressTableFilterComposer
    extends Composer<_$AppDatabase, $ProgressTable> {
  $$ProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastReadPage => $composableBuilder(
    column: $table.lastReadPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $ProgressTable> {
  $$ProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastReadPage => $composableBuilder(
    column: $table.lastReadPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProgressTable> {
  $$ProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get lastReadPage => $composableBuilder(
    column: $table.lastReadPage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProgressTable,
          ProgressData,
          $$ProgressTableFilterComposer,
          $$ProgressTableOrderingComposer,
          $$ProgressTableAnnotationComposer,
          $$ProgressTableCreateCompanionBuilder,
          $$ProgressTableUpdateCompanionBuilder,
          (
            ProgressData,
            BaseReferences<_$AppDatabase, $ProgressTable, ProgressData>,
          ),
          ProgressData,
          PrefetchHooks Function()
        > {
  $$ProgressTableTableManager(_$AppDatabase db, $ProgressTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> lastReadPage = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ProgressCompanion(
                id: id,
                lastReadPage: lastReadPage,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int lastReadPage,
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ProgressCompanion.insert(
                id: id,
                lastReadPage: lastReadPage,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProgressTable,
      ProgressData,
      $$ProgressTableFilterComposer,
      $$ProgressTableOrderingComposer,
      $$ProgressTableAnnotationComposer,
      $$ProgressTableCreateCompanionBuilder,
      $$ProgressTableUpdateCompanionBuilder,
      (
        ProgressData,
        BaseReferences<_$AppDatabase, $ProgressTable, ProgressData>,
      ),
      ProgressData,
      PrefetchHooks Function()
    >;
typedef $$FavoritesTableCreateCompanionBuilder =
    FavoritesCompanion Function({
      Value<int> id,
      required String type,
      required int itemId,
      Value<int?> surahNumber,
      Value<int?> ayahNumber,
      Value<int?> hadithId,
      Value<DateTime> createdAt,
    });
typedef $$FavoritesTableUpdateCompanionBuilder =
    FavoritesCompanion Function({
      Value<int> id,
      Value<String> type,
      Value<int> itemId,
      Value<int?> surahNumber,
      Value<int?> ayahNumber,
      Value<int?> hadithId,
      Value<DateTime> createdAt,
    });

class $$FavoritesTableFilterComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hadithId => $composableBuilder(
    column: $table.hadithId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoritesTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hadithId => $composableBuilder(
    column: $table.hadithId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoritesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hadithId =>
      $composableBuilder(column: $table.hadithId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FavoritesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoritesTable,
          FavoriteData,
          $$FavoritesTableFilterComposer,
          $$FavoritesTableOrderingComposer,
          $$FavoritesTableAnnotationComposer,
          $$FavoritesTableCreateCompanionBuilder,
          $$FavoritesTableUpdateCompanionBuilder,
          (
            FavoriteData,
            BaseReferences<_$AppDatabase, $FavoritesTable, FavoriteData>,
          ),
          FavoriteData,
          PrefetchHooks Function()
        > {
  $$FavoritesTableTableManager(_$AppDatabase db, $FavoritesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoritesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> itemId = const Value.absent(),
                Value<int?> surahNumber = const Value.absent(),
                Value<int?> ayahNumber = const Value.absent(),
                Value<int?> hadithId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FavoritesCompanion(
                id: id,
                type: type,
                itemId: itemId,
                surahNumber: surahNumber,
                ayahNumber: ayahNumber,
                hadithId: hadithId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String type,
                required int itemId,
                Value<int?> surahNumber = const Value.absent(),
                Value<int?> ayahNumber = const Value.absent(),
                Value<int?> hadithId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FavoritesCompanion.insert(
                id: id,
                type: type,
                itemId: itemId,
                surahNumber: surahNumber,
                ayahNumber: ayahNumber,
                hadithId: hadithId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoritesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoritesTable,
      FavoriteData,
      $$FavoritesTableFilterComposer,
      $$FavoritesTableOrderingComposer,
      $$FavoritesTableAnnotationComposer,
      $$FavoritesTableCreateCompanionBuilder,
      $$FavoritesTableUpdateCompanionBuilder,
      (
        FavoriteData,
        BaseReferences<_$AppDatabase, $FavoritesTable, FavoriteData>,
      ),
      FavoriteData,
      PrefetchHooks Function()
    >;
typedef $$AdhkarCategoriesTableCreateCompanionBuilder =
    AdhkarCategoriesCompanion Function({
      Value<int> id,
      required String title,
      Value<String> description,
    });
typedef $$AdhkarCategoriesTableUpdateCompanionBuilder =
    AdhkarCategoriesCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> description,
    });

final class $$AdhkarCategoriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AdhkarCategoriesTable,
          AdhkarCategoryData
        > {
  $$AdhkarCategoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$AdhkarItemsTable, List<AdhkarItemData>>
  _adhkarItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.adhkarItems,
    aliasName: $_aliasNameGenerator(
      db.adhkarCategories.id,
      db.adhkarItems.categoryId,
    ),
  );

  $$AdhkarItemsTableProcessedTableManager get adhkarItemsRefs {
    final manager = $$AdhkarItemsTableTableManager(
      $_db,
      $_db.adhkarItems,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_adhkarItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AdhkarCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $AdhkarCategoriesTable> {
  $$AdhkarCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> adhkarItemsRefs(
    Expression<bool> Function($$AdhkarItemsTableFilterComposer f) f,
  ) {
    final $$AdhkarItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.adhkarItems,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdhkarItemsTableFilterComposer(
            $db: $db,
            $table: $db.adhkarItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AdhkarCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $AdhkarCategoriesTable> {
  $$AdhkarCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AdhkarCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AdhkarCategoriesTable> {
  $$AdhkarCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  Expression<T> adhkarItemsRefs<T extends Object>(
    Expression<T> Function($$AdhkarItemsTableAnnotationComposer a) f,
  ) {
    final $$AdhkarItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.adhkarItems,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdhkarItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.adhkarItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AdhkarCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AdhkarCategoriesTable,
          AdhkarCategoryData,
          $$AdhkarCategoriesTableFilterComposer,
          $$AdhkarCategoriesTableOrderingComposer,
          $$AdhkarCategoriesTableAnnotationComposer,
          $$AdhkarCategoriesTableCreateCompanionBuilder,
          $$AdhkarCategoriesTableUpdateCompanionBuilder,
          (AdhkarCategoryData, $$AdhkarCategoriesTableReferences),
          AdhkarCategoryData,
          PrefetchHooks Function({bool adhkarItemsRefs})
        > {
  $$AdhkarCategoriesTableTableManager(
    _$AppDatabase db,
    $AdhkarCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AdhkarCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AdhkarCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AdhkarCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
              }) => AdhkarCategoriesCompanion(
                id: id,
                title: title,
                description: description,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String> description = const Value.absent(),
              }) => AdhkarCategoriesCompanion.insert(
                id: id,
                title: title,
                description: description,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AdhkarCategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({adhkarItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (adhkarItemsRefs) db.adhkarItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (adhkarItemsRefs)
                    await $_getPrefetchedData<
                      AdhkarCategoryData,
                      $AdhkarCategoriesTable,
                      AdhkarItemData
                    >(
                      currentTable: table,
                      referencedTable: $$AdhkarCategoriesTableReferences
                          ._adhkarItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AdhkarCategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).adhkarItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AdhkarCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AdhkarCategoriesTable,
      AdhkarCategoryData,
      $$AdhkarCategoriesTableFilterComposer,
      $$AdhkarCategoriesTableOrderingComposer,
      $$AdhkarCategoriesTableAnnotationComposer,
      $$AdhkarCategoriesTableCreateCompanionBuilder,
      $$AdhkarCategoriesTableUpdateCompanionBuilder,
      (AdhkarCategoryData, $$AdhkarCategoriesTableReferences),
      AdhkarCategoryData,
      PrefetchHooks Function({bool adhkarItemsRefs})
    >;
typedef $$AdhkarItemsTableCreateCompanionBuilder =
    AdhkarItemsCompanion Function({
      Value<int> id,
      required int categoryId,
      required String textContent,
      required int targetCount,
      Value<String> reference,
    });
typedef $$AdhkarItemsTableUpdateCompanionBuilder =
    AdhkarItemsCompanion Function({
      Value<int> id,
      Value<int> categoryId,
      Value<String> textContent,
      Value<int> targetCount,
      Value<String> reference,
    });

final class $$AdhkarItemsTableReferences
    extends BaseReferences<_$AppDatabase, $AdhkarItemsTable, AdhkarItemData> {
  $$AdhkarItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AdhkarCategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.adhkarCategories.createAlias(
        $_aliasNameGenerator(db.adhkarItems.categoryId, db.adhkarCategories.id),
      );

  $$AdhkarCategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$AdhkarCategoriesTableTableManager(
      $_db,
      $_db.adhkarCategories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AdhkarProgressesTable, List<AdhkarProgressData>>
  _adhkarProgressesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.adhkarProgresses,
    aliasName: $_aliasNameGenerator(
      db.adhkarItems.id,
      db.adhkarProgresses.itemId,
    ),
  );

  $$AdhkarProgressesTableProcessedTableManager get adhkarProgressesRefs {
    final manager = $$AdhkarProgressesTableTableManager(
      $_db,
      $_db.adhkarProgresses,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _adhkarProgressesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AdhkarItemsTableFilterComposer
    extends Composer<_$AppDatabase, $AdhkarItemsTable> {
  $$AdhkarItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetCount => $composableBuilder(
    column: $table.targetCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  $$AdhkarCategoriesTableFilterComposer get categoryId {
    final $$AdhkarCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.adhkarCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdhkarCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.adhkarCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> adhkarProgressesRefs(
    Expression<bool> Function($$AdhkarProgressesTableFilterComposer f) f,
  ) {
    final $$AdhkarProgressesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.adhkarProgresses,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdhkarProgressesTableFilterComposer(
            $db: $db,
            $table: $db.adhkarProgresses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AdhkarItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $AdhkarItemsTable> {
  $$AdhkarItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetCount => $composableBuilder(
    column: $table.targetCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  $$AdhkarCategoriesTableOrderingComposer get categoryId {
    final $$AdhkarCategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.adhkarCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdhkarCategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.adhkarCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AdhkarItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AdhkarItemsTable> {
  $$AdhkarItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetCount => $composableBuilder(
    column: $table.targetCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  $$AdhkarCategoriesTableAnnotationComposer get categoryId {
    final $$AdhkarCategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.adhkarCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdhkarCategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.adhkarCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> adhkarProgressesRefs<T extends Object>(
    Expression<T> Function($$AdhkarProgressesTableAnnotationComposer a) f,
  ) {
    final $$AdhkarProgressesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.adhkarProgresses,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdhkarProgressesTableAnnotationComposer(
            $db: $db,
            $table: $db.adhkarProgresses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AdhkarItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AdhkarItemsTable,
          AdhkarItemData,
          $$AdhkarItemsTableFilterComposer,
          $$AdhkarItemsTableOrderingComposer,
          $$AdhkarItemsTableAnnotationComposer,
          $$AdhkarItemsTableCreateCompanionBuilder,
          $$AdhkarItemsTableUpdateCompanionBuilder,
          (AdhkarItemData, $$AdhkarItemsTableReferences),
          AdhkarItemData,
          PrefetchHooks Function({bool categoryId, bool adhkarProgressesRefs})
        > {
  $$AdhkarItemsTableTableManager(_$AppDatabase db, $AdhkarItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AdhkarItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AdhkarItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AdhkarItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<String> textContent = const Value.absent(),
                Value<int> targetCount = const Value.absent(),
                Value<String> reference = const Value.absent(),
              }) => AdhkarItemsCompanion(
                id: id,
                categoryId: categoryId,
                textContent: textContent,
                targetCount: targetCount,
                reference: reference,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int categoryId,
                required String textContent,
                required int targetCount,
                Value<String> reference = const Value.absent(),
              }) => AdhkarItemsCompanion.insert(
                id: id,
                categoryId: categoryId,
                textContent: textContent,
                targetCount: targetCount,
                reference: reference,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AdhkarItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({categoryId = false, adhkarProgressesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (adhkarProgressesRefs) db.adhkarProgresses,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable:
                                        $$AdhkarItemsTableReferences
                                            ._categoryIdTable(db),
                                    referencedColumn:
                                        $$AdhkarItemsTableReferences
                                            ._categoryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (adhkarProgressesRefs)
                        await $_getPrefetchedData<
                          AdhkarItemData,
                          $AdhkarItemsTable,
                          AdhkarProgressData
                        >(
                          currentTable: table,
                          referencedTable: $$AdhkarItemsTableReferences
                              ._adhkarProgressesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AdhkarItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).adhkarProgressesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.itemId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AdhkarItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AdhkarItemsTable,
      AdhkarItemData,
      $$AdhkarItemsTableFilterComposer,
      $$AdhkarItemsTableOrderingComposer,
      $$AdhkarItemsTableAnnotationComposer,
      $$AdhkarItemsTableCreateCompanionBuilder,
      $$AdhkarItemsTableUpdateCompanionBuilder,
      (AdhkarItemData, $$AdhkarItemsTableReferences),
      AdhkarItemData,
      PrefetchHooks Function({bool categoryId, bool adhkarProgressesRefs})
    >;
typedef $$AdhkarProgressesTableCreateCompanionBuilder =
    AdhkarProgressesCompanion Function({
      Value<int> id,
      required int itemId,
      Value<int> count,
      required String date,
    });
typedef $$AdhkarProgressesTableUpdateCompanionBuilder =
    AdhkarProgressesCompanion Function({
      Value<int> id,
      Value<int> itemId,
      Value<int> count,
      Value<String> date,
    });

final class $$AdhkarProgressesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AdhkarProgressesTable,
          AdhkarProgressData
        > {
  $$AdhkarProgressesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AdhkarItemsTable _itemIdTable(_$AppDatabase db) =>
      db.adhkarItems.createAlias(
        $_aliasNameGenerator(db.adhkarProgresses.itemId, db.adhkarItems.id),
      );

  $$AdhkarItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<int>('item_id')!;

    final manager = $$AdhkarItemsTableTableManager(
      $_db,
      $_db.adhkarItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AdhkarProgressesTableFilterComposer
    extends Composer<_$AppDatabase, $AdhkarProgressesTable> {
  $$AdhkarProgressesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  $$AdhkarItemsTableFilterComposer get itemId {
    final $$AdhkarItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.adhkarItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdhkarItemsTableFilterComposer(
            $db: $db,
            $table: $db.adhkarItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AdhkarProgressesTableOrderingComposer
    extends Composer<_$AppDatabase, $AdhkarProgressesTable> {
  $$AdhkarProgressesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  $$AdhkarItemsTableOrderingComposer get itemId {
    final $$AdhkarItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.adhkarItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdhkarItemsTableOrderingComposer(
            $db: $db,
            $table: $db.adhkarItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AdhkarProgressesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AdhkarProgressesTable> {
  $$AdhkarProgressesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  $$AdhkarItemsTableAnnotationComposer get itemId {
    final $$AdhkarItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.adhkarItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdhkarItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.adhkarItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AdhkarProgressesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AdhkarProgressesTable,
          AdhkarProgressData,
          $$AdhkarProgressesTableFilterComposer,
          $$AdhkarProgressesTableOrderingComposer,
          $$AdhkarProgressesTableAnnotationComposer,
          $$AdhkarProgressesTableCreateCompanionBuilder,
          $$AdhkarProgressesTableUpdateCompanionBuilder,
          (AdhkarProgressData, $$AdhkarProgressesTableReferences),
          AdhkarProgressData,
          PrefetchHooks Function({bool itemId})
        > {
  $$AdhkarProgressesTableTableManager(
    _$AppDatabase db,
    $AdhkarProgressesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AdhkarProgressesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AdhkarProgressesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AdhkarProgressesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> itemId = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<String> date = const Value.absent(),
              }) => AdhkarProgressesCompanion(
                id: id,
                itemId: itemId,
                count: count,
                date: date,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int itemId,
                Value<int> count = const Value.absent(),
                required String date,
              }) => AdhkarProgressesCompanion.insert(
                id: id,
                itemId: itemId,
                count: count,
                date: date,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AdhkarProgressesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({itemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (itemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.itemId,
                                referencedTable:
                                    $$AdhkarProgressesTableReferences
                                        ._itemIdTable(db),
                                referencedColumn:
                                    $$AdhkarProgressesTableReferences
                                        ._itemIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AdhkarProgressesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AdhkarProgressesTable,
      AdhkarProgressData,
      $$AdhkarProgressesTableFilterComposer,
      $$AdhkarProgressesTableOrderingComposer,
      $$AdhkarProgressesTableAnnotationComposer,
      $$AdhkarProgressesTableCreateCompanionBuilder,
      $$AdhkarProgressesTableUpdateCompanionBuilder,
      (AdhkarProgressData, $$AdhkarProgressesTableReferences),
      AdhkarProgressData,
      PrefetchHooks Function({bool itemId})
    >;
typedef $$TasbihsTableCreateCompanionBuilder =
    TasbihsCompanion Function({
      Value<int> id,
      required String phrase,
      Value<int> count,
      Value<int> target,
      Value<DateTime> updatedAt,
    });
typedef $$TasbihsTableUpdateCompanionBuilder =
    TasbihsCompanion Function({
      Value<int> id,
      Value<String> phrase,
      Value<int> count,
      Value<int> target,
      Value<DateTime> updatedAt,
    });

class $$TasbihsTableFilterComposer
    extends Composer<_$AppDatabase, $TasbihsTable> {
  $$TasbihsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phrase => $composableBuilder(
    column: $table.phrase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasbihsTableOrderingComposer
    extends Composer<_$AppDatabase, $TasbihsTable> {
  $$TasbihsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phrase => $composableBuilder(
    column: $table.phrase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasbihsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasbihsTable> {
  $$TasbihsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get phrase =>
      $composableBuilder(column: $table.phrase, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<int> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TasbihsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasbihsTable,
          TasbihData,
          $$TasbihsTableFilterComposer,
          $$TasbihsTableOrderingComposer,
          $$TasbihsTableAnnotationComposer,
          $$TasbihsTableCreateCompanionBuilder,
          $$TasbihsTableUpdateCompanionBuilder,
          (
            TasbihData,
            BaseReferences<_$AppDatabase, $TasbihsTable, TasbihData>,
          ),
          TasbihData,
          PrefetchHooks Function()
        > {
  $$TasbihsTableTableManager(_$AppDatabase db, $TasbihsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasbihsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasbihsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasbihsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> phrase = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<int> target = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TasbihsCompanion(
                id: id,
                phrase: phrase,
                count: count,
                target: target,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String phrase,
                Value<int> count = const Value.absent(),
                Value<int> target = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TasbihsCompanion.insert(
                id: id,
                phrase: phrase,
                count: count,
                target: target,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasbihsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasbihsTable,
      TasbihData,
      $$TasbihsTableFilterComposer,
      $$TasbihsTableOrderingComposer,
      $$TasbihsTableAnnotationComposer,
      $$TasbihsTableCreateCompanionBuilder,
      $$TasbihsTableUpdateCompanionBuilder,
      (TasbihData, BaseReferences<_$AppDatabase, $TasbihsTable, TasbihData>),
      TasbihData,
      PrefetchHooks Function()
    >;
typedef $$HadithBooksTableCreateCompanionBuilder =
    HadithBooksCompanion Function({
      Value<int> id,
      required String title,
      Value<String> author,
      Value<String> description,
    });
typedef $$HadithBooksTableUpdateCompanionBuilder =
    HadithBooksCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> author,
      Value<String> description,
    });

final class $$HadithBooksTableReferences
    extends BaseReferences<_$AppDatabase, $HadithBooksTable, HadithBookData> {
  $$HadithBooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$HadithsTable, List<HadithData>> _hadithsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.hadiths,
    aliasName: $_aliasNameGenerator(db.hadithBooks.id, db.hadiths.bookId),
  );

  $$HadithsTableProcessedTableManager get hadithsRefs {
    final manager = $$HadithsTableTableManager(
      $_db,
      $_db.hadiths,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_hadithsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HadithBooksTableFilterComposer
    extends Composer<_$AppDatabase, $HadithBooksTable> {
  $$HadithBooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> hadithsRefs(
    Expression<bool> Function($$HadithsTableFilterComposer f) f,
  ) {
    final $$HadithsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.hadiths,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HadithsTableFilterComposer(
            $db: $db,
            $table: $db.hadiths,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HadithBooksTableOrderingComposer
    extends Composer<_$AppDatabase, $HadithBooksTable> {
  $$HadithBooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HadithBooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $HadithBooksTable> {
  $$HadithBooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  Expression<T> hadithsRefs<T extends Object>(
    Expression<T> Function($$HadithsTableAnnotationComposer a) f,
  ) {
    final $$HadithsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.hadiths,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HadithsTableAnnotationComposer(
            $db: $db,
            $table: $db.hadiths,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HadithBooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HadithBooksTable,
          HadithBookData,
          $$HadithBooksTableFilterComposer,
          $$HadithBooksTableOrderingComposer,
          $$HadithBooksTableAnnotationComposer,
          $$HadithBooksTableCreateCompanionBuilder,
          $$HadithBooksTableUpdateCompanionBuilder,
          (HadithBookData, $$HadithBooksTableReferences),
          HadithBookData,
          PrefetchHooks Function({bool hadithsRefs})
        > {
  $$HadithBooksTableTableManager(_$AppDatabase db, $HadithBooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HadithBooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HadithBooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HadithBooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String> description = const Value.absent(),
              }) => HadithBooksCompanion(
                id: id,
                title: title,
                author: author,
                description: description,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String> author = const Value.absent(),
                Value<String> description = const Value.absent(),
              }) => HadithBooksCompanion.insert(
                id: id,
                title: title,
                author: author,
                description: description,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HadithBooksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({hadithsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (hadithsRefs) db.hadiths],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (hadithsRefs)
                    await $_getPrefetchedData<
                      HadithBookData,
                      $HadithBooksTable,
                      HadithData
                    >(
                      currentTable: table,
                      referencedTable: $$HadithBooksTableReferences
                          ._hadithsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$HadithBooksTableReferences(
                            db,
                            table,
                            p0,
                          ).hadithsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.bookId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$HadithBooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HadithBooksTable,
      HadithBookData,
      $$HadithBooksTableFilterComposer,
      $$HadithBooksTableOrderingComposer,
      $$HadithBooksTableAnnotationComposer,
      $$HadithBooksTableCreateCompanionBuilder,
      $$HadithBooksTableUpdateCompanionBuilder,
      (HadithBookData, $$HadithBooksTableReferences),
      HadithBookData,
      PrefetchHooks Function({bool hadithsRefs})
    >;
typedef $$HadithCategoriesTableCreateCompanionBuilder =
    HadithCategoriesCompanion Function({Value<int> id, required String title});
typedef $$HadithCategoriesTableUpdateCompanionBuilder =
    HadithCategoriesCompanion Function({Value<int> id, Value<String> title});

final class $$HadithCategoriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $HadithCategoriesTable,
          HadithCategoryData
        > {
  $$HadithCategoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$HadithsTable, List<HadithData>> _hadithsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.hadiths,
    aliasName: $_aliasNameGenerator(
      db.hadithCategories.id,
      db.hadiths.categoryId,
    ),
  );

  $$HadithsTableProcessedTableManager get hadithsRefs {
    final manager = $$HadithsTableTableManager(
      $_db,
      $_db.hadiths,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_hadithsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HadithCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $HadithCategoriesTable> {
  $$HadithCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> hadithsRefs(
    Expression<bool> Function($$HadithsTableFilterComposer f) f,
  ) {
    final $$HadithsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.hadiths,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HadithsTableFilterComposer(
            $db: $db,
            $table: $db.hadiths,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HadithCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $HadithCategoriesTable> {
  $$HadithCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HadithCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HadithCategoriesTable> {
  $$HadithCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  Expression<T> hadithsRefs<T extends Object>(
    Expression<T> Function($$HadithsTableAnnotationComposer a) f,
  ) {
    final $$HadithsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.hadiths,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HadithsTableAnnotationComposer(
            $db: $db,
            $table: $db.hadiths,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HadithCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HadithCategoriesTable,
          HadithCategoryData,
          $$HadithCategoriesTableFilterComposer,
          $$HadithCategoriesTableOrderingComposer,
          $$HadithCategoriesTableAnnotationComposer,
          $$HadithCategoriesTableCreateCompanionBuilder,
          $$HadithCategoriesTableUpdateCompanionBuilder,
          (HadithCategoryData, $$HadithCategoriesTableReferences),
          HadithCategoryData,
          PrefetchHooks Function({bool hadithsRefs})
        > {
  $$HadithCategoriesTableTableManager(
    _$AppDatabase db,
    $HadithCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HadithCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HadithCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HadithCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
              }) => HadithCategoriesCompanion(id: id, title: title),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String title}) =>
                  HadithCategoriesCompanion.insert(id: id, title: title),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HadithCategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({hadithsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (hadithsRefs) db.hadiths],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (hadithsRefs)
                    await $_getPrefetchedData<
                      HadithCategoryData,
                      $HadithCategoriesTable,
                      HadithData
                    >(
                      currentTable: table,
                      referencedTable: $$HadithCategoriesTableReferences
                          ._hadithsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$HadithCategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).hadithsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$HadithCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HadithCategoriesTable,
      HadithCategoryData,
      $$HadithCategoriesTableFilterComposer,
      $$HadithCategoriesTableOrderingComposer,
      $$HadithCategoriesTableAnnotationComposer,
      $$HadithCategoriesTableCreateCompanionBuilder,
      $$HadithCategoriesTableUpdateCompanionBuilder,
      (HadithCategoryData, $$HadithCategoriesTableReferences),
      HadithCategoryData,
      PrefetchHooks Function({bool hadithsRefs})
    >;
typedef $$HadithsTableCreateCompanionBuilder =
    HadithsCompanion Function({
      Value<int> id,
      required int bookId,
      required int categoryId,
      Value<String> narrator,
      required String textContent,
      Value<String> source,
      Value<String> explanation,
      Value<String> vocabularyJson,
      Value<String> lifeApplicationsJson,
    });
typedef $$HadithsTableUpdateCompanionBuilder =
    HadithsCompanion Function({
      Value<int> id,
      Value<int> bookId,
      Value<int> categoryId,
      Value<String> narrator,
      Value<String> textContent,
      Value<String> source,
      Value<String> explanation,
      Value<String> vocabularyJson,
      Value<String> lifeApplicationsJson,
    });

final class $$HadithsTableReferences
    extends BaseReferences<_$AppDatabase, $HadithsTable, HadithData> {
  $$HadithsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HadithBooksTable _bookIdTable(_$AppDatabase db) => db.hadithBooks
      .createAlias($_aliasNameGenerator(db.hadiths.bookId, db.hadithBooks.id));

  $$HadithBooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$HadithBooksTableTableManager(
      $_db,
      $_db.hadithBooks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $HadithCategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.hadithCategories.createAlias(
        $_aliasNameGenerator(db.hadiths.categoryId, db.hadithCategories.id),
      );

  $$HadithCategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$HadithCategoriesTableTableManager(
      $_db,
      $_db.hadithCategories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HadithsTableFilterComposer
    extends Composer<_$AppDatabase, $HadithsTable> {
  $$HadithsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get narrator => $composableBuilder(
    column: $table.narrator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vocabularyJson => $composableBuilder(
    column: $table.vocabularyJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lifeApplicationsJson => $composableBuilder(
    column: $table.lifeApplicationsJson,
    builder: (column) => ColumnFilters(column),
  );

  $$HadithBooksTableFilterComposer get bookId {
    final $$HadithBooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.hadithBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HadithBooksTableFilterComposer(
            $db: $db,
            $table: $db.hadithBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HadithCategoriesTableFilterComposer get categoryId {
    final $$HadithCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.hadithCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HadithCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.hadithCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HadithsTableOrderingComposer
    extends Composer<_$AppDatabase, $HadithsTable> {
  $$HadithsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get narrator => $composableBuilder(
    column: $table.narrator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vocabularyJson => $composableBuilder(
    column: $table.vocabularyJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lifeApplicationsJson => $composableBuilder(
    column: $table.lifeApplicationsJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$HadithBooksTableOrderingComposer get bookId {
    final $$HadithBooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.hadithBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HadithBooksTableOrderingComposer(
            $db: $db,
            $table: $db.hadithBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HadithCategoriesTableOrderingComposer get categoryId {
    final $$HadithCategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.hadithCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HadithCategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.hadithCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HadithsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HadithsTable> {
  $$HadithsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get narrator =>
      $composableBuilder(column: $table.narrator, builder: (column) => column);

  GeneratedColumn<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vocabularyJson => $composableBuilder(
    column: $table.vocabularyJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lifeApplicationsJson => $composableBuilder(
    column: $table.lifeApplicationsJson,
    builder: (column) => column,
  );

  $$HadithBooksTableAnnotationComposer get bookId {
    final $$HadithBooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.hadithBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HadithBooksTableAnnotationComposer(
            $db: $db,
            $table: $db.hadithBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HadithCategoriesTableAnnotationComposer get categoryId {
    final $$HadithCategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.hadithCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HadithCategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.hadithCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HadithsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HadithsTable,
          HadithData,
          $$HadithsTableFilterComposer,
          $$HadithsTableOrderingComposer,
          $$HadithsTableAnnotationComposer,
          $$HadithsTableCreateCompanionBuilder,
          $$HadithsTableUpdateCompanionBuilder,
          (HadithData, $$HadithsTableReferences),
          HadithData,
          PrefetchHooks Function({bool bookId, bool categoryId})
        > {
  $$HadithsTableTableManager(_$AppDatabase db, $HadithsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HadithsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HadithsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HadithsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bookId = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<String> narrator = const Value.absent(),
                Value<String> textContent = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> explanation = const Value.absent(),
                Value<String> vocabularyJson = const Value.absent(),
                Value<String> lifeApplicationsJson = const Value.absent(),
              }) => HadithsCompanion(
                id: id,
                bookId: bookId,
                categoryId: categoryId,
                narrator: narrator,
                textContent: textContent,
                source: source,
                explanation: explanation,
                vocabularyJson: vocabularyJson,
                lifeApplicationsJson: lifeApplicationsJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bookId,
                required int categoryId,
                Value<String> narrator = const Value.absent(),
                required String textContent,
                Value<String> source = const Value.absent(),
                Value<String> explanation = const Value.absent(),
                Value<String> vocabularyJson = const Value.absent(),
                Value<String> lifeApplicationsJson = const Value.absent(),
              }) => HadithsCompanion.insert(
                id: id,
                bookId: bookId,
                categoryId: categoryId,
                narrator: narrator,
                textContent: textContent,
                source: source,
                explanation: explanation,
                vocabularyJson: vocabularyJson,
                lifeApplicationsJson: lifeApplicationsJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HadithsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false, categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.bookId,
                                referencedTable: $$HadithsTableReferences
                                    ._bookIdTable(db),
                                referencedColumn: $$HadithsTableReferences
                                    ._bookIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable: $$HadithsTableReferences
                                    ._categoryIdTable(db),
                                referencedColumn: $$HadithsTableReferences
                                    ._categoryIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HadithsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HadithsTable,
      HadithData,
      $$HadithsTableFilterComposer,
      $$HadithsTableOrderingComposer,
      $$HadithsTableAnnotationComposer,
      $$HadithsTableCreateCompanionBuilder,
      $$HadithsTableUpdateCompanionBuilder,
      (HadithData, $$HadithsTableReferences),
      HadithData,
      PrefetchHooks Function({bool bookId, bool categoryId})
    >;
typedef $$ReligiousTasksTableCreateCompanionBuilder =
    ReligiousTasksCompanion Function({
      Value<int> id,
      required String title,
      Value<String> type,
      Value<String> frequency,
      Value<DateTime> createdAt,
    });
typedef $$ReligiousTasksTableUpdateCompanionBuilder =
    ReligiousTasksCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> type,
      Value<String> frequency,
      Value<DateTime> createdAt,
    });

final class $$ReligiousTasksTableReferences
    extends
        BaseReferences<_$AppDatabase, $ReligiousTasksTable, ReligiousTaskData> {
  $$ReligiousTasksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$TaskCompletionsTable, List<TaskCompletionData>>
  _taskCompletionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.taskCompletions,
    aliasName: $_aliasNameGenerator(
      db.religiousTasks.id,
      db.taskCompletions.taskId,
    ),
  );

  $$TaskCompletionsTableProcessedTableManager get taskCompletionsRefs {
    final manager = $$TaskCompletionsTableTableManager(
      $_db,
      $_db.taskCompletions,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _taskCompletionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ReligiousTasksTableFilterComposer
    extends Composer<_$AppDatabase, $ReligiousTasksTable> {
  $$ReligiousTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> taskCompletionsRefs(
    Expression<bool> Function($$TaskCompletionsTableFilterComposer f) f,
  ) {
    final $$TaskCompletionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskCompletions,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskCompletionsTableFilterComposer(
            $db: $db,
            $table: $db.taskCompletions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ReligiousTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $ReligiousTasksTable> {
  $$ReligiousTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReligiousTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReligiousTasksTable> {
  $$ReligiousTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> taskCompletionsRefs<T extends Object>(
    Expression<T> Function($$TaskCompletionsTableAnnotationComposer a) f,
  ) {
    final $$TaskCompletionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskCompletions,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskCompletionsTableAnnotationComposer(
            $db: $db,
            $table: $db.taskCompletions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ReligiousTasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReligiousTasksTable,
          ReligiousTaskData,
          $$ReligiousTasksTableFilterComposer,
          $$ReligiousTasksTableOrderingComposer,
          $$ReligiousTasksTableAnnotationComposer,
          $$ReligiousTasksTableCreateCompanionBuilder,
          $$ReligiousTasksTableUpdateCompanionBuilder,
          (ReligiousTaskData, $$ReligiousTasksTableReferences),
          ReligiousTaskData,
          PrefetchHooks Function({bool taskCompletionsRefs})
        > {
  $$ReligiousTasksTableTableManager(
    _$AppDatabase db,
    $ReligiousTasksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReligiousTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReligiousTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReligiousTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> frequency = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ReligiousTasksCompanion(
                id: id,
                title: title,
                type: type,
                frequency: frequency,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String> type = const Value.absent(),
                Value<String> frequency = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ReligiousTasksCompanion.insert(
                id: id,
                title: title,
                type: type,
                frequency: frequency,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReligiousTasksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({taskCompletionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (taskCompletionsRefs) db.taskCompletions,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (taskCompletionsRefs)
                    await $_getPrefetchedData<
                      ReligiousTaskData,
                      $ReligiousTasksTable,
                      TaskCompletionData
                    >(
                      currentTable: table,
                      referencedTable: $$ReligiousTasksTableReferences
                          ._taskCompletionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ReligiousTasksTableReferences(
                            db,
                            table,
                            p0,
                          ).taskCompletionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.taskId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ReligiousTasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReligiousTasksTable,
      ReligiousTaskData,
      $$ReligiousTasksTableFilterComposer,
      $$ReligiousTasksTableOrderingComposer,
      $$ReligiousTasksTableAnnotationComposer,
      $$ReligiousTasksTableCreateCompanionBuilder,
      $$ReligiousTasksTableUpdateCompanionBuilder,
      (ReligiousTaskData, $$ReligiousTasksTableReferences),
      ReligiousTaskData,
      PrefetchHooks Function({bool taskCompletionsRefs})
    >;
typedef $$TaskCompletionsTableCreateCompanionBuilder =
    TaskCompletionsCompanion Function({
      Value<int> id,
      required int taskId,
      required String date,
      Value<bool> completed,
    });
typedef $$TaskCompletionsTableUpdateCompanionBuilder =
    TaskCompletionsCompanion Function({
      Value<int> id,
      Value<int> taskId,
      Value<String> date,
      Value<bool> completed,
    });

final class $$TaskCompletionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TaskCompletionsTable,
          TaskCompletionData
        > {
  $$TaskCompletionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ReligiousTasksTable _taskIdTable(_$AppDatabase db) =>
      db.religiousTasks.createAlias(
        $_aliasNameGenerator(db.taskCompletions.taskId, db.religiousTasks.id),
      );

  $$ReligiousTasksTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<int>('task_id')!;

    final manager = $$ReligiousTasksTableTableManager(
      $_db,
      $_db.religiousTasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TaskCompletionsTableFilterComposer
    extends Composer<_$AppDatabase, $TaskCompletionsTable> {
  $$TaskCompletionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  $$ReligiousTasksTableFilterComposer get taskId {
    final $$ReligiousTasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.religiousTasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReligiousTasksTableFilterComposer(
            $db: $db,
            $table: $db.religiousTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskCompletionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskCompletionsTable> {
  $$TaskCompletionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  $$ReligiousTasksTableOrderingComposer get taskId {
    final $$ReligiousTasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.religiousTasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReligiousTasksTableOrderingComposer(
            $db: $db,
            $table: $db.religiousTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskCompletionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskCompletionsTable> {
  $$TaskCompletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  $$ReligiousTasksTableAnnotationComposer get taskId {
    final $$ReligiousTasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.religiousTasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReligiousTasksTableAnnotationComposer(
            $db: $db,
            $table: $db.religiousTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskCompletionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskCompletionsTable,
          TaskCompletionData,
          $$TaskCompletionsTableFilterComposer,
          $$TaskCompletionsTableOrderingComposer,
          $$TaskCompletionsTableAnnotationComposer,
          $$TaskCompletionsTableCreateCompanionBuilder,
          $$TaskCompletionsTableUpdateCompanionBuilder,
          (TaskCompletionData, $$TaskCompletionsTableReferences),
          TaskCompletionData,
          PrefetchHooks Function({bool taskId})
        > {
  $$TaskCompletionsTableTableManager(
    _$AppDatabase db,
    $TaskCompletionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskCompletionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskCompletionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskCompletionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> taskId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<bool> completed = const Value.absent(),
              }) => TaskCompletionsCompanion(
                id: id,
                taskId: taskId,
                date: date,
                completed: completed,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int taskId,
                required String date,
                Value<bool> completed = const Value.absent(),
              }) => TaskCompletionsCompanion.insert(
                id: id,
                taskId: taskId,
                date: date,
                completed: completed,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TaskCompletionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (taskId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.taskId,
                                referencedTable:
                                    $$TaskCompletionsTableReferences
                                        ._taskIdTable(db),
                                referencedColumn:
                                    $$TaskCompletionsTableReferences
                                        ._taskIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TaskCompletionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskCompletionsTable,
      TaskCompletionData,
      $$TaskCompletionsTableFilterComposer,
      $$TaskCompletionsTableOrderingComposer,
      $$TaskCompletionsTableAnnotationComposer,
      $$TaskCompletionsTableCreateCompanionBuilder,
      $$TaskCompletionsTableUpdateCompanionBuilder,
      (TaskCompletionData, $$TaskCompletionsTableReferences),
      TaskCompletionData,
      PrefetchHooks Function({bool taskId})
    >;
typedef $$UserStatsTableCreateCompanionBuilder =
    UserStatsCompanion Function({
      Value<int> id,
      required String date,
      Value<int> quranPagesRead,
      Value<int> tasbihCount,
      Value<int> adhkarCompleted,
    });
typedef $$UserStatsTableUpdateCompanionBuilder =
    UserStatsCompanion Function({
      Value<int> id,
      Value<String> date,
      Value<int> quranPagesRead,
      Value<int> tasbihCount,
      Value<int> adhkarCompleted,
    });

class $$UserStatsTableFilterComposer
    extends Composer<_$AppDatabase, $UserStatsTable> {
  $$UserStatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quranPagesRead => $composableBuilder(
    column: $table.quranPagesRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tasbihCount => $composableBuilder(
    column: $table.tasbihCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get adhkarCompleted => $composableBuilder(
    column: $table.adhkarCompleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserStatsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserStatsTable> {
  $$UserStatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quranPagesRead => $composableBuilder(
    column: $table.quranPagesRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tasbihCount => $composableBuilder(
    column: $table.tasbihCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get adhkarCompleted => $composableBuilder(
    column: $table.adhkarCompleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserStatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserStatsTable> {
  $$UserStatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get quranPagesRead => $composableBuilder(
    column: $table.quranPagesRead,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tasbihCount => $composableBuilder(
    column: $table.tasbihCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get adhkarCompleted => $composableBuilder(
    column: $table.adhkarCompleted,
    builder: (column) => column,
  );
}

class $$UserStatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserStatsTable,
          UserStatData,
          $$UserStatsTableFilterComposer,
          $$UserStatsTableOrderingComposer,
          $$UserStatsTableAnnotationComposer,
          $$UserStatsTableCreateCompanionBuilder,
          $$UserStatsTableUpdateCompanionBuilder,
          (
            UserStatData,
            BaseReferences<_$AppDatabase, $UserStatsTable, UserStatData>,
          ),
          UserStatData,
          PrefetchHooks Function()
        > {
  $$UserStatsTableTableManager(_$AppDatabase db, $UserStatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserStatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserStatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserStatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<int> quranPagesRead = const Value.absent(),
                Value<int> tasbihCount = const Value.absent(),
                Value<int> adhkarCompleted = const Value.absent(),
              }) => UserStatsCompanion(
                id: id,
                date: date,
                quranPagesRead: quranPagesRead,
                tasbihCount: tasbihCount,
                adhkarCompleted: adhkarCompleted,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String date,
                Value<int> quranPagesRead = const Value.absent(),
                Value<int> tasbihCount = const Value.absent(),
                Value<int> adhkarCompleted = const Value.absent(),
              }) => UserStatsCompanion.insert(
                id: id,
                date: date,
                quranPagesRead: quranPagesRead,
                tasbihCount: tasbihCount,
                adhkarCompleted: adhkarCompleted,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserStatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserStatsTable,
      UserStatData,
      $$UserStatsTableFilterComposer,
      $$UserStatsTableOrderingComposer,
      $$UserStatsTableAnnotationComposer,
      $$UserStatsTableCreateCompanionBuilder,
      $$UserStatsTableUpdateCompanionBuilder,
      (
        UserStatData,
        BaseReferences<_$AppDatabase, $UserStatsTable, UserStatData>,
      ),
      UserStatData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SurahsTableTableManager get surahs =>
      $$SurahsTableTableManager(_db, _db.surahs);
  $$AyahsTableTableManager get ayahs =>
      $$AyahsTableTableManager(_db, _db.ayahs);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db, _db.bookmarks);
  $$ProgressTableTableManager get progress =>
      $$ProgressTableTableManager(_db, _db.progress);
  $$FavoritesTableTableManager get favorites =>
      $$FavoritesTableTableManager(_db, _db.favorites);
  $$AdhkarCategoriesTableTableManager get adhkarCategories =>
      $$AdhkarCategoriesTableTableManager(_db, _db.adhkarCategories);
  $$AdhkarItemsTableTableManager get adhkarItems =>
      $$AdhkarItemsTableTableManager(_db, _db.adhkarItems);
  $$AdhkarProgressesTableTableManager get adhkarProgresses =>
      $$AdhkarProgressesTableTableManager(_db, _db.adhkarProgresses);
  $$TasbihsTableTableManager get tasbihs =>
      $$TasbihsTableTableManager(_db, _db.tasbihs);
  $$HadithBooksTableTableManager get hadithBooks =>
      $$HadithBooksTableTableManager(_db, _db.hadithBooks);
  $$HadithCategoriesTableTableManager get hadithCategories =>
      $$HadithCategoriesTableTableManager(_db, _db.hadithCategories);
  $$HadithsTableTableManager get hadiths =>
      $$HadithsTableTableManager(_db, _db.hadiths);
  $$ReligiousTasksTableTableManager get religiousTasks =>
      $$ReligiousTasksTableTableManager(_db, _db.religiousTasks);
  $$TaskCompletionsTableTableManager get taskCompletions =>
      $$TaskCompletionsTableTableManager(_db, _db.taskCompletions);
  $$UserStatsTableTableManager get userStats =>
      $$UserStatsTableTableManager(_db, _db.userStats);
}
