import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/models/recipe.dart';

void main() {
  group('Recipe', () {
    test('round trips its editable fields through database values', () {
      const recipe = Recipe(
        id: 7,
        title: 'Tomato soup',
        description: 'A quick soup',
        typeId: 4,
        imagePath: '/images/soup.jpg',
        ingredients: ['Tomatoes', 'Stock'],
        steps: ['Chop tomatoes', 'Simmer with stock'],
        prepMinutes: 25,
      );

      final restored = Recipe.fromDatabase(recipe.toDatabase());

      expect(restored.id, recipe.id);
      expect(restored.title, recipe.title);
      expect(restored.description, recipe.description);
      expect(restored.typeId, recipe.typeId);
      expect(restored.imagePath, recipe.imagePath);
      expect(restored.ingredients, recipe.ingredients);
      expect(restored.steps, recipe.steps);
      expect(restored.prepMinutes, recipe.prepMinutes);
    });

    test('copyWith can assign a different type', () {
      const recipe = Recipe(
        title: 'Toast',
        description: 'Breakfast',
        typeId: 1,
        imagePath: '',
        ingredients: ['Bread'],
        steps: ['Toast bread'],
        prepMinutes: 5,
      );

      expect(recipe.copyWith(typeId: 2).typeId, 2);
      expect(recipe.copyWith(typeId: 2).title, recipe.title);
    });
  });
}
