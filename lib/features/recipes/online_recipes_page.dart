import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/recipe.dart';
import 'recipe_controller.dart';
import 'widgets/recipe_image.dart';

class OnlineRecipesPage extends StatefulWidget {
  const OnlineRecipesPage({super.key});

  @override
  State<OnlineRecipesPage> createState() => _OnlineRecipesPageState();
}

class _OnlineRecipesPageState extends State<OnlineRecipesPage> {
  final _searchController = TextEditingController();
  final _recipeController = Get.find<RecipeController>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find recipes online')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: _search,
              decoration: InputDecoration(
                hintText: 'Search by recipe name',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  tooltip: 'Search',
                  onPressed: () => _search(_searchController.text),
                  icon: const Icon(Icons.arrow_forward_rounded),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (_recipeController.isSearchingOnline.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_recipeController.onlineRecipes.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(28),
                    child: Text(
                      'Search TheMealDB for inspiration, then add a recipe to your collection.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: _recipeController.onlineRecipes.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final recipe = _recipeController.onlineRecipes[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading: SizedBox(
                        width: 64,
                        height: 64,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: RecipeImage(imagePath: recipe.imagePath),
                        ),
                      ),
                      title: Text(recipe.title),
                      subtitle: Text(
                        '${recipe.ingredients.length} ingredients',
                      ),
                      trailing: IconButton(
                        tooltip: 'Add to my recipes',
                        onPressed: () => _addRecipe(recipe),
                        icon: const Icon(Icons.add_circle_outline_rounded),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      Get.snackbar('Search needed', 'Enter a recipe name to search.');
      return;
    }
    await _recipeController.searchOnline(query);
  }

  Future<void> _addRecipe(Recipe recipe) async {
    if (_recipeController.recipeTypes.isEmpty) return;
    var typeId = _recipeController.recipeTypes.first.id;
    final savedTypeId = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Choose a recipe type'),
          content: DropdownButtonFormField<int>(
            initialValue: typeId,
            items: _recipeController.recipeTypes
                .map(
                  (type) => DropdownMenuItem<int>(
                    value: type.id,
                    child: Text(type.name),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setDialogState(() => typeId = value);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, typeId),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
    if (savedTypeId == null) return;
    await _recipeController.saveRecipe(recipe.copyWith(typeId: savedTypeId));
  }
}
