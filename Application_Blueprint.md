# Application Blueprint: Frequency-Based Indonesian Vocabulary App (BIPA)

> Single source of truth for the project. Read this entire file before generating code.
> Stack assumption: Flutter (Dart), SQLite (sqflite), Firebase (Auth, Firestore, FCM), GitHub Releases/Raw.

---

## 1. Free Backend & Database Architecture

### 1.1 Proposed 100% Free Architecture

The application follows an **offline-first** philosophy: all learning content and user progress reside locally on the device, with selective cloud synchronization for user accounts, progress backup, content updates, and remote notifications.

**Cloud services (all free tiers):**

| Service | Purpose | Free Tier Limits |
| --- | --- | --- |
| **Firebase Authentication** | Email/password registration and login. | Unlimited users, email/password auth free. |
| **Firebase Firestore** | Store user profile, lightweight progress snapshot, vocabulary version marker. | 1 GiB storage, 50K reads/day, 20K writes/day. |
| **Firebase Cloud Messaging (FCM)** | Push notifications (study reminders, word of the day, content updates). | Unlimited notifications (free). |
| **GitHub Releases** | Host APK files and a version manifest JSON for in-app updates. | Unlimited public repositories, releases up to 2 GiB per file. |
| **GitHub Raw / Firebase Storage** | Host vocabulary JSON data (initial 3000 words, later 5000) and delta update packages. | GitHub raw for small JSON; Firebase Storage free tier 5 GiB. |

**Why this stack:**

- Firebase provides a mature, Flutter-friendly backend with generous free quotas.
- GitHub Releases enables automatic APK updates without relying on the Play Store.
- All components are completely free and sufficient for a research project scale (hundreds to a few thousand users).

### 1.2 Data Storage: Local vs. Cloud

**Local (SQLite on device):**

- Full vocabulary database (all words, sentences, translations, audio references).
- User's learning state: flashcard box (Leitner), progress per word (status, correct/incorrect counts, last review date, next due date).
- User preferences: notification settings (local vs. remote, reminder time), daily goal, TTS language.
- Temporary quiz results (if quizzes are purely local).
- Cached version numbers for vocabulary and app.
- Offline dictionary index (for fast search).

**Cloud (Firestore):**

- User profile: `uid`, `email`, `name`, `university`, `nationality`, `proficiencyLevel`, `registrationDate`.
- Aggregated progress snapshot (updated rarely):
  - `totalWordsLearned` (count where status = "learned")
  - `currentStreak`
  - `lastActiveDate`
  - `vocabularyVersionInstalled`
- (Optional) Daily activity log. To minimize writes, store only a single summary document per user, updated on app close or after significant events.

**Sync strategy:**

- The app uses Firestore **only** for login, progress backup, and remote notification token registration.
- On first login after registration, the app downloads the user profile and sets up the local DB.
- Progress is synced to Firestore in two cases:
  - When the user explicitly taps "Sync now" in settings.
  - Automatically on app background/close (throttled to once per hour).
- Vocabulary content is **never** synced per-user; it is downloaded once per version update and stored locally.

This minimizes bandwidth and Firestore reads/writes, keeping the app fully functional offline while enabling remote push capabilities.

---

## 2. Vocabulary Data Model (Schema)

Vocabulary content is stored locally in SQLite and distributed as JSON for updates. The schema supports versioning and both **full** and **delta** (incremental) updates.

### 2.1 JSON Format (for download/update)

The remote manifest (`vocab_manifest.json`) contains:

```json
{
  "version": 2,
  "totalWords": 5000,
  "fullDownloadUrl": "https://raw.githubusercontent.com/.../vocab_v2_full.json",
  "deltaFrom": [1],
  "deltaDownloadUrl": "https://.../vocab_delta_1_to_2.json",
  "updateStrategy": "delta_or_full"
}
```

