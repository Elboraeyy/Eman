import 'package:flutter/services.dart';

class FontLoaderHelper {
  FontLoaderHelper._();

  static const String bsmlFontFamily = 'QCF_BSML';
  static final Set<String> _loadedFonts = {};

  /// Dynamically loads a page font from the assets folder.
  /// Format: assets/fonts/QCF_P[PageNumber].TTF (e.g. QCF_P001.TTF)
  static Future<String> loadPageFont(int pageNumber) async {
    final fontName = 'QCF_P${pageNumber.toString().padLeft(3, '0')}';
    
    // Check if font has already been loaded in this app instance
    if (_loadedFonts.contains(fontName)) {
      return fontName;
    }

    try {
      final fontLoader = FontLoader(fontName);
      final fontData = rootBundle.load('assets/fonts/$fontName.TTF');
      fontLoader.addFont(fontData);
      await fontLoader.load();
      _loadedFonts.add(fontName);
    } catch (e) {
      // Fallback: If page font fails to load, use standard sans-serif
      // or default system font.
      print('Error loading dynamic QCF font $fontName: $e');
    }
    
    return fontName;
  }

  /// Dynamically loads the Bismillah font.
  static Future<String> loadBismillahFont() async {
    if (_loadedFonts.contains(bsmlFontFamily)) {
      return bsmlFontFamily;
    }

    try {
      final fontLoader = FontLoader(bsmlFontFamily);
      final fontData = rootBundle.load('assets/fonts/QCF_BSML.TTF');
      fontLoader.addFont(fontData);
      await fontLoader.load();
      _loadedFonts.add(bsmlFontFamily);
    } catch (e) {
      print('Error loading Bismillah font: $e');
    }
    
    return bsmlFontFamily;
  }
}
