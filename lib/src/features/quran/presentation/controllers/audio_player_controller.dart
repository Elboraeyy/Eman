import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
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
}

const List<Reciter> staticReciters = [
  Reciter(
    id: 'abdul_basit',
    nameEnglish: 'Abdul Basit',
    nameArabic: 'عبد الباسط عبد الصمد',
    server: 'https://everyayah.com/data/Abdul_Basit_Murattal_192kbps/',
    surahServer: 'https://server7.mp3quran.net/basit/',
  ),
  Reciter(
    id: 'al_hudhaifi',
    nameEnglish: 'Al-Hudhaifi',
    nameArabic: 'صالح الحذيفي',
    server: 'https://everyayah.com/data/Hudhaifi_128kbps/',
    surahServer: 'https://server9.mp3quran.net/hudhaifi/',
  ),
  Reciter(
    id: 'al_minshawi',
    nameEnglish: 'Al-Minshawi',
    nameArabic: 'محمد صديق المنشاوي',
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
    );
  }
}

class AudioPlayerNotifier extends Notifier<AudioPlaybackState> {
  late final AudioPlayer _player;
  late final StreamController<void> _pageCompletedController;

  Stream<void> get pageCompletedStream => _pageCompletedController.stream;

  @override
  AudioPlaybackState build() {
    _player = AudioPlayer();
    _pageCompletedController = StreamController<void>.broadcast();

    _initListeners();

    ref.onDispose(() {
      _player.dispose();
      _pageCompletedController.close();
    });

    return AudioPlaybackState(
      isPlaying: false,
      currentSurah: 1,
      currentAyahIndex: -1,
      position: Duration.zero,
      duration: Duration.zero,
      activeReciterId: 'mishary_alfasy',
      isPageMode: false,
      pageVerses: [],
      playbackSpeed: 1.0,
      isSingleAyahPlay: false,
      isLoading: false,
      customTitle: null,
      customSubtitle: null,
      isLiveStream: false,
    );
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
    return staticReciters.firstWhere(
      (r) => r.id == reciterId,
      orElse: () => staticReciters.first,
    );
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

  Future<void> playSurah(String reciterId, int surahNumber) async {
    try {
      final reciter = _getReciter(reciterId);
      final url = _getSurahAudioUrl(reciter, surahNumber);

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
      );

      await _player.setUrl(url);
      _player.play();
    } catch (e) {
      debugPrint('AudioPlayerNotifier Error: Failed to play surah: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> playPageAyahs(String reciterId, List<QcfVerse> verses) async {
    if (verses.isEmpty) return;

    try {
      final reciter = _getReciter(reciterId);
      
      // Load URLs as AudioSources
      final sources = verses.map((v) {
        return AudioSource.uri(Uri.parse(_getAyahAudioUrl(reciter, v.surahNumber, v.ayahNumber)));
      }).toList();

      state = AudioPlaybackState(
        isPlaying: false,
        currentSurah: verses.first.surahNumber,
        currentAyahIndex: 0,
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
      );

      await _player.setAudioSources(sources);
      _player.play();
    } catch (e) {
      debugPrint('AudioPlayerNotifier Error: Failed to play page: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> playAyah(String reciterId, int surahNumber, int ayahNumber) async {
    try {
      final reciter = _getReciter(reciterId);
      final url = _getAyahAudioUrl(reciter, surahNumber, ayahNumber);

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
      );

      await _player.setUrl(url);
      _player.play();
    } catch (e) {
      debugPrint('AudioPlayerNotifier Error: Failed to play single ayah: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> playSingleAyah(String reciterId, QcfVerse verse) async {
    try {
      final reciter = _getReciter(reciterId);
      final url = _getAyahAudioUrl(reciter, verse.surahNumber, verse.ayahNumber);

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
      );

      await _player.setUrl(url);
      _player.play();
    } catch (e) {
      debugPrint('AudioPlayerNotifier Error: Failed to play single ayah: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> playUrl(String url, {required String title, required String subtitle, bool isLiveStream = false}) async {
    try {
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
      );

      await _player.setUrl(url);
      _player.play();
    } catch (e) {
      debugPrint('AudioPlayerNotifier Error: Failed to play custom URL: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  void pause() {
    _player.pause();
  }

  void resume() {
    _player.play();
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
    );
  }

  void seek(Duration pos) {
    _player.seek(pos);
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
    state = state.copyWith(activeReciterId: reciterId);
    
    // If playing, restart with new reciter
    if (state.isPlaying && state.currentSurah > 0) {
      if (state.isPageMode) {
        playPageAyahs(reciterId, state.pageVerses);
      } else {
        playSurah(reciterId, state.currentSurah);
      }
    }
  }
}

final audioPlayerProvider = NotifierProvider<AudioPlayerNotifier, AudioPlaybackState>(() {
  return AudioPlayerNotifier();
});
