import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:iman/src/core/database/shared_preferences_provider.dart';
import '../../domain/entities/quran_entities.dart';

class Reciter {
  final String id;
  final String nameEnglish;
  final String nameArabic;
  final String server;
  final String? surahServer;

  const Reciter({
    required this.id,
    required this.nameEnglish,
    required this.nameArabic,
    required this.server,
    this.surahServer,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nameEnglish': nameEnglish,
    'nameArabic': nameArabic,
    'server': server,
    'surahServer': surahServer,
  };

  factory Reciter.fromJson(Map<String, dynamic> json) => Reciter(
    id: json['id'] as String,
    nameEnglish: json['nameEnglish'] as String,
    nameArabic: json['nameArabic'] as String,
    server: json['server'] as String,
    surahServer: json['surahServer'] as String?,
  );
}

const List<Reciter> staticReciters = [
  Reciter(
    id: 'yasser_al_dossari',
    nameEnglish: 'Yasser Al-Dossari',
    nameArabic: 'ياسر الدوسري',
    server: 'https://everyayah.com/data/Yasser_Ad-Dussary_128kbps/',
    surahServer: 'https://server11.mp3quran.net/yasser/',
  ),
  Reciter(
    id: 'maher_al_muaiqly',
    nameEnglish: 'Maher Al-Muaiqly',
    nameArabic: 'ماهر المعيقلي',
    server: 'https://everyayah.com/data/MaherAlMuaiqly128kbps/',
    surahServer: 'https://server12.mp3quran.net/maher/',
  ),
  Reciter(
    id: 'mishary_alfasy',
    nameEnglish: 'Mishary Alafasy',
    nameArabic: 'مشاري العفاسي',
    server: 'https://everyayah.com/data/Alafasy_128kbps/',
    surahServer: 'https://server8.mp3quran.net/afs/',
  ),
  Reciter(
    id: 'mahmoud_al_husary',
    nameEnglish: 'Mahmoud Khalil Al-Husary (Murattal)',
    nameArabic: 'محمود خليل الحصري (مرتل)',
    server: 'https://everyayah.com/data/Husary_128kbps/',
    surahServer: 'https://server13.mp3quran.net/husr/',
  ),
  Reciter(
    id: 'al_minshawi',
    nameEnglish: 'Al-Minshawi',
    nameArabic: 'محمد صديق المنشاوي',
    server: 'https://everyayah.com/data/Minshawy_Murattal_128kbps/',
    surahServer: 'https://server11.mp3quran.net/minsh/',
  ),
  Reciter(
    id: 'abdul_basit',
    nameEnglish: 'Abdul Basit',
    nameArabic: 'عبد الباسط عبد الصمد',
    server: 'https://everyayah.com/data/Abdul_Basit_Murattal_192kbps/',
    surahServer: 'https://server7.mp3quran.net/basit/',
  ),
];

const List<Reciter> allEveryAyahReciters = [
  Reciter(
    id: 'abdul_basit',
    nameEnglish: 'Abdul Basit (Murattal)',
    nameArabic: 'عبد الباسط عبد الصمد (مرتل)',
    server: 'https://everyayah.com/data/Abdul_Basit_Murattal_192kbps/',
    surahServer: 'https://server7.mp3quran.net/basit/',
  ),
  Reciter(
    id: 'abdul_basit_mujawwad',
    nameEnglish: 'Abdul Basit (Mujawwad)',
    nameArabic: 'عبد الباسط عبد الصمد (مجود)',
    server: 'https://everyayah.com/data/Abdul_Basit_Mujawwad_128kbps/',
    surahServer: 'https://server7.mp3quran.net/basit_mjwd/',
  ),
  Reciter(
    id: 'yasser_al_dossari',
    nameEnglish: 'Yasser Al-Dossari',
    nameArabic: 'ياسر الدوسري',
    server: 'https://everyayah.com/data/Yasser_Ad-Dussary_128kbps/',
    surahServer: 'https://server11.mp3quran.net/yasser/',
  ),
  Reciter(
    id: 'al_minshawi',
    nameEnglish: 'Al-Minshawi (Murattal)',
    nameArabic: 'محمد صديق المنشاوي (مرتل)',
    server: 'https://everyayah.com/data/Minshawy_Murattal_128kbps/',
    surahServer: 'https://server11.mp3quran.net/minsh/',
  ),
  Reciter(
    id: 'mishary_alfasy',
    nameEnglish: 'Mishary Alafasy',
    nameArabic: 'مشاري العفاسي',
    server: 'https://everyayah.com/data/Alafasy_128kbps/',
    surahServer: 'https://server8.mp3quran.net/afs/',
  ),
  Reciter(
    id: 'saad_al_ghamdi',
    nameEnglish: 'Saad Al-Ghamdi',
    nameArabic: 'سعد الغامدي',
    server: 'https://everyayah.com/data/Ghamadi_40kbps/',
    surahServer: 'https://server7.mp3quran.net/s_gmd/',
  ),
  Reciter(
    id: 'maher_al_muaiqly',
    nameEnglish: 'Maher Al-Muaiqly',
    nameArabic: 'ماهر المعيقلي',
    server: 'https://everyayah.com/data/MaherAlMuaiqly128kbps/',
    surahServer: 'https://server12.mp3quran.net/maher/',
  ),
  Reciter(
    id: 'abdurrahman_al_sudais',
    nameEnglish: 'Abdul Rahman Al-Sudais',
    nameArabic: 'عبد الرحمن السديس',
    server: 'https://everyayah.com/data/Abdurrahmaan_As-Sudais_192kbps/',
    surahServer: 'https://server11.mp3quran.net/sds/',
  ),
  Reciter(
    id: 'saud_al_shuraim',
    nameEnglish: 'Saud Al-Shuraim',
    nameArabic: 'سعود الشريم',
    server: 'https://everyayah.com/data/Saood_ash-Shuraym_128kbps/',
    surahServer: 'https://server7.mp3quran.net/shrm/',
  ),
  Reciter(
    id: 'mahmoud_al_husary',
    nameEnglish: 'Mahmoud Khalil Al-Husary (Murattal)',
    nameArabic: 'محمود خليل الحصري (مرتل)',
    server: 'https://everyayah.com/data/Husary_128kbps/',
    surahServer: 'https://server13.mp3quran.net/husr/',
  ),
  Reciter(
    id: 'nasser_al_qatami',
    nameEnglish: 'Nasser Al-Qatami',
    nameArabic: 'ناصر القطامي',
    server: 'https://everyayah.com/data/Nasser_Alqatami_128kbps/',
    surahServer: 'https://server11.mp3quran.net/qtm/',
  ),
  Reciter(
    id: 'fares_abbad',
    nameEnglish: 'Fares Abbad',
    nameArabic: 'فارس عباد',
    server: 'https://everyayah.com/data/Fares_Abbad_64kbps/',
    surahServer: 'https://server8.mp3quran.net/frs_a/',
  ),
  Reciter(
    id: 'abdullah_basfar',
    nameEnglish: 'Abdullah Basfar',
    nameArabic: 'عبد الله بصفر',
    server: 'https://everyayah.com/data/Abdullah_Basfar_192kbps/',
    surahServer: 'https://server6.mp3quran.net/bsfr/',
  ),
  Reciter(
    id: 'muhammad_ayyoub',
    nameEnglish: 'Muhammad Ayyoub',
    nameArabic: 'محمد أيوب',
    server: 'https://everyayah.com/data/Muhammad_Ayyoub_128kbps/',
    surahServer: 'https://server8.mp3quran.net/ayoub/',
  ),
  Reciter(
    id: 'muhammad_jibreel',
    nameEnglish: 'Muhammad Jibreel',
    nameArabic: 'محمد جبريل',
    server: 'https://everyayah.com/data/Muhammad_Jibreel_128kbps/',
    surahServer: 'https://server8.mp3quran.net/jbrl/',
  ),
  Reciter(
    id: 'salah_al_budair',
    nameEnglish: 'Salah Al-Budair',
    nameArabic: 'صلاح البدير',
    server: 'https://everyayah.com/data/Salah_Al_Budair_128kbps/',
    surahServer: 'https://server11.mp3quran.net/budair/',
  ),
  Reciter(
    id: 'ahmed_al_hawashi',
    nameEnglish: 'Ahmed Al-Hawashi',
    nameArabic: 'أحمد الحواشي',
    server: 'https://everyayah.com/data/Ahmed_Neana_128kbps/',
    surahServer: 'https://server11.mp3quran.net/hawash/',
  ),
  Reciter(
    id: 'sahl_yassin',
    nameEnglish: 'Sahl Yassin',
    nameArabic: 'سهل ياسين',
    server: 'https://everyayah.com/data/Sahl_Yassin_128kbps/',
    surahServer: 'https://server6.mp3quran.net/sahil/',
  ),
];

final recentRecitersProvider = NotifierProvider<RecentRecitersNotifier, List<Reciter>>(() {
  return RecentRecitersNotifier();
});

class RecentRecitersNotifier extends Notifier<List<Reciter>> {
  @override
  List<Reciter> build() {
    return _loadRecentReciters();
  }

