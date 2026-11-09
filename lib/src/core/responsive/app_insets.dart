import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// أدوات الـ ريسبونس والمسافات الآمنة بتتكون في مكان واحد، وبتغطي:
///
/// 1. الأجهزة اللي فيها أزرار/شريط تنقّل جوه الشاشة (Gesture bar أو
///    3-button nav) — لازم أي محتوى يوصل أرض الشاشة ياخد مسافة =
///    [navBar] فوق أطراف الشاشة.
/// 2. شاشات MainShell (extendBody: true): Flutter بيفرّغ
///    `MediaQuery.padding.bottom` لمحتوى الـ body، فلازم نجيب مسافة
///    النظام الحقيقية من `View.of(context)` بدل ما نعتمد على MediaQuery.
/// 3. التابلت / الشاشات العريضة: دوال مساعدة لأعداد الأعمدة المتجاوبة.
class AppInsets {
  AppInsets._();

  /// مسافة شريط التنقّل السفلي للنظام (بالمنطقي = logical px).
  ///
  /// بتشتغل في أي حتة (جوه MainShell أو خارجها) لأنها بقتش على الـ View
  /// الحقيقية مش الـ MediaQuery المعدّلة، ومش بتتأثر بلوحة المفاتيح.
  static double navBar(BuildContext context) {
    final view = View.of(context);
    return view.viewPadding.bottom / view.devicePixelRatio;
  }

  /// المسافة السفلية لآخر عنصر في شاشة مستقلة (مفيهاش شريط عائم).
  /// (حطها في padding السكرول / آخر SizedBox في العمود)
  static double page(BuildContext context, {double gap = 24}) =>
      navBar(context) + gap;

  /// المسافة السفلية لآخر عنصر جوه MainShell
  /// (شريط التنقّل العائم: 72 ارتفاع + 12 هامش + مسافة النظام).
  static double shell(BuildContext context, {double gap = 28}) =>
      navBar(context) + 84 + gap;

  /// المسافة السفلية جوه MainShell مع مراعاة فقاعة الصوت العائمة
  /// (بتقعد فوق الشريط بحوالي 52px عند تشغيل الصوت).
  static double shellWithAudio(BuildContext context) => navBar(context) + 152;

  /// padding سفلي آمن لأي Bottom Sheet: بينزح لأعلى أكبر من
  /// (لوحة المفاتيح / شريط تنقّل النظام).
  static double sheetBottom(BuildContext context, {double gap = 0}) {
    final mq = MediaQuery.of(context);
    return math.max(mq.viewInsets.bottom, mq.viewPadding.bottom) + gap;
  }

  /// أعمدة شبكة متجاوبة حسب عرض الشاشة (موبايل/تابلت/بوك).
  static int columnsFor(
    double width, {
    double targetTile = 160,
    int min = 2,
    int max = 4,
  }) {
    return (width / targetTile).floor().clamp(min, max);
  }
}

/// امتدادات سريعة للسياق — اختصار للاستدعاءات الشائعة.
extension AppInsetsX on BuildContext {
  /// شريط تنقّل النظام السفلي (logical px).
  double get navBarInset => AppInsets.navBar(this);

  /// padding سفلي جاهز لسكرول شاشة مستقلة.
  double get pageBottomPadding => AppInsets.page(this);

  /// padding سفلي جاهز لسكرول شاشة جوه MainShell.
  double get shellBottomPadding => AppInsets.shell(this);
}
