import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ellena/core/constants/colors.dart';
import 'package:ellena/core/constants/text_styles.dart';
import 'package:ellena/core/models/task.dart';
import 'package:ellena/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:ellena/features/tasks/presentation/bloc/task_event.dart';
import 'package:ellena/features/tasks/presentation/bloc/task_state.dart';
import 'package:ellena/features/tasks/presentation/widgets/task_card.dart';
import 'package:ellena/features/chat/presentation/pages/chat_page.dart';

class TaskListPage extends StatelessWidget {
  final TaskType? initialFilter;

  const TaskListPage({
    Key? key,
    this.initialFilter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TaskBloc()..add(LoadTasks(filterType: initialFilter)),
      child: _TaskListView(initialFilter: initialFilter),
    );
  }
}

class _TaskListView extends StatefulWidget {
  final TaskType? initialFilter;

  const _TaskListView({
    Key? key,
    this.initialFilter,
  }) : super(key: key);

  @override
  State<_TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<_TaskListView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TaskType? _currentFilter;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.initialFilter;
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: _getInitialTabIndex(),
    );
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentFilter = _getFilterFromIndex(_tabController.index);
      });
      context.read<TaskBloc>().add(LoadTasks(filterType: _currentFilter));
    }
  }

  int _getInitialTabIndex() {
    if (widget.initialFilter == null) return 0;
    switch (widget.initialFilter!) {
      case TaskType.todo:
        return 1;
      case TaskType.ticket:
        return 2;
      case TaskType.meetingNote:
        return 3;
      default:
        return 0;
    }
  }

  TaskType? _getFilterFromIndex(int index) {
    switch (index) {
      case 0:
        return null; // All tasks
      case 1:
        return TaskType.todo;
      case 2:
        return TaskType.ticket;
      case 3:
        return TaskType.meetingNote;
      default:
        return null;
    }
  }

  String _getTabTitle(int index) {
    switch (index) {
      case 0:
        return 'All';
      case 1:
        return 'To-Do';
      case 2:
        return 'Tickets';
      case 3:
        return 'Meetings';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tasks',
          style: AppTextStyles.titleLarge,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: List.generate(
            4,
            (index) => Tab(text: _getTabTitle(index)),
          ),
        ),
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TasksError) {
            return _buildErrorView(context, state.message);
          } else if (state is TasksLoaded) {
            return _buildTaskList(context, state.tasks);
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to chat to create a new task
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatPage()),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
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
            'Error loading tasks',
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
              context.read<TaskBloc>().add(LoadTasks(filterType: _currentFilter));
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, List<Task> tasks) {
    if (tasks.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<TaskBloc>().add(LoadTasks(filterType: _currentFilter));
      },
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: tasks.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskCard(task: task);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    String actionText;
    IconData icon;

    if (_currentFilter == null) {
      message = "You don't have any tasks yet";
      actionText = "Create your first task";
      icon = Icons.task_outlined;
    } else {
      switch (_currentFilter!) {
        case TaskType.todo:
          message = "You don't have any to-do items";
          actionText = "Create a to-do";
          icon = Icons.check_circle_outline;
          break;
        case TaskType.ticket:
          message = "You don't have any tickets";
          actionText = "Create a ticket";
          icon = Icons.confirmation_number_outlined;
          break;
        case TaskType.meetingNote:
          message = "You don't have any meeting notes";
          actionText = "Create a meeting note";
          icon = Icons.event_note_outlined;
          break;
      }
    }

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 72,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatPage()),
                );
              },
              icon: const Icon(Icons.add),
              label: Text(actionText),
            ),
          ],
        ),
      ),
    );
  }
}