Note: `updateStrategy` lets the app choose between delta and full based on its current installed version. (Do not put comments inside the real JSON file; JSON does not support them.)

- **Full update:** Replaces the entire vocabulary table but **preserves user progress** by matching `word_id` (existing words keep progress; new words get default progress).
- **Delta update:** Contains only new or modified words. The app applies changes without touching other words.

**Word object (same for full and delta):**

```json
{
  "wordId": 2913,
  "indonesian": "gubernur",
  "frequencyRank": 2913,
  "translation": "governor",
  "pos": "noun",
  "usageNote": "",
  "collocationIdn": "gubernur provinsi",
  "collocationEng": "province governor",
  "exampleSentenceIdn": "Gubernur akan mengunjungi sekolah besok",
  "exampleSentenceEng": "The governor will visit the school tomorrow"
}
```

### 2.2 SQLite Schema (local)

The `vocabulary` table is **updated to match the JSON word object above** (10 fields, same order).

#### Table: `vocabulary`

| Column | Type | JSON field | Description |
| --- | --- | --- | --- |
| `word_id` | INTEGER PRIMARY KEY | `wordId` | Unique identifier. Used to match user progress across vocabulary updates. |
| `indonesian` | TEXT NOT NULL | `indonesian` | Indonesian word. |
| `frequency_rank` | INTEGER | `frequencyRank` | Rank from frequency corpus. |
| `translation` | TEXT | `translation` | English translation. |
| `pos` | TEXT | `pos` | Part of speech (verb, noun, adj., etc.). |
| `usage_note` | TEXT | `usageNote` | Optional usage or cultural note. May be an empty string. |
| `collocation_idn` | TEXT | `collocationIdn` | Common collocation/context in Indonesian. |
| `collocation_eng` | TEXT | `collocationEng` | English translation of the collocation. |
| `example_sentence_idn` | TEXT | `exampleSentenceIdn` | Example sentence in Indonesian. |
| `example_sentence_eng` | TEXT | `exampleSentenceEng` | Example sentence in English. |

Suggested DDL:

```sql
CREATE TABLE vocabulary (
    word_id              INTEGER PRIMARY KEY,
    indonesian           TEXT NOT NULL,
    frequency_rank       INTEGER,
    translation          TEXT,
    pos                  TEXT,
    usage_note           TEXT,
    collocation_idn      TEXT,
    collocation_eng      TEXT,
    example_sentence_idn TEXT,
    example_sentence_eng TEXT
);

CREATE INDEX idx_vocabulary_indonesian ON vocabulary(indonesian);
CREATE INDEX idx_vocabulary_frequency_rank ON vocabulary(frequency_rank);
```

**Mapping rule:** JSON keys are `camelCase`; SQLite columns are `snake_case`. The import/update code must map between them explicitly (see the "JSON field" column). Note that the old single `collocation` column no longer exists; it is replaced by `collocation_idn` + `collocation_eng`, and `usage_note` is new.

#### Table: `user_progress`

| Column | Type | Description |
| --- | --- | --- |
| `user_id` | TEXT | Firebase UID (or local ID if not logged in). |
| `word_id` | INTEGER | Foreign key to `vocabulary.word_id`. |
| `status` | INTEGER | 0 = new, 1 = learning, 2 = learned, 3 = mastered. |
| `leitner_box` | INTEGER | 0-5 (Leitner box number). |
| `correct_count` | INTEGER | Number of correct answers. |
| `incorrect_count` | INTEGER | Number of incorrect answers. |
| `last_reviewed` | INTEGER | Timestamp of last review. |
| `next_due` | INTEGER | Timestamp when the word is due for review. |
| `is_favorite` | INTEGER | 0/1. |

#### Progress calculation: `user_summary`

