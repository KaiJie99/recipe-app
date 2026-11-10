# Recipe Book

A responsive Flutter recipe manager using GetX for reactive state, SQLite for
offline persistence, and Dio/Retrofit for optional online recipe search.

## Features

- Recipe types are read from `assets/data/recipetypes.json` and seeded into the
  local SQLite database.
- Five sample recipes are inserted on first launch.
- Browse and filter recipes by type; create, edit, and delete recipes.
- Store recipe photos in the app documents directory.
- Search TheMealDB and save results into a chosen local recipe type.
- GetX `Obx` bindings keep the recipe list and online search state reactive.

## Run

```shell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

The Retrofit generated client is checked in as `lib/network/meal_api.g.dart`.
Regenerate it after changing `MealApi` annotations.

## Test and build

```shell
flutter test
flutter analyze
flutter build apk
```

Online search requires an internet connection. All saved recipes and the
pre-populated sample collection work offline.
