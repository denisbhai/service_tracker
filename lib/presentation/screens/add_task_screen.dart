// lib/presentation/screens/add_task_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_theme.dart';
import '../../core/di/service_locator.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/entities/task_entity.dart';
import '../blocs/add_task/add_task_bloc.dart';
import '../widgets/error_view.dart';

class AddTaskScreen extends StatelessWidget {
  const AddTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddTaskBloc(createTaskUseCase: sl()),
      child: const _AddTaskView(),
    );
  }
}

class _AddTaskView extends StatefulWidget {
  const _AddTaskView();

  @override
  State<_AddTaskView> createState() => _AddTaskViewState();
}

class _AddTaskViewState extends State<_AddTaskView> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddTaskBloc, AddTaskState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == AddTaskStatus.success && state.createdTask != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Task created successfully!'),
                ],
              ),
              backgroundColor: AppTheme.completedColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
          Navigator.of(context).pop(state.createdTask);
        }
      },
      builder: (context, state) {
        final isSubmitting = state.status == AddTaskStatus.submitting;

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: const Text('New Task'),
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Error banner
                  if (state.status == AddTaskStatus.failure &&
                      state.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ErrorBanner(message: state.errorMessage!),
                    ),

                  _SectionLabel(label: 'Title'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Inspect Unit 4B HVAC System',
                      prefixIcon: Icon(Icons.title_rounded,
                          size: 20, color: AppTheme.textMuted),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Title is required';
                      }
                      if (v.trim().length < 5) {
                        return 'Title must be at least 5 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  _SectionLabel(label: 'Description'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText:
                          'Describe the task scope, tools needed, or any special instructions...',
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 60),
                        child: Icon(Icons.notes_rounded,
                            size: 20, color: AppTheme.textMuted),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Description is required';
                      }
                      if (v.trim().length < 10) {
                        return 'Please provide a more detailed description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  _SectionLabel(label: 'Priority'),
                  const SizedBox(height: 8),
                  _PrioritySelector(selectedPriority: state.selectedPriority),
                  const SizedBox(height: 20),

                  _SectionLabel(label: 'Due Date'),
                  const SizedBox(height: 8),
                  _DueDatePicker(selectedDate: state.selectedDueDate),
                  const SizedBox(height: 32),

                  ElevatedButton.icon(
                    onPressed: isSubmitting ? null : () => _submit(context),
                    icon: isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.add_task_rounded, size: 20),
                    label: Text(
                      isSubmitting ? 'Creating Task...' : 'Create Task',
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    context.read<AddTaskBloc>().add(
          AddTaskSubmitted(
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim(),
          ),
        );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
    );
  }
}

class _PrioritySelector extends StatelessWidget {
  final TaskPriority selectedPriority;

  const _PrioritySelector({required this.selectedPriority});

  static const _priorities = TaskPriority.values;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _priorities.map((p) {
        final isSelected = p == selectedPriority;
        final color = _color(p);
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: p != _priorities.last ? 8 : 0,
            ),
            child: GestureDetector(
              onTap: () =>
                  context.read<AddTaskBloc>().add(AddTaskPriorityChanged(p)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.12) : AppTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? color : AppTheme.divider,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _icon(p),
                      size: 18,
                      color: isSelected ? color : AppTheme.textMuted,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? color : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _color(TaskPriority p) {
    switch (p) {
      case TaskPriority.low:
        return AppTheme.lowColor;
      case TaskPriority.medium:
        return AppTheme.mediumColor;
      case TaskPriority.high:
        return AppTheme.highColor;
      case TaskPriority.critical:
        return AppTheme.criticalColor;
    }
  }

  IconData _icon(TaskPriority p) {
    switch (p) {
      case TaskPriority.low:
        return Icons.arrow_downward_rounded;
      case TaskPriority.medium:
        return Icons.remove_rounded;
      case TaskPriority.high:
        return Icons.arrow_upward_rounded;
      case TaskPriority.critical:
        return Icons.priority_high_rounded;
    }
  }
}

class _DueDatePicker extends StatelessWidget {
  final DateTime selectedDate;

  const _DueDatePicker({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded,
                size: 20, color: AppTheme.textMuted),
            const SizedBox(width: 12),
            Text(
              AppDateUtils.toFullDate(selectedDate),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                size: 20, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null && context.mounted) {
      context.read<AddTaskBloc>().add(AddTaskDueDateChanged(picked));
    }
  }
}
