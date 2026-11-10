import '../models/recipe.dart';
import 'recipe_storage.dart';

class RecipeRepository {
  const RecipeRepository(this._storage);

  final RecipeStorage _storage;

  Future<List<RecipeType>> getTypes() => _storage.getTypes();

  Future<List<Recipe>> getRecipes({int? typeId}) =>
      _storage.getRecipes(typeId: typeId);

  Future<void> saveRecipe(Recipe recipe) => _storage.saveRecipe(recipe);

  Future<void> deleteRecipe(int id) => _storage.deleteRecipe(id);
}