```sql
CREATE TABLE user_summary (
    user_id TEXT PRIMARY KEY,
    total_words_seen INTEGER,        -- Count of words with progress
    total_words_learned INTEGER,     -- Count with status >= 2
    total_words_mastered INTEGER,    -- Count with status = 3
    furthest_rank INTEGER,           -- Max frequency_rank learned
    current_streak INTEGER,          -- Consecutive days
    longest_streak INTEGER,
    last_study_date TEXT,
    updated_at INTEGER
);
```

**Update triggers or app logic:**

```dart
// After each study session
void updateSummary(String userId) {
  final summary = calculateSummary(userId);
  db.insert('user_summary', summary.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace);
}
```

#### Table: `app_meta`

| Key | Value |
| --- | --- |
| `vocab_version` | Current installed vocabulary version. |
| `app_version` | Currently installed app version (from pubspec). |
| `last_sync` | Timestamp of last Firestore sync. |
| `fcm_token` | Latest Firebase Cloud Messaging token for remote notifications. |

This schema supports SRS (Leitner), offline dictionary search, and both local and remote progress tracking.

---

## 3. Application Page Flow & Information Architecture

The app contains **9 core screens** (excluding external research instruments).

### 3.1 Splash / Initialization Screen

- Checks local database, app version, and internet connectivity.
- If online: fetch remote version manifest (from GitHub) and vocabulary manifest.
- If app update available → redirect to **Update Screen**.
- If vocabulary update available → download in background (show progress) using the appropriate strategy (delta or full).
- If not logged in → navigate to **Onboarding**.

### 3.2 Onboarding / Authentication

- **Login** with email/password (Firebase Auth).
- **Register** → after account creation, the user must complete a **Demographic Survey** (fields: name, email, university, nationality, Indonesian proficiency level [Beginner/Intermediate/Advanced]).
- Option to skip login and use offline mode (progress stored locally but not backed up). For research, login is encouraged but not mandatory.

### 3.3 Home / Dashboard

- Displays daily goal progress (e.g., words reviewed today).
- Current streak and total learned words.
- Quick action buttons: "Study" (flashcards), "Practice" (quiz), "Dictionary" (offline lookup).
- Notification settings shortcut (manage local and remote preferences).
- Sync status indicator.

### 3.4 Vocabulary Study / Flashcards

- Card-based learning (front: Indonesian word + audio button; back: translation, example sentences).
- Buttons: "Know it" (promotes to next Leitner box), "Still learning" (keeps or demotes).
- TTS audio playback on demand (using device TTS or pre-recorded assets).
- Progress saved locally; due words shown according to SRS schedule.

### 3.5 Practice / Quiz

- Multiple-choice or typing exercises generated from due vocabulary.
- Immediate feedback with the correct answer and example sentence.
- Updates word progress (correct/incorrect counts, Leitner box).
- Option to review mistakes after the quiz.

### 3.6 Offline Dictionary Lookup

- Searchable list of all vocabulary words.
- Each entry shows: Indonesian word, translation, part of speech, frequency rank, usage note (if not empty), collocation (Indonesian + English), example sentences (both languages), and an audio button.
- Works completely offline (SQLite query).
- Allows marking a word as favorite for later review.

### 3.7 Profile / Settings

- Shows user demographic info (editable).
- App version, vocabulary version, last sync time.
- Notification preferences:
  - Enable/disable local reminders (choose time).
  - Enable/disable remote push notifications (FCM token management).
- Manual sync button.
- Logout.

### 3.8 Update Screen (Forced App Update)

- Shown when the remote manifest indicates a newer APK version.
- Displays version changelog (optional) and a **Download & Install** button.
- Downloads the APK from GitHub Releases using `flutter_downloader` or `dio`, then opens the installer (requires `REQUEST_INSTALL_PACKAGES` permission on Android).
- User cannot bypass; the app remains blocked until the update completes.

### 3.9 Vocabulary Update Notice (Non-blocking)

- Shown as a banner or modal when new vocabulary is available.
- User can choose to download immediately or continue with current data (download in background).
- The app automatically chooses a delta update if available, otherwise a full download.
- After download, the local DB is updated, preserving all user progress for existing words and adding new ones.

