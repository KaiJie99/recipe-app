import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/recipe.dart';
import 'online_recipes_page.dart';
import 'recipe_controller.dart';
import 'recipe_detail_page.dart';
import 'recipe_editor_page.dart';
import 'widgets/recipe_image.dart';

class RecipeListPage extends GetView<RecipeController> {
  const RecipeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recipe Book', style: TextStyle(fontWeight: FontWeight.w700)),
            Text(
              'Good food, made at home',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Find recipes online',
            onPressed: () => Get.to<void>(() => const OnlineRecipesPage()),
            icon: const Icon(Icons.travel_explore_rounded),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value != null &&
            controller.recipeTypes.isEmpty) {
          return _ErrorPanel(
            message: controller.errorMessage.value!,
            onRetry: controller.loadData,
          );
        }
        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Text(
                  'Your collection',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: DropdownButtonFormField<int?>(
                  initialValue: controller.selectedTypeId.value,
                  decoration: const InputDecoration(
                    labelText: 'Filter by recipe type',
                    prefixIcon: Icon(Icons.filter_list_rounded),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('All recipes'),
                    ),
                    ...controller.recipeTypes.map(
                      (type) => DropdownMenuItem<int?>(
                        value: type.id,
                        child: Text(type.name),
                      ),
                    ),
                  ],
                  onChanged: controller.filterByType,
                ),
              ),
              if (controller.errorMessage.value != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text(
                    controller.errorMessage.value!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              Expanded(
                child: controller.recipes.isEmpty
                    ? const _EmptyRecipes()
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = constraints.maxWidth >= 900
                              ? 3
                              : constraints.maxWidth >= 600
                              ? 2
                              : 1;
                          return GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  mainAxisExtent: 118,
                                ),
                            itemCount: controller.recipes.length,
                            itemBuilder: (context, index) {
                              final recipe = controller.recipes[index];
                              return _RecipeCard(
                                recipe: recipe,
                                typeName: _typeName(recipe.typeId),
                                onTap: () => Get.to<void>(
                                  () => RecipeDetailPage(recipe: recipe),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: Obx(
        () => FloatingActionButton.extended(
          onPressed: controller.recipeTypes.isEmpty
              ? null
              : () => Get.to<void>(() => const RecipeEditorPage()),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add recipe'),
        ),
      ),
    );
  }

  String _typeName(int id) {
    for (final type in controller.recipeTypes) {
      if (type.id == id) return type.name;
    }
    return 'Recipe';
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({
    required this.recipe,
    required this.typeName,
    required this.onTap,
  });

  final Recipe recipe;
  final String typeName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            SizedBox(
              width: 118,
              height: double.infinity,
              child: RecipeImage(imagePath: recipe.imagePath),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      typeName.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.7,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      recipe.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${recipe.prepMinutes} min  ·  ${recipe.ingredients.length} ingredients',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyRecipes extends StatelessWidget {
  const _EmptyRecipes();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.menu_book_rounded,
            size: 52,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'No recipes in this category yet',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          const Text('Add a recipe or choose another filter.'),
        ],
      ),
    ),
  );
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 44),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    ),
  );
}