  List<Reciter> _loadRecentReciters() {
    final prefs = ref.read(sharedPreferencesProvider);
    final list = prefs.getStringList('recent_quran_reciters');
    if (list == null || list.isEmpty) {
      return List.from(staticReciters);
    } else {
      try {
        return list.map((item) => Reciter.fromJson(jsonDecode(item))).toList();
      } catch (e) {
        return List.from(staticReciters);
      }
    }
  }

  void addReciter(Reciter reciter) {
    final prefs = ref.read(sharedPreferencesProvider);
    final newList = state.where((r) => r.id != reciter.id).toList();
    newList.insert(0, reciter);
    if (newList.length > 6) {
      newList.removeRange(6, newList.length);
    }
    state = newList;
    final stringList = newList.map((r) => jsonEncode(r.toJson())).toList();
    prefs.setStringList('recent_quran_reciters', stringList);
  }
}

const List<String> surahNamesArabic = [
  "الفاتحة", "البقرة", "آل عمران", "النساء", "المائدة", "الأنعام", "الأعراف", "الأنفال", "التوبة", "يونس",
  "هود", "يوسف", "الرعد", "إبراهيم", "الحجر", "النحل", "الإسراء", "الكهف", "مريم", "طه",
  "الأنبياء", "الحج", "المؤمنون", "النور", "الفرقان", "الشعراء", "النمل", "القصص", "العنكبوت", "الروم",
  "لقمان", "السجدة", "الأحزاب", "سبأ", "فاطر", "يس", "الصافات", "ص", "الزمر", "غافر",
  "فصلت", "الشورى", "الزخرف", "الدخان", "الجاثية", "الأحقاف", "محمد", "الفتح", "الحجرات", "ق",
  "الذاريات", "الطور", "النجم", "القمر", "الرحمن", "الواقعة", "الحديد", "المجادلة", "الحشر", "الممتحنة",
  "الصف", "الجمعة", "المنافقون", "التغابن", "الطلاق", "التحريم", "الملك", "القلم", "الحاقة", "المعارج",
  "نوح", "الجن", "المزمل", "المدثر", "القيامة", "الإنسان", "المرسلات", "النبأ", "النازعات", "عبس",
  "التكوير", "الانفطار", "المطففين", "الانشقاق", "البروج", "الطارق", "الأعلى", "الغاشية", "الفجر", "البلد",
  "الشمس", "الليل", "الضحى", "الشرح", "التين", "العلق", "القدر", "البينة", "الزلزلة", "العاديات",
  "القارعة", "التكاثر", "العصر", "الهمزة", "الفيل", "قريش", "الماعون", "الكوثر", "الكافرون", "النصر",
  "المسد", "الإخلاص", "الفلق", "الناس"
];

class AudioPlaybackState {
  final bool isPlaying;
  final int currentSurah;
  final int currentAyahIndex; // Index in the active page list
  final Duration position;
  final Duration duration;
  final String activeReciterId;
  final bool isPageMode;
  final List<QcfVerse> pageVerses;
  final double playbackSpeed;
  final bool isSingleAyahPlay;
  final bool isLoading;
  final String? customTitle;
  final String? customSubtitle;
  final bool isLiveStream;
  final bool isRepeatOne;
  final Duration? sleepTimeRemaining;

