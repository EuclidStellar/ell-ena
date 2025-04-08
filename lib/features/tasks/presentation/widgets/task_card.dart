import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ellena/core/constants/colors.dart';
import 'package:ellena/core/constants/text_styles.dart';
import 'package:ellena/core/models/task.dart';
import 'package:ellena/core/utils/date_utils.dart';
import 'package:ellena/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:ellena/features/tasks/presentation/bloc/task_event.dart';
import 'package:ellena/features/tasks/presentation/pages/task_detail_page.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailPage(taskId: task.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox for task completion
              Transform.scale(
                scale: 1.1,
                child: Checkbox(
                  value: task.isDone,
                  activeColor: AppColors.primary,
                  shape: const CircleBorder(),
                  onChanged: (_) {
                    context.read<TaskBloc>().add(ToggleTaskStatus(task.id));
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Task content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task title
                    Text(
                      task.title,
                      style: AppTextStyles.titleMedium.copyWith(
                        decoration: task.isDone ? TextDecoration.lineThrough : null,
                        color: task.isDone ? AppColors.textSecondary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Task metadata row
                    Row(
                      children: [
                        // Task type chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getTaskTypeColor(task.type).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getTaskTypeIcon(task.type),
                                size: 12,
                                color: _getTaskTypeColor(task.type),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                task.typeLabel,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: _getTaskTypeColor(task.type),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Priority chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: task.priorityColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getPriorityLabel(task.priority),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: task.priorityColor,
                            ),
                          ),
                        ),
                        // Due date, if available
                        if (task.dueDate != null) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
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
                    // Task description preview, if available
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        task.description,
                        style: AppTextStyles.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    // Task tags, if available
                    if (task.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: task.tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              // Forward icon
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

  Color _getTaskTypeColor(TaskType type) {
    switch (type) {
      case TaskType.todo:
        return AppColors.primary;
      case TaskType.ticket:
        return AppColors.accent;
      case TaskType.meetingNote:
        return Colors.orange;
    }
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

  bool _isOverdue(DateTime dueDate) {
    final now = DateTime.now();
    return dueDate.isBefore(now) && 
           !(dueDate.year == now.year && dueDate.month == now.month && dueDate.day == now.day);
  }
}