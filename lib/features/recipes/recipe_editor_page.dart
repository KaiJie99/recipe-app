import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/recipe.dart';
import 'recipe_controller.dart';
import 'widgets/recipe_image.dart';

class RecipeEditorPage extends StatefulWidget {
  const RecipeEditorPage({super.key, this.recipe});

  final Recipe? recipe;

  @override
  State<RecipeEditorPage> createState() => _RecipeEditorPageState();
}

class _RecipeEditorPageState extends State<RecipeEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _stepsController = TextEditingController();
  final _minutesController = TextEditingController();
  late final RecipeController _controller;
  late int _typeId;
  late String _imagePath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<RecipeController>();
    final recipe = widget.recipe;
    _typeId =
        recipe?.typeId ??
        (_controller.recipeTypes.isEmpty
            ? 1
            : _controller.recipeTypes.first.id);
    _imagePath = recipe?.imagePath ?? '';
    _titleController.text = recipe?.title ?? '';
    _descriptionController.text = recipe?.description ?? '';
    _ingredientsController.text = recipe?.ingredients.join('\n') ?? '';
    _stepsController.text = recipe?.steps.join('\n') ?? '';
    _minutesController.text = recipe?.prepMinutes.toString() ?? '20';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _stepsController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe == null ? 'New recipe' : 'Edit recipe'),
      ),
      body: _controller.recipeTypes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final contentWidth = constraints.maxWidth > 720
                      ? 680.0
                      : constraints.maxWidth;
                  return Center(
                    child: SizedBox(
                      width: contentWidth,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                        children: [
                          _buildImagePicker(context),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _titleController,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              labelText: 'Recipe name',
                              prefixIcon: Icon(Icons.edit_note_rounded),
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Enter a recipe name'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<int>(
                            initialValue: _typeId,
                            decoration: const InputDecoration(
                              labelText: 'Recipe type',
                              prefixIcon: Icon(Icons.category_outlined),
                            ),
                            items: _controller.recipeTypes
                                .map(
                                  (type) => DropdownMenuItem<int>(
                                    value: type.id,
                                    child: Text(type.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _typeId = value);
                              }
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _descriptionController,
                            minLines: 2,
                            maxLines: 4,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              labelText: 'Short description',
                              alignLabelWithHint: true,
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Add a short description'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _minutesController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Preparation time (minutes)',
                              prefixIcon: Icon(Icons.schedule_rounded),
                            ),
                            validator: (value) {
                              final minutes = int.tryParse(value ?? '');
                              return minutes == null || minutes < 1
                                  ? 'Enter a number greater than zero'
                                  : null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _listField(
                            controller: _ingredientsController,
                            label: 'Ingredients',
                            hint: 'Add one ingredient per line',
                            icon: Icons.shopping_basket_outlined,
                          ),
                          const SizedBox(height: 14),
                          _listField(
                            controller: _stepsController,
                            label: 'Preparation steps',
                            hint: 'Add one step per line, in order',
                            icon: Icons.format_list_numbered_rounded,
                          ),
                          const SizedBox(height: 22),
                          FilledButton.icon(
                            onPressed: _isSaving ? null : _save,
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save_outlined),
                            label: Text(
                              widget.recipe == null
                                  ? 'Save recipe'
                                  : 'Save changes',
                            ),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildImagePicker(BuildContext context) => SizedBox(
    height: 210,
    child: Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: RecipeImage(imagePath: _imagePath),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton.tonalIcon(
              onPressed: _chooseImage,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(_imagePath.isEmpty ? 'Add photo' : 'Change photo'),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _listField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) => TextFormField(
    controller: controller,
    minLines: 4,
    maxLines: 8,
    textCapitalization: TextCapitalization.sentences,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      alignLabelWithHint: true,
      prefixIcon: Padding(
        padding: const EdgeInsets.only(bottom: 54),
        child: Icon(icon),
      ),
    ),
    validator: (value) {
      if (value == null ||
          value.split('\n').every((line) => line.trim().isEmpty)) {
        return 'Add at least one ${label.toLowerCase()} item';
      }
      return null;
    },
  );

  Future<void> _chooseImage() async {
    final imagePath = await _controller.pickAndStoreImage();
    if (imagePath != null && mounted) {
      setState(() => _imagePath = imagePath);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final recipe = Recipe(
      id: widget.recipe?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      typeId: _typeId,
      imagePath: _imagePath,
      ingredients: _lines(_ingredientsController.text),
      steps: _lines(_stepsController.text),
      prepMinutes: int.parse(_minutesController.text.trim()),
    );
    final saved = await _controller.saveRecipe(recipe);
    if (mounted) {
      setState(() => _isSaving = false);
      if (saved) {
        if (widget.recipe == null) {
          Get.back<void>();
        } else {
          Get.back<Recipe>(result: recipe);
        }
      }
    }
  }

  List<String> _lines(String text) => text
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
}
