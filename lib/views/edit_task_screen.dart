import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import '../models/task_model.dart';

class EditTaskScreen extends GetView<TaskController> {
  final Task task;

  EditTaskScreen({Key? key, required this.task}) : super(key: key);

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _hasChanges = false.obs;

  @override
  Widget build(BuildContext context) {
    _titleController.text = task.title;
    _descriptionController.text = task.description;

    _titleController.addListener(_checkForChanges);
    _descriptionController.addListener(_checkForChanges);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: Text(
            'Edit Task',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => _onWillPop().then((canPop) {
              if (canPop) Get.back();
            }),
          ),
          actions: [
            Obx(() => IconButton(
                  icon: Icon(Icons.check),
                  onPressed: _hasChanges.value ? _submitForm : null,
                  color: _hasChanges.value
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                )),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Task title',
                      prefixIcon: Icon(
                        Icons.task_alt,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      hintText: 'Description (optional)',
                      prefixIcon: Icon(
                        Icons.description,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 24),
                  Obx(() => ElevatedButton(
                        onPressed: _hasChanges.value ? _submitForm : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _checkForChanges() {
    _hasChanges.value = _titleController.text != task.title ||
        _descriptionController.text != task.description;
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges.value) return true;

    final result = await showDialog<bool>(
      context: Get.context!,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Discard Changes?'),
        content: Text('You have unsaved changes. Do you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Discard',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      controller.updateTask(
        id: task.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
      );
    }
  }
}
