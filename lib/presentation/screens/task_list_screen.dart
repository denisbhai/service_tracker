// lib/presentation/screens/task_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_theme.dart';
import '../../core/di/service_locator.dart';
import '../../domain/entities/task_entity.dart';
import '../blocs/task_list/task_list_bloc.dart';
import '../widgets/error_view.dart';
import '../widgets/task_card.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TaskListBloc(getTasksUseCase: sl())
        ..add(const TaskListFetched()),
      child: const _TaskListView(),
    );
  }
}

class _TaskListView extends StatelessWidget {
  const _TaskListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          BlocBuilder<TaskListBloc, TaskListState>(
            buildWhen: (prev, curr) => prev.status != curr.status,
            builder: (context, state) {
              if (state.status == TaskListStatus.success) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${state.allTasks.length}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () =>
                context.read<TaskListBloc>().add(const TaskListFetched()),
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterBar(),
          Expanded(child: _TaskBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddTask(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Task'),
      ),
    );
  }

  Future<void> _navigateToAddTask(BuildContext context) async {
    final bloc = context.read<TaskListBloc>();
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddTaskScreen()),
    );
    if (result is TaskEntity) {
      bloc.add(TaskListTaskCreated(result));
    }
  }
}

// ── Filter Bar ────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskListBloc, TaskListState>(
      buildWhen: (prev, curr) => prev.activeFilter != curr.activeFilter,
      builder: (context, state) {
        return Container(
          color: AppTheme.surface,
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'All',
                      isSelected: state.activeFilter == null,
                      onTap: () => context
                          .read<TaskListBloc>()
                          .add(const TaskListFilterChanged(null)),
                    ),
                    const SizedBox(width: 8),
                    ...TaskStatus.values.map((status) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _FilterChip(
                            label: status.label,
                            isSelected: state.activeFilter == status,
                            onTap: () => context
                                .read<TaskListBloc>()
                                .add(TaskListFilterChanged(status)),
                          ),
                        )),
                  ],
                ),
              ),
              const Divider(height: 1),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : AppTheme.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ── Task Body ─────────────────────────────────────────────────────────────────

class _TaskBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskListBloc, TaskListState>(
      builder: (context, state) {
        switch (state.status) {
          case TaskListStatus.initial:
          case TaskListStatus.loading:
            return const LoadingView(message: 'Loading tasks...');

          case TaskListStatus.failure:
            return ErrorView(
              message: state.errorMessage ?? 'Failed to load tasks.',
              onRetry: () =>
                  context.read<TaskListBloc>().add(const TaskListFetched()),
            );

          case TaskListStatus.success:
            if (state.filteredTasks.isEmpty) {
              return EmptyView(
                icon: state.activeFilter != null
                    ? Icons.filter_list_off_rounded
                    : Icons.task_alt_rounded,
                title: state.activeFilter != null
                    ? 'No ${state.activeFilter!.label} tasks'
                    : 'No tasks yet',
                subtitle: state.activeFilter != null
                    ? 'Try a different filter or add a new task.'
                    : 'Tap the button below to create your first task.',
              );
            }
            return _TaskList(tasks: state.filteredTasks);
        }
      },
    );
  }
}

class _TaskList extends StatelessWidget {
  final List<TaskEntity> tasks;

  const _TaskList({required this.tasks});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppTheme.primaryColor,
      onRefresh: () async =>
          context.read<TaskListBloc>().add(const TaskListFetched()),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 100),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskCard(
            task: task,
            onTap: () => _navigateToDetail(context, task),
          );
        },
      ),
    );
  }

  Future<void> _navigateToDetail(BuildContext context, TaskEntity task) async {
    final bloc = context.read<TaskListBloc>();
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TaskDetailScreen(task: task),
      ),
    );
    if (result is TaskEntity) {
      bloc.add(TaskListTaskUpdated(result));
    }
  }
}