  AudioPlaybackState({
    required this.isPlaying,
    required this.currentSurah,
    required this.currentAyahIndex,
    required this.position,
    required this.duration,
    required this.activeReciterId,
    required this.isPageMode,
    required this.pageVerses,
    required this.playbackSpeed,
    required this.isSingleAyahPlay,
    required this.isLoading,
    this.customTitle,
    this.customSubtitle,
    this.isLiveStream = false,
    this.isRepeatOne = false,
    this.sleepTimeRemaining,
  });

  AudioPlaybackState copyWith({
    bool? isPlaying,
    int? currentSurah,
    int? currentAyahIndex,
    Duration? position,
    Duration? duration,
    String? activeReciterId,
    bool? isPageMode,
    List<QcfVerse>? pageVerses,
    double? playbackSpeed,
    bool? isSingleAyahPlay,
    bool? isLoading,
    String? customTitle,
    String? customSubtitle,
    bool? isLiveStream,
    bool? isRepeatOne,
    bool clearSleepTimer = false,
    Duration? sleepTimeRemaining,
  }) {
    return AudioPlaybackState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentSurah: currentSurah ?? this.currentSurah,
      currentAyahIndex: currentAyahIndex ?? this.currentAyahIndex,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      activeReciterId: activeReciterId ?? this.activeReciterId,
      isPageMode: isPageMode ?? this.isPageMode,
      pageVerses: pageVerses ?? this.pageVerses,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      isSingleAyahPlay: isSingleAyahPlay ?? this.isSingleAyahPlay,
      isLoading: isLoading ?? this.isLoading,
      customTitle: customTitle ?? this.customTitle,
      customSubtitle: customSubtitle ?? this.customSubtitle,
      isLiveStream: isLiveStream ?? this.isLiveStream,
      isRepeatOne: isRepeatOne ?? this.isRepeatOne,
      sleepTimeRemaining: clearSleepTimer ? null : (sleepTimeRemaining ?? this.sleepTimeRemaining),
    );
  }
}

