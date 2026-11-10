import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'data/recipe_repository.dart';
import 'data/recipe_storage.dart';
import 'features/recipes/recipe_controller.dart';
import 'features/recipes/recipe_list_page.dart';
import 'network/meal_api.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RecipeApp());
}

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Recipe Book',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF376B4D),
          surface: const Color(0xFFFFFCF7),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFCF7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFCF7),
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      initialBinding: BindingsBuilder(() {
        final storage = RecipeStorage();
        Get.put(RecipeController(RecipeRepository(storage), MealApi.create()));
      }),
      home: const RecipeListPage(),
    );
  }
}
