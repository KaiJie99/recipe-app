import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/recipe.dart';
import 'recipe_controller.dart';
import 'recipe_editor_page.dart';
import 'widgets/recipe_image.dart';

class RecipeDetailPage extends StatefulWidget {
  const RecipeDetailPage({super.key, required this.recipe});

  final Recipe recipe;

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  late Recipe _recipe;
  late RecipeController _controller;

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe;
    _controller = Get.find<RecipeController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe details'),
        actions: [
          IconButton(
            tooltip: 'Edit recipe',
            onPressed: _editRecipe,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Delete recipe',
            onPressed: () => _confirmDelete(context),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final imageHeight = (constraints.maxWidth * 0.58).clamp(210.0, 360.0);
          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: imageHeight,
                      child: RecipeImage(imagePath: _recipe.imagePath),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 22, 22, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _typeName.toUpperCase(),
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _recipe.title,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _recipe.description,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 18),
                          Chip(
                            avatar: const Icon(
                              Icons.schedule_rounded,
                              size: 18,
                            ),
                            label: Text('${_recipe.prepMinutes} minutes'),
                          ),
                          const SizedBox(height: 18),
                          _sectionTitle(context, 'Ingredients'),
                          const SizedBox(height: 8),
                          ..._recipe.ingredients.map(
                            (ingredient) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 20,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(ingredient)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          _sectionTitle(context, 'Preparation'),
                          const SizedBox(height: 8),
                          ..._recipe.steps.asMap().entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    child: Text('${entry.key + 1}'),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(entry.value),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) => Text(
    title,
    style: Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
  );

  String get _typeName {
    for (final type in _controller.recipeTypes) {
      if (type.id == _recipe.typeId) return type.name;
    }
    return 'Recipe';
  }

  Future<void> _editRecipe() async {
    final updated = await Get.to<Recipe>(
      () => RecipeEditorPage(recipe: _recipe),
    );
    if (updated != null && mounted) {
      setState(() => _recipe = updated);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete recipe?'),
        content: Text(
          '“${_recipe.title}” will be removed from your collection.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      await _controller.deleteRecipe(_recipe);
    }
  }
}
