class RecipeType {
  const RecipeType({required this.id, required this.name});

  final int id;
  final String name;

  factory RecipeType.fromJson(Map<String, dynamic> json) =>
      RecipeType(id: json['id'] as int, name: json['name'] as String);
}

class Recipe {
  const Recipe({
    this.id,
    required this.title,
    required this.description,
    required this.typeId,
    required this.imagePath,
    required this.ingredients,
    required this.steps,
    required this.prepMinutes,
  });

  final int? id;
  final String title;
  final String description;
  final int typeId;
  final String imagePath;
  final List<String> ingredients;
  final List<String> steps;
  final int prepMinutes;

  Recipe copyWith({int? id, int? typeId}) => Recipe(
    id: id ?? this.id,
    title: title,
    description: description,
    typeId: typeId ?? this.typeId,
    imagePath: imagePath,
    ingredients: ingredients,
    steps: steps,
    prepMinutes: prepMinutes,
  );

  Map<String, Object?> toDatabase() => {
    'id': id,
    'title': title,
    'description': description,
    'type_id': typeId,
    'image_path': imagePath,
    'ingredients': ingredients.join('\n'),
    'steps': steps.join('\n'),
    'prep_minutes': prepMinutes,
  };

  factory Recipe.fromDatabase(Map<String, Object?> row) => Recipe(
    id: row['id'] as int,
    title: row['title'] as String,
    description: row['description'] as String,
    typeId: row['type_id'] as int,
    imagePath: row['image_path'] as String,
    ingredients: _splitLines(row['ingredients'] as String),
    steps: _splitLines(row['steps'] as String),
    prepMinutes: row['prep_minutes'] as int,
  );

  static List<String> _splitLines(String value) =>
      value.split('\n').where((line) => line.trim().isNotEmpty).toList();
}
