# Zad (زاد) 🕋

A premium, elegant, and lightweight Islamic Flutter application styled with a modern two-layer overlapping UI and warm aesthetics.

---

## ✨ Features

The application features a beautifully structured, responsive layout:

*   📖 **Holy Quran**: Full recitation and translation support.
*   📜 **Prophetic Hadith**: Complete access to collections of Hadith (Riyad as-Salihin).
*   📿 **Tasbih (Counter)**: An interactive digital prayer beads counter.
*   🕌 **Prayer Times**: Automatic location-based prayer times with a next prayer countdown.
*   🧭 **Qibla Direction**: A precise interactive compass to locate the Kaaba.
*   🤲 **Adhkar & Supplications**: Fortress of the Muslim (morning, evening, and daily remembrance).
*   🎧 **Audios**: Beautiful recitations, Quran radio stations, and audio supplications/podcasts.
*   ✨ **Sunan**: A comprehensive guide to the daily Sunnah of Prophet Muhammad ﷺ with progress checklist.
*   📚 **Stories**: Islamic and prophetic historical stories with search, lessons, and bookmarking.

---

## 🛠️ Tech Stack

*   **Framework**: [Flutter](https://flutter.dev) (iOS & Android)
*   **State Management**: [Riverpod](https://riverpod.dev) (with code generation)
*   **Routing**: [GoRouter](https://pub.dev/packages/go_router)
*   **Local Database**: [Drift (SQLite)](https://drift.simonbinder.eu)
*   **Aesthetics**: Two-layer overlapping sheet layout, custom painted Rub el Hizb backgrounds, SVG icons, and smooth transitions via `Flutter Animate`.

---

## 🚀 Getting Started

1.  **Clone the repository**:
    ```bash
    git clone <repository-url>
    cd zad
    ```
2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Generate database code**:
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```
4.  **Run the application**:
    ```bash
    flutter run
    ```
