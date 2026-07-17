# Entertainment Tracker (Flutter)

Flutter client for the Entertainment Tracker app.

## Getting Started

From this directory:

```bash
flutter pub get
flutter run
```

### Film / show search (TMDb)

IMDb and Google are not used (no free public API / scraping). Search uses [TMDb](https://www.themoviedb.org/settings/api).

1. Create a free TMDb account and request an API key.
2. Run with the key:

```bash
flutter run --dart-define=TMDB_API_KEY=your_key_here
```

Without a key, you can still type a title manually; live search results will not appear.

### Windows build

```bash
flutter build windows --dart-define=TMDB_API_KEY=your_key_here
```

The project path must not contain spaces (CMake install step breaks on spaced paths).
