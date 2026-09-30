# Indovoca

Flutter Web Indonesian vocabulary learning app based on the Stitch design.

## Run in Chrome

```powershell
flutter pub get
flutter run -d chrome
```

## Vocabulary data

The app loads `assets/vocab_cleaned_reindexed.json` at runtime. The supplied dataset contains 2,609 vocabulary entries with translations, parts of speech, usage notes, collocations, and example sentences.

The Vocabulary screen progresses through the dataset in frequency-rank order, while Dictionary searches the full dataset.