### 3.10 Primary UI Components

- Flashcard widget with flip animation.
- ProgressBar for daily goal.
- LeitnerBoxIndicator showing distribution.
- NotificationSettings with time picker and toggles for local/remote.
- ForceUpdateDialog with progress bar.
- DictionarySearchBar with live filtering.

All screens work offline except those requiring authentication, update downloads, or remote notification registration.

---

## 4. Feature Prioritization & Trade-offs

### 4.1 Core MVP Features (Must-Have for PKM Research Timeline)

1. **User Registration & Login (Firebase Auth)** – essential for demographic tracking and progress backup.
2. **Demographic Survey** – required fields: name, email, university, nationality, proficiency level.
3. **Offline Vocabulary Database** – initial 3000 words, stored in SQLite, fully functional offline.
4. **Flashcard Study with Basic SRS (Leitner Box)** – simple spaced repetition to promote retention.
5. **Practice Quiz** – multiple-choice questions derived from the user's due words.
6. **Progress Tracking** – per-word status, counts, and daily streak.
7. **Manual/Background Sync** – upload progress to Firestore (backup).
8. **App Version Check & Forced Update** – using GitHub Releases.
9. **Vocabulary Version Check & Update** – support both full and delta updates to minimize data usage.
10. **Offline Dictionary Lookup** – essential for quick reference and review; included in MVP because it requires no backend and greatly enhances usability.

### 4.2 Retention & Engagement Features

- **Notifications (Dual)**
  - *Local scheduled reminders*: set a daily study time; works offline.
  - *Remote push notifications (FCM)*: allow sending Word of the Day and content announcements.
- **Word of the Day Notification**
  - Daily push/local notification containing a new vocabulary word, its translation, and example sentence.
  - Tapping the notification opens the app to the dictionary entry or flashcard.
- **Streak & Gamification** – display streak count, maybe simple badges.
- **Audio Pronunciation** – use device Text-to-Speech (Google TTS) for Indonesian words; no extra assets needed.
- **Favorites / Word Collection** – allow users to mark difficult words for extra review.

### 4.3 Trade-offs & Decisions

- **Why keep pre/post/SUS external?**
  Reduces app complexity and avoids building survey logic. Researchers can administer these via Google Forms or Qualtrics, linked by the user's email or a generated participant ID. The app only logs usage data, which can be exported for correlation.
- **Force update vs. optional update:**
  Force update ensures all users run the same version, critical for research consistency. The update is distributed via GitHub Releases, which is free and reliable for APK hosting.
- **Offline-first with minimal sync:**
  Reduces dependency on internet and keeps Firestore costs near zero. Users can study entirely offline; only sync when needed. Remote notifications require a valid FCM token, but if offline they simply don't receive push until reconnected.
- **Vocabulary update flexibility:**
  Supporting both delta and full updates allows the research team to publish small corrections (delta) or major expansions (full) without forcing users to re-download everything. The app automatically chooses the best strategy based on the current installed version and available deltas.

---

## 5. Interactive Consultation

### 5.1 Recommended High-Impact Optional Features for BIPA Learners

- **Cultural Context Cards** – Each vocabulary word includes a short note about Indonesian culture or usage nuance (e.g., formality levels like "kamu" vs. "Anda"). *This maps to the `usageNote` / `usage_note` field already present in the schema.*
- **Audio Recording & Playback** – Allow users to record their pronunciation and compare it with the TTS reference (requires local audio recording permission).
- **Mini-Dialogues** – Pre-built conversational scenarios that combine multiple vocabulary items (e.g., ordering food, asking directions).
- **Grammar Tips** – Brief explanations of common grammar patterns encountered in the example sentences.
- **Offline Progress Export** – Let users export their own progress as CSV or JSON for personal analysis.
