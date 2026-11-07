import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'arabic_text.dart';

/// إطار «اسم السورة» الزخرفي (فريم الإطار) — صورة PNG شفافة معزولة عن الخلفية
/// في [assets/images/iman2_frame.png] بألوانها الأصلية (نبيتي + لوح مشفاف بلون الصفحة)
/// لوح النص يبدأ من 28.3% من العرض من كل جهة (مقاس من الصورة الأصلية 678×79)
///
/// نص الاسم:
/// - لو فيه [surahNumber] يُرسم بكتابة `surahXXX` بـخط SurahNameV1
///   (خط أسماء السور من QUL — لكل سورة كليغاتور خاص 001..114)
/// - غير كده يُرسم بنص عربي عادي بخط ألميري
class SurahNameFrame extends StatelessWidget {
  final String surahName;
  final int? surahNumber;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  static const double aspect = 678 / 79; // نسبة الصورة المعزولة

  const SurahNameFrame({
    super.key,
    required this.surahName,
    this.surahNumber,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final w = width ?? (height ?? 44.0) * aspect;
    final h = w / aspect;

    return InkWell(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // الفريم بألوانه الأصلية (نبيتي) — لا يحتاج تلوينًا خارجيًا
          Image.asset(
            'assets/images/iman2_frame.png',
            width: w,
            height: h,
            fit: BoxFit.fill,
          ),
          // نص اسم السورة داخل اللوح الأوسط — حجم أصغر ومقيّد بمساحة اللوح
          // padding رأسي غير متماثل: ينزل الاسم شوية لتحت جوّه الفريم
          Padding(
            padding: EdgeInsets.only(
              left: w * 0.315,
              right: w * 0.315,
              top: h * 0.21,
              bottom: h * 0.11,
            ),
            child: Align(
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: surahNumber != null
                    // ملاحظة مهمة: Text عادية مش ArabicText
                    // لأن ArabicText بتحول الأرقام لعربية (٠٠١) فتُلغي الكليغاتور
                    ? Text(
                        'surah${surahNumber.toString().padLeft(3, '0')}',
                        maxLines: 1,
                        semanticsLabel: surahName,
                        style: TextStyle(
                          fontFamily: 'SurahNameV1',
                          fontSize: w * 0.080,
                          // نبيتي داكن مناسِب للقراءة
                          color: const Color(0xFF6E3230),
                        ),
                      )
                    : ArabicText(
                        surahName,
                        maxLines: 1,
                        style: GoogleFonts.amiri(
                          fontSize: w * 0.050,
                          fontWeight: FontWeight.bold,
                          // نبيتي داكن مناسِب للقراءة على اللوح
                          color: const Color(0xFF6E3230),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
