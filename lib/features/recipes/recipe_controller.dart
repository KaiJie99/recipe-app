import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../data/recipe_repository.dart';
import '../../models/recipe.dart';
import '../../network/meal_api.dart';

class RecipeController extends GetxController {
  RecipeController(this._repository, this._mealApi);

  final RecipeRepository _repository;
  final MealApi _mealApi;
  final RxList<Recipe> recipes = <Recipe>[].obs;
  final RxList<RecipeType> recipeTypes = <RecipeType>[].obs;
  final RxList<Recipe> onlineRecipes = <Recipe>[].obs;
  final RxnInt selectedTypeId = RxnInt();
  final RxBool isLoading = true.obs;
  final RxBool isSearchingOnline = false.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      recipeTypes.assignAll(await _repository.getTypes());
      await loadRecipes();
    } catch (error) {
      errorMessage.value = 'Could not load recipes. $error';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadRecipes() async {
    try {
      recipes.assignAll(
        await _repository.getRecipes(typeId: selectedTypeId.value),
      );
      errorMessage.value = null;
    } catch (error) {
      errorMessage.value = 'Could not read saved recipes. $error';
    }
  }

  Future<void> filterByType(int? typeId) async {
    selectedTypeId.value = typeId;
    await loadRecipes();
  }

  Future<bool> saveRecipe(Recipe recipe) async {
    try {
      await _repository.saveRecipe(recipe);
      await loadRecipes();
      Get.snackbar('Saved', '${recipe.title} is in your recipe book.');
      return true;
    } catch (error) {
      Get.snackbar('Save failed', '$error');
      return false;
    }
  }

  Future<void> deleteRecipe(Recipe recipe) async {
    final id = recipe.id;
    if (id == null) return;
    try {
      await _repository.deleteRecipe(id);
      await loadRecipes();
      Get.back<void>();
      Get.snackbar('Deleted', '${recipe.title} was removed.');
    } catch (error) {
      Get.snackbar('Delete failed', '$error');
    }
  }

  Future<String?> pickAndStoreImage() async {
    try {
      final selected = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1800,
      );
      if (selected == null) return null;
      final directory = await getApplicationDocumentsDirectory();
      final extension = path.extension(selected.path);
      final savedPath = path.join(
        directory.path,
        'recipe_${DateTime.now().microsecondsSinceEpoch}$extension',
      );
      await File(selected.path).copy(savedPath);
      return savedPath;
    } catch (error) {
      Get.snackbar('Image unavailable', '$error');
      return null;
    }
  }

  Future<void> searchOnline(String query) async {
    isSearchingOnline.value = true;
    onlineRecipes.clear();
    try {
      final result = await _mealApi.searchMeals(query.trim());
      if (result is! Map<String, dynamic>) {
        throw const FormatException('Unexpected recipe search response.');
      }
      final response = result;
      final meals = response['meals'] as List<dynamic>? ?? const [];
      onlineRecipes.assignAll(
        meals
            .cast<Map<String, dynamic>>()
            .map(_recipeFromMeal)
            .toList(growable: false),
      );
    } catch (error) {
      Get.snackbar('Search unavailable', 'Could not reach the recipe service.');
    } finally {
      isSearchingOnline.value = false;
    }
  }

  Recipe _recipeFromMeal(Map<String, dynamic> meal) {
    final ingredients = <String>[];
    for (var index = 1; index <= 20; index++) {
      final ingredient = '${meal['strIngredient$index'] ?? ''}'.trim();
      final measure = '${meal['strMeasure$index'] ?? ''}'.trim();
      if (ingredient.isNotEmpty) {
        ingredients.add(measure.isEmpty ? ingredient : '$measure $ingredient');
      }
    }
    final instructions = '${meal['strInstructions'] ?? ''}'
        .split(RegExp(r'\r?\n+'))
        .map((step) => step.trim())
        .where((step) => step.isNotEmpty)
        .toList();
    return Recipe(
      title: '${meal['strMeal'] ?? 'Untitled recipe'}',
      description: 'Imported from TheMealDB',
      typeId: recipeTypes.isEmpty ? 1 : recipeTypes.first.id,
      imagePath: '${meal['strMealThumb'] ?? ''}',
      ingredients: ingredients,
      steps: instructions,
      prepMinutes: 30,
    );
  }
}
