# بازی‌آموز — Persian early-learning prototype

*(Working title. The final product needs its own name: "Kitkit" and "Enuma" are trademarks of Enuma, Inc.)*

A first, small working prototype of a Persian (Farsi) learning app for **children aged 4–8 in Iran**.
It keeps the play-based approach of [Kitkit School](../README.md) but is **rebuilt from scratch** in
[Flutter](https://flutter.dev), so that it:

- shows Persian correctly: right-to-left, with letters joined and shaped the way they should be;
- runs on **Android, iOS and the web** from one set of code;
- works **completely offline** (no internet, no accounts, no tracking).

The original Kitkit School apps in this repository are **not changed**.

| Home | Letter sounds | Tracing | Reading | Counting |
|---|---|---|---|---|
| ![Home](docs/screenshots/home.png) | ![Sounds](docs/screenshots/letter_sounds.png) | ![Tracing](docs/screenshots/tracing.png) | ![Reading](docs/screenshots/reading.png) | ![Counting](docs/screenshots/counting.png) |

## What's in the prototype

| Activity | Inspired by (Kitkit) | What the child does | What it teaches |
|---|---|---|---|
| **صدای حرف‌ها** (Letter sounds) | SoundTrain, BirdPhonics | Hears a letter or vowel and its example word, taps the matching card among three. | Linking sounds to letter shapes. |
| **بنویسیم** (Let's write) | LetterTrace | Traces a letter or vowel with a finger: from the green circle, **right to left**, body first, **dots and vowel signs last**. Sees the shapes at the start, middle and end of a word. | Correct stroke order and direction; that Persian letters change shape. |
| **بخوانیم** (Let's read) | WordMachine, BirdPhonics | Hears a syllable such as «بُ» and finds it among three cards. Rounds alternate between *same letter, different vowel* (بَ / بِ / بُ) and *same vowel, different letter* (بو / تو / سو). | Decoding: putting a letter and a vowel together, the step before reading words. |
| **بشماریم** (Let's count) | Counting, FeedingTime | Taps each pomegranate (each tap says the next number and shows it in Persian digits), then picks the right number. | One-to-one counting, number words, Persian digits ۱–۱۰. |

The 13 units — **آ، ب، اَ، د، م، ن، او، ت، ای، س، اُ، ر، اِ** — are the first lessons of Iran's Grade 1
Persian textbook (فارسی اول دبستان), in the same order: eight letters plus the three short vowels
(اَ اِ اُ) and two long vowels (او ای). The reading game combines the seven letters with the six vowels
into 42 syllables (بَ بِ بُ با بو بی, دَ دِ دُ ...).

All 13 tracing guides on one sheet, for review by a handwriting teacher: [docs/tracing_guides.png](docs/tracing_guides.png).

Design choices for young children:

- **Audio first.** Instructions are spoken, and a big orange speaker button repeats them, so pre-readers can play alone.
- **No failure states.** A wrong answer fades out gently and the child tries again. A star is earned for getting it right the first time.
- **Big targets**, high contrast, and screen-reader labels for every button.

## How the content is organised (no programming needed to change it)

| What | Where |
|---|---|
| Letters and vowels, example words, tracing shapes | `lib/data/letters.dart` |
| Syllables for the reading game | `lib/data/syllables.dart` |
| Everything the app says aloud | `lib/data/voice_script.dart` |
| Checklist for the voice artist | `docs/RECORDING_SCRIPT.md` |
| Recordings and sound effects | `assets/audio/` |
| Colours | `lib/theme.dart` |
| Font (Vazirmatn) | `assets/fonts/` |

**Voice:** the app plays a real recording as soon as a file named as in `docs/RECORDING_SCRIPT.md`
is placed in `assets/audio/`. Until then it uses the device's own Persian text-to-speech voice if one is
installed (many Android phones have one; browsers often don't), otherwise it stays silent.

**Tracing shapes** are lists of points inside a square from 0 to 1 (0,0 = top-left); the app draws a smooth
curve through them. They are first approximations: a handwriting teacher should review them, and an animator
can replace them with precise paths.

## Try it in a browser (iPhone, Android, computer)

The web version is published with GitHub Pages from the `/docs` folder at the root of this repository:
**https://imaneh1234.github.io/GLEXP-Team-KitkitSchool/**

On an iPhone, open it in Safari, tap Share, then **Add to Home Screen** to get an app icon.
To update the site after changing the app, run `persian_prototype/tool/build_web_pages.sh` and commit `/docs`.

## Running it (for developers)

Requires Flutter 3.50 or newer.

```bash
cd persian_prototype
flutter pub get
flutter test                                       # 19 automated checks
flutter run                                        # on a connected phone or emulator
flutter build apk --release                        # Android
flutter build web --release --no-web-resources-cdn # Web, fully offline
```

`--no-web-resources-cdn` makes the web version include everything it needs instead of downloading
parts from Google's servers, so it also works offline.

## Known limits of this prototype

- No recorded voice yet (text-to-speech fallback only).
- Reading stops at single syllables; whole words (بابا، آب، نان) are the next step.
- Progress isn't saved between sessions.
- Simple drawn graphics only; no illustrations or animations yet.
- Not yet tested with children.

## Credits and licences

See [NOTICE.md](NOTICE.md).