class AudioPlayerNotifier extends Notifier<AudioPlaybackState> {
  late final AudioPlayer _player;
  late final StreamController<void> _pageCompletedController;
  Timer? _sleepTimer;

  Stream<void> get pageCompletedStream => _pageCompletedController.stream;

  @override
  AudioPlaybackState build() {
    _player = AudioPlayer();
    _pageCompletedController = StreamController<void>.broadcast();

    _initListeners();

    ref.onDispose(() {
      _sleepTimer?.cancel();
      _player.dispose();
      _pageCompletedController.close();
    });

    // Restore last played state globally
    final prefs = ref.read(sharedPreferencesProvider);
    final lastGlobalType = prefs.getString('last_global_type') ?? 'quran';

    if (lastGlobalType == 'quran') {
      final reciterId = prefs.getString('last_quran_reciter') ?? 'yasser_al_dossari';
      final surah = prefs.getInt('last_quran_surah') ?? 1;
      return AudioPlaybackState(
        isPlaying: false,
        currentSurah: surah,
        currentAyahIndex: -1,
        position: Duration.zero,
        duration: Duration.zero,
        activeReciterId: reciterId,
        isPageMode: false,
        pageVerses: [],
        playbackSpeed: 1.0,
        isSingleAyahPlay: false,
        isLoading: false,
      );
    } else if (lastGlobalType == 'radio') {
      final name = prefs.getString('last_radio_name') ?? 'إذاعة القرآن الكريم من القاهرة';
      return AudioPlaybackState(
        isPlaying: false,
        currentSurah: -1,
        currentAyahIndex: -1,
        position: Duration.zero,
        duration: Duration.zero,
        activeReciterId: 'custom',
        isPageMode: false,
        pageVerses: [],
        playbackSpeed: 1.0,
        isSingleAyahPlay: false,
        isLoading: false,
        customTitle: name,
        customSubtitle: 'إذاعة القرآن الكريم (بث حي)',
        isLiveStream: true,
      );
    } else {
      final title = prefs.getString('last_podcast_title') ?? 'حلقة البودكاست';
      final publisher = prefs.getString('last_podcast_publisher') ?? 'بودكاست ديني';
      return AudioPlaybackState(
        isPlaying: false,
        currentSurah: -1,
        currentAyahIndex: -1,
        position: Duration.zero,
        duration: Duration.zero,
        activeReciterId: 'custom',
        isPageMode: false,
        pageVerses: [],
        playbackSpeed: 1.0,
        isSingleAyahPlay: false,
        isLoading: false,
        customTitle: title,
        customSubtitle: publisher,
        isLiveStream: false,
      );
    }
  }

