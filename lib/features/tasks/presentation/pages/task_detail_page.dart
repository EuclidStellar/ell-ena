import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ellena/core/constants/colors.dart';
import 'package:ellena/core/constants/text_styles.dart';
import 'package:ellena/core/models/task.dart';
import 'package:ellena/core/utils/date_utils.dart';
import 'package:ellena/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:ellena/features/tasks/presentation/bloc/task_event.dart';
import 'package:ellena/features/tasks/presentation/bloc/task_state.dart';


class TaskDetailPage extends StatelessWidget {
  final String taskId;

  const TaskDetailPage({
    Key? key,
    required this.taskId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TaskBloc()..add(LoadTaskDetail(taskId)),
      child: TaskDetailView(taskId: taskId),
    );
  }
}

class TaskDetailView extends StatelessWidget {
  final String taskId;

  const TaskDetailView({
    Key? key,
    required this.taskId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Task Details',
          style: AppTextStyles.titleLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskDeleted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Task deleted')),
            );
          }
        },
        builder: (context, state) {
          if (state is TaskDetailLoading || state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TaskDetailError) {
            return _buildErrorView(context, state.message);
          } else if (state is TaskDetailLoaded) {
            return _buildTaskDetail(context, state.task, state.relatedTasks);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<TaskBloc>().add(LoadTaskDetail(taskId));
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskDetail(BuildContext context, Task task, List<Task> relatedTasks) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: task.priorityColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: AppTextStyles.headlineSmall.copyWith(
                              decoration: task.isDone ? TextDecoration.lineThrough : null,
                              color: task.isDone ? AppColors.textSecondary : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Checkbox(
                          value: task.isDone,
                          activeColor: AppColors.primary,
                          onChanged: (_) => ToggleTaskDone(task.id, context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _getTaskTypeIcon(task.type),
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task.typeLabel,
                          style: AppTextStyles.labelSmall,
                        ),
                        if (task.dueDate != null) ...[
                          const SizedBox(width: 12),
                          const VerticalDivider(
                            width: 1,
                            thickness: 1,
                            color: AppColors.divider,
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: _isOverdue(task.dueDate!) 
                                ? AppColors.error
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppDateUtils.formatDate(task.dueDate!),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: _isOverdue(task.dueDate!)
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Priority
          const SizedBox(height: 24),
          Text(
            'Priority',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: task.priorityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: task.priorityColor),
            ),
            child: Text(
              _getPriorityLabel(task.priority),
              style: AppTextStyles.labelMedium.copyWith(
                color: task.priorityColor,
              ),
            ),
          ),
          
          // Description
          if (task.description.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Description',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                task.description,
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ],
          
          // Tags
          if (task.tags.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Tags',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: task.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    tag,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          
          // Related Tasks
          if (relatedTasks.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Related Tasks',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 8),
            ...relatedTasks.map((relatedTask) => _buildRelatedTaskItem(context, relatedTask)),
          ],
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildRelatedTaskItem(BuildContext context, Task task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          // Navigate to the related task
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailPage(taskId: task.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: task.priorityColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: AppTextStyles.titleSmall.copyWith(
                        decoration: task.isDone ? TextDecoration.lineThrough : null,
                        color: task.isDone ? AppColors.textSecondary : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.typeLabel,
                      style: AppTextStyles.labelSmall,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<TaskBloc>().add(DeleteTask(taskId));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void ToggleTaskDone(String taskId, BuildContext context) {
    context.read<TaskBloc>().add(ToggleTaskStatus(taskId));
  }

  IconData _getTaskTypeIcon(TaskType type) {
    switch (type) {
      case TaskType.todo:
        return Icons.check_circle_outline;
      case TaskType.ticket:
        return Icons.confirmation_number_outlined;
      case TaskType.meetingNote:
        return Icons.event_note_outlined;
    }
  }

  bool _isOverdue(DateTime dueDate) {
    final now = DateTime.now();
    return dueDate.isBefore(now) && 
           !(dueDate.year == now.year && dueDate.month == now.month && dueDate.day == now.day);
  }

  String _getPriorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }
}