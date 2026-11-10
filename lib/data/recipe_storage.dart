import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/recipe.dart';

class RecipeStorage {
  Database? _database;

  Future<Database> get _db async {
    if (_database != null) return _database!;
    final databasePath = await getDatabasesPath();
    _database = await openDatabase(
      path.join(databasePath, 'recipe_book.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE recipe_types (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE recipes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            type_id INTEGER NOT NULL,
            image_path TEXT NOT NULL,
            ingredients TEXT NOT NULL,
            steps TEXT NOT NULL,
            prep_minutes INTEGER NOT NULL,
            FOREIGN KEY (type_id) REFERENCES recipe_types (id)
          )
        ''');
      },
    );
    await _seedTypes(_database!);
    await _seedRecipes(_database!);
    return _database!;
  }

  Future<void> _seedTypes(Database db) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM recipe_types'),
    );
    if ((count ?? 0) > 0) return;

    final jsonText = await rootBundle.loadString(
      'assets/data/recipetypes.json',
    );
    final types = (jsonDecode(jsonText) as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(RecipeType.fromJson);
    final batch = db.batch();
    for (final type in types) {
      batch.insert('recipe_types', {'id': type.id, 'name': type.name});
    }
    await batch.commit(noResult: true);
  }

  Future<void> _seedRecipes(Database db) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM recipes'),
    );
    if ((count ?? 0) > 0) return;

    final samples = [
      Recipe(
        title: 'Avocado Breakfast Toast',
        description:
            'Crispy sourdough with creamy avocado and a bright finish.',
        typeId: 1,
        imagePath:
            'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=900',
        ingredients: [
          '2 slices sourdough',
          '1 ripe avocado',
          '1 lemon',
          'Chili flakes',
        ],
        steps: [
          'Toast the sourdough until golden.',
          'Mash avocado with lemon juice and a pinch of salt.',
          'Spread over toast and finish with chili flakes.',
        ],
        prepMinutes: 10,
      ),
      Recipe(
        title: 'Lemon Herb Chicken',
        description: 'A simple, juicy skillet chicken with fresh herbs.',
        typeId: 2,
        imagePath:
            'https://images.unsplash.com/photo-1532550907401-a500c9a57435?w=900',
        ingredients: [
          '2 chicken breasts',
          '1 lemon',
          '2 tbsp olive oil',
          'Parsley',
        ],
        steps: [
          'Season chicken with salt and pepper.',
          'Sear in olive oil until cooked through.',
          'Add lemon juice and parsley, then serve warm.',
        ],
        prepMinutes: 30,
      ),
      Recipe(
        title: 'Garden Tomato Salad',
        description: 'Juicy tomatoes, crisp cucumber, and a quick vinaigrette.',
        typeId: 3,
        imagePath:
            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=900',
        ingredients: [
          '3 ripe tomatoes',
          '1 cucumber',
          '2 tbsp olive oil',
          'Fresh basil',
        ],
        steps: [
          'Cut tomatoes and cucumber into bite-size pieces.',
          'Toss with olive oil, salt, and torn basil.',
          'Let stand for 5 minutes before serving.',
        ],
        prepMinutes: 15,
      ),
      Recipe(
        title: 'Creamy Pumpkin Soup',
        description: 'Comforting roasted pumpkin soup with a silky texture.',
        typeId: 4,
        imagePath:
            'https://images.unsplash.com/photo-1476718406336-bb5a9690ee2a?w=900',
        ingredients: [
          '500 g pumpkin',
          '1 onion',
          '500 ml vegetable stock',
          '100 ml cream',
        ],
        steps: [
          'Roast pumpkin pieces until tender.',
          'Soften chopped onion in a pot and add the pumpkin and stock.',
          'Blend until smooth, stir in cream, and season to taste.',
        ],
        prepMinutes: 40,
      ),
      Recipe(
        title: 'Berry Yogurt Parfait',
        description: 'Layers of berries, creamy yogurt, and crunchy granola.',
        typeId: 5,
        imagePath:
            'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=900',
        ingredients: [
          '1 cup Greek yogurt',
          '1 cup mixed berries',
          '½ cup granola',
          '1 tsp honey',
        ],
        steps: [
          'Spoon yogurt into a glass.',
          'Add a layer of berries and granola.',
          'Repeat the layers and drizzle with honey.',
        ],
        prepMinutes: 8,
      ),
    ];
    final batch = db.batch();
    for (final recipe in samples) {
      batch.insert('recipes', recipe.toDatabase());
    }
    await batch.commit(noResult: true);
  }

  Future<List<RecipeType>> getTypes() async {
    final db = await _db;
    final rows = await db.query('recipe_types', orderBy: 'name');
    return rows.map(RecipeType.fromJson).toList();
  }

  Future<List<Recipe>> getRecipes({int? typeId}) async {
    final db = await _db;
    final rows = await db.query(
      'recipes',
      where: typeId == null ? null : 'type_id = ?',
      whereArgs: typeId == null ? null : [typeId],
      orderBy: 'title COLLATE NOCASE',
    );
    return rows.map(Recipe.fromDatabase).toList();
  }

  Future<void> saveRecipe(Recipe recipe) async {
    final db = await _db;
    if (recipe.id == null) {
      await db.insert('recipes', recipe.toDatabase());
    } else {
      await db.update(
        'recipes',
        recipe.toDatabase()..remove('id'),
        where: 'id = ?',
        whereArgs: [recipe.id],
      );
    }
  }

  Future<void> deleteRecipe(int id) async {
    final db = await _db;
    await db.delete('recipes', where: 'id = ?', whereArgs: [id]);
  }
}