  void _initListeners() {
    // 1. Listen to play/pause state
    _player.playingStream.listen((playing) {
      state = state.copyWith(isPlaying: playing);
    });

    // 2. Listen to position changes
    _player.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
    });

    // 3. Listen to duration changes
    _player.durationStream.listen((dur) {
      state = state.copyWith(duration: dur ?? Duration.zero);
    });

    // 4. Listen to playlist item transitions (Ayah transitions)
    _player.currentIndexStream.listen((index) {
      if (state.isPageMode && index != null) {
        state = state.copyWith(currentAyahIndex: index);
      }
    });

    // 5. Listen to playback states (completed)
    _player.processingStateStream.listen((processingState) {
      final isLoadingState = processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering;
      
      state = state.copyWith(isLoading: isLoadingState);

      if (processingState == ProcessingState.completed) {
        if (state.isPageMode) {
          state = AudioPlaybackState(
            isPlaying: false,
            currentSurah: 0,
            currentAyahIndex: -1,
            position: Duration.zero,
            duration: Duration.zero,
            activeReciterId: state.activeReciterId,
            isPageMode: false,
            pageVerses: [],
            playbackSpeed: state.playbackSpeed,
            isSingleAyahPlay: false,
            isLoading: false,
            isRepeatOne: state.isRepeatOne,
            sleepTimeRemaining: state.sleepTimeRemaining,
          );
          _pageCompletedController.add(null);
        } else if (state.currentSurah > 0) {
          final nextSurah = (state.currentSurah % 114) + 1;
          playSurah(state.activeReciterId, nextSurah);
        } else {
          stop();
        }
      }
    });
  }

  Reciter _getReciter(String reciterId) {
    debugPrint('AudioPlayerNotifier: _getReciter called for ID: "$reciterId"');
    // Search in recent reciters first
    try {
      final reciters = ref.read(recentRecitersProvider);
      debugPrint('AudioPlayerNotifier: recent reciters IDs: ${reciters.map((r) => r.id).toList()}');
      final match = reciters.firstWhere((r) => r.id == reciterId);
      debugPrint('AudioPlayerNotifier: match found in recent reciters: "${match.nameArabic}" with ID: "${match.id}"');
      return match;
    } catch (e) {
      debugPrint('AudioPlayerNotifier: failed to find match in recent: $e');
    }

    // Fallback to static reciters
    final fallback = staticReciters.firstWhere(
      (r) => r.id == reciterId,
      orElse: () => staticReciters.first,
    );
    debugPrint('AudioPlayerNotifier: fallback resolved: "${fallback.nameArabic}" with ID: "${fallback.id}"');
    return fallback;
  }

  String _getAyahAudioUrl(Reciter reciter, int surah, int ayah) {
    final sStr = surah.toString().padLeft(3, '0');
    final aStr = ayah.toString().padLeft(3, '0');
    return '${reciter.server}$sStr$aStr.mp3';
  }

  String _getSurahAudioUrl(Reciter reciter, int surah) {
    final sStr = surah.toString().padLeft(3, '0');
    final baseUrl = reciter.surahServer ?? reciter.server;
    return '$baseUrl$sStr.mp3';
  }

  Future<void> playSurah(String reciterId, int surahNumber, {bool play = true}) async {
    try {
      final reciter = _getReciter(reciterId);
      final url = _getSurahAudioUrl(reciter, surahNumber);
      final surahName = surahNamesArabic[surahNumber - 1];

      await _player.stop();

      state = AudioPlaybackState(
        isPlaying: false,
        currentSurah: surahNumber,
        currentAyahIndex: -1,
        position: Duration.zero,
        duration: Duration.zero,
        activeReciterId: reciterId,
        isPageMode: false,
        pageVerses: [],
        playbackSpeed: state.playbackSpeed,
        isSingleAyahPlay: false,
        isLoading: true,
        customTitle: null,
        customSubtitle: null,
        isLiveStream: false,
        isRepeatOne: state.isRepeatOne,
        sleepTimeRemaining: state.sleepTimeRemaining,
      );

      final prefs = ref.read(sharedPreferencesProvider);
      prefs.setString('last_type', 'quran');
      prefs.setString('last_quran_reciter', reciterId);
      prefs.setInt('last_quran_surah', surahNumber);
      prefs.setString('last_global_type', 'quran');

      final source = AudioSource.uri(
        Uri.parse(url),
        tag: MediaItem(
          id: 'surah_${reciterId}_$surahNumber',
          album: 'القرآن الكريم',
          title: 'سورة $surahName',
          artist: reciter.nameArabic,
        ),
      );

      await _player.setAudioSource(source);
      if (play) {
        _player.play();
        state = state.copyWith(isPlaying: true, isLoading: false);
      } else {
        state = state.copyWith(isPlaying: false, isLoading: false);
      }
    } catch (e) {
      debugPrint('AudioPlayerNotifier Error: Failed to play surah: $e');
      state = state.copyWith(isPlaying: false, isLoading: false);
    }
  }

  Future<void> playPageAyahs(String reciterId, List<QcfVerse> verses, {int initialIndex = 0, bool play = true}) async {
    if (verses.isEmpty) return;

    try {
      final reciter = _getReciter(reciterId);
      if (!reciter.server.contains('everyayah.com')) {
        debugPrint('AudioPlayerNotifier: Reciter does not support Ayah mode. Falling back to Surah mode.');
        await playSurah(reciterId, verses.first.surahNumber, play: play);
        return;
      }
      
      final sources = verses.map((v) {
        final surahName = surahNamesArabic[v.surahNumber - 1];
        return AudioSource.uri(
          Uri.parse(_getAyahAudioUrl(reciter, v.surahNumber, v.ayahNumber)),
          tag: MediaItem(
            id: 'ayah_${reciterId}_${v.surahNumber}_${v.ayahNumber}',
            album: 'تلاوة الصفحة (آية ${v.ayahNumber})',
            title: 'سورة $surahName',
            artist: reciter.nameArabic,
          ),
        );
      }).toList();

      await _player.stop();

      state = AudioPlaybackState(
        isPlaying: false,
        currentSurah: verses.first.surahNumber,
        currentAyahIndex: initialIndex,
        position: Duration.zero,
        duration: Duration.zero,
        activeReciterId: reciterId,
        isPageMode: true,
        pageVerses: verses,
        playbackSpeed: state.playbackSpeed,
        isSingleAyahPlay: false,
        isLoading: true,
        customTitle: null,
        customSubtitle: null,
        isLiveStream: false,
        isRepeatOne: state.isRepeatOne,
        sleepTimeRemaining: state.sleepTimeRemaining,
      );

      await _player.setAudioSources(sources, initialIndex: initialIndex);
      if (play) {
        _player.play();
        state = state.copyWith(isPlaying: true, isLoading: false);
      } else {
        state = state.copyWith(isPlaying: false, isLoading: false);
      }
    } catch (e) {
      debugPrint('AudioPlayerNotifier Error: Failed to play page: $e');
      state = state.copyWith(isPlaying: false, isLoading: false);
    }
  }

  Future<void> playAyah(String reciterId, int surahNumber, int ayahNumber) async {
    try {
      final reciter = _getReciter(reciterId);
      if (!reciter.server.contains('everyayah.com')) {
        debugPrint('AudioPlayerNotifier: Reciter does not support Ayah mode. Falling back to Surah mode.');
        await playSurah(reciterId, surahNumber);
        return;
      }
      final url = _getAyahAudioUrl(reciter, surahNumber, ayahNumber);
      final surahName = surahNamesArabic[surahNumber - 1];

      await _player.stop();

      state = AudioPlaybackState(
        isPlaying: false,
        currentSurah: surahNumber,
        currentAyahIndex: -1,
        position: Duration.zero,
        duration: Duration.zero,
        activeReciterId: reciterId,
        isPageMode: false,
        pageVerses: [],
        playbackSpeed: state.playbackSpeed,
        isSingleAyahPlay: false,
        isLoading: true,
        customTitle: null,
        customSubtitle: null,
        isLiveStream: false,
        isRepeatOne: state.isRepeatOne,
        sleepTimeRemaining: state.sleepTimeRemaining,
      );

      final source = AudioSource.uri(
        Uri.parse(url),
        tag: MediaItem(
          id: 'ayah_${reciterId}_${surahNumber}_$ayahNumber',
          album: 'آية $ayahNumber',
          title: 'سورة $surahName',
          artist: reciter.nameArabic,
        ),
      );

      await _player.setAudioSource(source);
      _player.play();
      state = state.copyWith(isPlaying: true, isLoading: false);
    } catch (e) {
      debugPrint('AudioPlayerNotifier Error: Failed to play single ayah: $e');
      state = state.copyWith(isPlaying: false, isLoading: false);
    }
  }

  Future<void> playSingleAyah(String reciterId, QcfVerse verse) async {
    try {
      final reciter = _getReciter(reciterId);
      if (!reciter.server.contains('everyayah.com')) {
        debugPrint('AudioPlayerNotifier: Reciter does not support single ayah mode. Falling back to Surah mode.');
        await playSurah(reciterId, verse.surahNumber);
        return;
      }
      final url = _getAyahAudioUrl(reciter, verse.surahNumber, verse.ayahNumber);
      final surahName = surahNamesArabic[verse.surahNumber - 1];

      await _player.stop();

      state = AudioPlaybackState(
        isPlaying: false,
        currentSurah: verse.surahNumber,
        currentAyahIndex: 0,
        position: Duration.zero,
        duration: Duration.zero,
        activeReciterId: reciterId,
        isPageMode: true,
        pageVerses: [verse],
        playbackSpeed: state.playbackSpeed,
        isSingleAyahPlay: true,
        isLoading: true,
        customTitle: null,
        customSubtitle: null,
        isLiveStream: false,
        isRepeatOne: state.isRepeatOne,
        sleepTimeRemaining: state.sleepTimeRemaining,
      );

      final source = AudioSource.uri(
        Uri.parse(url),
        tag: MediaItem(
          id: 'single_ayah_${reciterId}_${verse.surahNumber}_${verse.ayahNumber}',
          album: 'آية ${verse.ayahNumber}',
          title: 'سورة $surahName',
          artist: reciter.nameArabic,
        ),
      );

      await _player.setAudioSource(source);
      _player.play();
      state = state.copyWith(isPlaying: true, isLoading: false);
    } catch (e) {
      debugPrint('AudioPlayerNotifier Error: Failed to play single ayah: $e');
      state = state.copyWith(isPlaying: false, isLoading: false);
    }
  }

  Future<void> playUrl(String url, {required String title, required String subtitle, bool isLiveStream = false}) async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      if (isLiveStream) {
        prefs.setString('last_type', 'radio');
        prefs.setString('last_radio_name', title);
        prefs.setString('last_radio_url', url);
        prefs.setString('last_global_type', 'radio');
      } else {
        prefs.setString('last_type', 'podcast');
        prefs.setString('last_podcast_title', title);
        prefs.setString('last_podcast_publisher', subtitle);
        prefs.setString('last_podcast_url', url);
        prefs.setString('last_global_type', 'podcast');
      }

      await _player.stop();

      state = AudioPlaybackState(
        isPlaying: false,
        currentSurah: -1, // Custom URL indicator
        currentAyahIndex: -1,
        position: Duration.zero,
        duration: Duration.zero,
        activeReciterId: 'custom',
        isPageMode: false,
        pageVerses: [],
        playbackSpeed: state.playbackSpeed,
        isSingleAyahPlay: false,
        isLoading: true,
        customTitle: title,
        customSubtitle: subtitle,
        isLiveStream: isLiveStream,
        isRepeatOne: state.isRepeatOne,
        sleepTimeRemaining: state.sleepTimeRemaining,
      );

      final source = AudioSource.uri(
        Uri.parse(url),
        tag: MediaItem(
          id: url,
          album: isLiveStream ? 'البث الحي' : 'صوتيات إيمان',
          title: title,
          artist: subtitle,
        ),
      );

      await _player.setAudioSource(source);
      _player.play();
      state = state.copyWith(isPlaying: true, isLoading: false);
    } catch (e) {
      debugPrint('AudioPlayerNotifier Error: Failed to play custom URL: $e');
      state = state.copyWith(isPlaying: false, isLoading: false);
    }
  }

  void pause() {
    _player.pause();
    state = state.copyWith(isPlaying: false);
  }

  void resume() {
    if (_player.audioSource == null) {
      if (state.currentSurah > 0) {
        playSurah(state.activeReciterId, state.currentSurah);
      } else if (state.customTitle != null) {
        final prefs = ref.read(sharedPreferencesProvider);
        if (state.isLiveStream) {
          final url = prefs.getString('last_radio_url') ?? 'https://stream.radiojar.com/8s5u55z47v8uv';
          playUrl(url, title: state.customTitle!, subtitle: state.customSubtitle!, isLiveStream: true);
        } else {
          final url = prefs.getString('last_podcast_url');
          if (url != null) {
            playUrl(url, title: state.customTitle!, subtitle: state.customSubtitle!);
          }
        }
      }
    } else {
      _player.play();
      state = state.copyWith(isPlaying: true);
    }
  }

  void stop() {
    _player.stop();
    state = AudioPlaybackState(
      isPlaying: false,
      currentSurah: 0,
      currentAyahIndex: -1,
      position: Duration.zero,
      duration: Duration.zero,
      activeReciterId: state.activeReciterId,
      isPageMode: false,
      pageVerses: [],
      playbackSpeed: state.playbackSpeed,
      isSingleAyahPlay: false,
      isLoading: false,
      customTitle: null,
      customSubtitle: null,
      isLiveStream: false,
      isRepeatOne: state.isRepeatOne,
      sleepTimeRemaining: state.sleepTimeRemaining,
    );
  }

  void seek(Duration pos) {
    _player.seek(pos);
  }

  void seekForward15s() {
    final newPos = state.position + const Duration(seconds: 15);
    if (newPos < state.duration) {
      _player.seek(newPos);
    } else {
      _player.seek(state.duration);
    }
  }

  void seekBackward15s() {
    final newPos = state.position - const Duration(seconds: 15);
    if (newPos > Duration.zero) {
      _player.seek(newPos);
    } else {
      _player.seek(Duration.zero);
    }
  }

  Future<void> next() async {
    if (state.isPageMode) {
      if (state.currentAyahIndex < state.pageVerses.length - 1) {
        _player.seekToNext();
      }
    } else if (state.currentSurah > 0) {
      final nextSurah = (state.currentSurah % 114) + 1;
      await playSurah(state.activeReciterId, nextSurah);
    }
  }

  Future<void> previous() async {
    if (state.isPageMode) {
      if (state.currentAyahIndex > 0) {
        _player.seekToPrevious();
      }
    } else if (state.currentSurah > 0) {
      final prevSurah = state.currentSurah == 1 ? 114 : state.currentSurah - 1;
      await playSurah(state.activeReciterId, prevSurah);
    }
  }

  void setSpeed(double speed) {
    _player.setSpeed(speed);
    state = state.copyWith(playbackSpeed: speed);
  }

  void changeReciter(String reciterId) {
    final wasPlaying = state.isPlaying;
    state = state.copyWith(activeReciterId: reciterId);
    
    if (state.currentSurah > 0) {
      if (state.isPageMode) {
        final index = state.currentAyahIndex >= 0 ? state.currentAyahIndex : 0;
        playPageAyahs(reciterId, state.pageVerses, initialIndex: index, play: wasPlaying);
      } else {
        playSurah(reciterId, state.currentSurah, play: wasPlaying);
      }
    }
  }

  void toggleRepeat() {
    final newRepeat = !state.isRepeatOne;
    _player.setLoopMode(newRepeat ? LoopMode.one : LoopMode.off);
    state = state.copyWith(isRepeatOne: newRepeat);
  }

  void setSleepTimer(Duration? duration) {
    _sleepTimer?.cancel();
    if (duration == null) {
      state = state.copyWith(clearSleepTimer: true);
      return;
    }

    state = state.copyWith(sleepTimeRemaining: duration);
    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.sleepTimeRemaining == null || state.sleepTimeRemaining! <= Duration.zero) {
        timer.cancel();
        stop();
      } else {
        state = state.copyWith(sleepTimeRemaining: state.sleepTimeRemaining! - const Duration(seconds: 1));
      }
    });
  }

  void setLastPlayedState({
    required int surah,
    required String reciterId,
    String? title,
    String? subtitle,
    bool isLiveStream = false,
  }) {
    if (state.isPlaying || state.isLoading) return;
    state = state.copyWith(
      currentSurah: surah,
      activeReciterId: reciterId,
      customTitle: title,
      customSubtitle: subtitle,
      isLiveStream: isLiveStream,
      position: Duration.zero,
      duration: Duration.zero,
    );
  }
}

final audioPlayerProvider = NotifierProvider<AudioPlayerNotifier, AudioPlaybackState>(() {
  return AudioPlayerNotifier();
});
