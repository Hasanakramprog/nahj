# 📖 Nahj al-Balagha App

A comprehensive Flutter application designed to provide easy access to the sermons, letters, and sayings of **Nahj al-Balagha**. This app aims to deliver a seamless reading experience with features like offline access, search, and sharing capabilities.

## ✨ Features

- **📚 Browse Content**: Access a vast collection of sermons and wisdom from Nahj al-Balagha.
- **🔍 Smart Search**: Quickly find specific topics or keywords within the text.
- **🌙 Dark/Light Mode**: Customizable themes for comfortable reading in any lighting.
- **📤 Share & Bookmark**: Share inspiring quotes with friends or bookmark them for later.
- **💾 Offline Access**: All data is stored locally, ensuring access even without an internet connection.
- **🛠️ Data Scraper**: Includes a Python-based scraper to fetch and update content from reliable sources.

## 🚀 Getting Started

Follow these steps to set up the project on your local machine.

### Prerequisites

Ensure you have the following installed:
- **[Flutter SDK](https://flutter.dev/docs/get-started/install)** (Version 3.8.1 or higher)
- **[Dart SDK](https://dart.dev/get-dart)**
- **[Python](https://www.python.org/downloads/)** (Optional: Only required if you want to run the data scraper)

### 📥 Installation

1.  **Clone the Repository**
    ```bash
    git clone https://github.com/Hasanakramprog/nahj.git
    cd nahj
    ```

2.  **Install Flutter Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Run the Application**
    Connect your device or start an emulator, then run:
    ```bash
    flutter run
    ```

## 🕷️ Data Scraper

This project includes a Python scraper to fetch fresh content. The scraper logic is located in `scraper.py`, and it outputs data to `assets/scraped_output.json`.

For detailed instructions on using the scraper, please refer to the [Scraper Documentation](SCRAPER_README.md).

## 📱 Tech Stack

- **Frontend**: Flutter & Dart
- **State Management**: Provider
- **Local Storage**: Shared Preferences
- **Icons**: Cupertino Icons & Flutter Launcher Icons
- **Formatting**: Google Fonts & Intl

## 🤝 Contributing

Contributions are welcome! If you have suggestions for improvements or want to report a bug, please open an issue or submit a pull request.

1.  Fork the repository.
2.  Create your feature branch (`git checkout -b feature/AmazingFeature`).
3.  Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4.  Push to the branch (`git push origin feature/AmazingFeature`).
5.  Open a Pull Request.

