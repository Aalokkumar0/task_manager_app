import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../widgets/custom_text_field.dart';

class CreateEditTaskScreen extends ConsumerStatefulWidget {
  final TaskModel? task; // null = create mode

  const CreateEditTaskScreen({super.key, this.task});

  @override
  ConsumerState<CreateEditTaskScreen> createState() =>
      _CreateEditTaskScreenState();
}

class _CreateEditTaskScreenState extends ConsumerState<CreateEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _dateCtrl;
  late TaskStatus _selectedStatus;
  late DateTime _selectedDate;
  bool _saving = false;

  bool get _isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleCtrl = TextEditingController(text: task?.title ?? '');
    _descCtrl = TextEditingController(text: task?.description ?? '');
    _selectedStatus = task?.status ?? TaskStatus.todo;
    _selectedDate =
        task?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    _dateCtrl = TextEditingController(
      text: DateFormat('MMM dd, yyyy').format(_selectedDate),
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateCtrl.text = DateFormat('MMM dd, yyyy').format(picked);
      });
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    try {
      final task = TaskModel(
        id: widget.task?.id ?? '',
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        status: _selectedStatus,
        dueDate: _selectedDate,
      );

      if (_isEdit) {
        await ref.read(tasksProvider.notifier).editTask(task);
      } else {
        await ref.read(tasksProvider.notifier).addTask(task);
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Task' : 'New Task')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  controller: _titleCtrl,
                  label: 'Title',
                  hint: 'What needs to be done?',
                  prefixIcon: const Icon(Icons.title),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Title is required';
                    }
                    if (v.trim().length < 3) return 'At least 3 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _descCtrl,
                  label: 'Description',
                  hint: 'Add more details…',
                  maxLines: 4,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 56),
                    child: Icon(Icons.notes),
                  ),
                ),
                const SizedBox(height: 16),

                // Status Dropdown
                DropdownButtonFormField<TaskStatus>(
                  initialValue: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    prefixIcon: const Icon(Icons.flag_outlined),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                  items: TaskStatus.values
                      .map(
                        (s) => DropdownMenuItem(value: s, child: Text(s.label)),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedStatus = v);
                  },
                ),
                const SizedBox(height: 16),

                // Date Picker
                CustomTextField(
                  controller: _dateCtrl,
                  label: 'Due Date',
                  readOnly: true,
                  onTap: _pickDate,
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Due date is required';
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(_isEdit ? 'Save Changes' : 'Create Task'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
