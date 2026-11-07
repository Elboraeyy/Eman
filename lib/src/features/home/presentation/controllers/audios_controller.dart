import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iman/src/core/network/dio_provider.dart';

// --- Entities ---

class ReciterApi {
  final int id;
  final String name;
  final String letter;
  final String server;
  final String rewaya;
  final List<int> surahList;

  ReciterApi({
    required this.id,
    required this.name,
    required this.letter,
    required this.server,
    required this.rewaya,
    required this.surahList,
  });

  factory ReciterApi.fromJson(Map<String, dynamic> json) {
    final moshafList = json['moshaf'] as List<dynamic>? ?? [];
    String serverUrl = '';
    String rewayaName = 'حفص عن عاصم';
    List<int> surahs = [];
    if (moshafList.isNotEmpty) {
      final mainMoshaf = moshafList.first;
      serverUrl = mainMoshaf['server'] as String? ?? '';
      rewayaName = mainMoshaf['name'] as String? ?? 'حفص عن عاصم';
      final surahListStr = mainMoshaf['surah_list'] as String? ?? '';
      surahs = surahListStr.split(',').map((s) => int.tryParse(s.trim())).whereType<int>().toList();
    }
    return ReciterApi(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      letter: json['letter'] as String? ?? '',
      server: serverUrl,
      rewaya: rewayaName,
      surahList: surahs,
    );
  }
}

class RadioStation {
  final int id;
  final String name;
  final String url;

  RadioStation({
    required this.id,
    required this.name,
    required this.url,
  });

  factory RadioStation.fromJson(Map<String, dynamic> json) {
    return RadioStation(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }
}

class PodcastChannel {
  final int id;
  final String title;
  final String publisher;
  final String description;
  final String imageUrl;
  final List<PodcastEpisode> episodes;

  PodcastChannel({
    required this.id,
    required this.title,
    required this.publisher,
    required this.description,
    required this.imageUrl,
    required this.episodes,
  });

  factory PodcastChannel.fromJson(Map<String, dynamic> json) {
    final episodesList = json['episodes'] as List<dynamic>? ?? [];
    return PodcastChannel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      publisher: json['publisher'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      episodes: episodesList.map((e) => PodcastEpisode.fromJson(e)).toList(),
    );
  }
}

class PodcastEpisode {
  final int id;
  final String title;
  final String duration;
  final String url;
  final String pubDate;

  PodcastEpisode({
    required this.id,
    required this.title,
    required this.duration,
    required this.url,
    required this.pubDate,
  });

  factory PodcastEpisode.fromJson(Map<String, dynamic> json) {
    return PodcastEpisode(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      url: json['url'] as String? ?? '',
      pubDate: json['pubDate'] as String? ?? '',
    );
  }
}

// --- Riverpod Providers ---

final recitersApiProvider = FutureProvider<List<ReciterApi>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('https://mp3quran.net/api/v3/reciters?language=ar');
  if (response.statusCode == 200) {
    final data = response.data;
    final Map<String, dynamic> parsedJson = data is String ? jsonDecode(data) : data;
    final list = parsedJson['reciters'] as List<dynamic>? ?? [];
    return list.map((e) => ReciterApi.fromJson(e)).toList();
  }
  return [];
});

final radiosApiProvider = FutureProvider<List<RadioStation>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('https://mp3quran.net/api/v3/radios?language=ar');
  if (response.statusCode == 200) {
    final data = response.data;
    final Map<String, dynamic> parsedJson = data is String ? jsonDecode(data) : data;
    final list = parsedJson['radios'] as List<dynamic>? ?? [];
    return list.map((e) => RadioStation.fromJson(e)).toList();
  }
  return [];
});

final podcastsProvider = FutureProvider<List<PodcastChannel>>((ref) async {
  final jsonStr = await rootBundle.loadString('assets/podcasts.json');
  final Map<String, dynamic> data = jsonDecode(jsonStr);
  final list = data['podcasts'] as List<dynamic>? ?? [];
  return list.map((e) => PodcastChannel.fromJson(e)).toList();
});
