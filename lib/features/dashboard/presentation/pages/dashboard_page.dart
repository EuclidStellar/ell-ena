import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ellena/core/constants/app_constants.dart';
import 'package:ellena/core/constants/colors.dart';
import 'package:ellena/core/constants/text_styles.dart';
import 'package:ellena/core/models/task.dart';
import 'package:ellena/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:ellena/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:ellena/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:ellena/features/dashboard/presentation/widgets/summary_card.dart';
import 'package:ellena/features/dashboard/presentation/widgets/task_list.dart';
import 'package:ellena/features/tasks/presentation/pages/task_list_page.dart';
import 'package:ellena/features/chat/presentation/pages/chat_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardBloc()..add(LoadDashboard()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: AppTextStyles.titleLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DashboardBloc>().add(RefreshDashboard());
            },
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DashboardError) {
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
                    'Error loading dashboard',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DashboardBloc>().add(RefreshDashboard());
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          } else if (state is DashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(RefreshDashboard());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeHeader(context),
                    const SizedBox(height: 24),
                    _buildSummaryCards(context, state),
                    const SizedBox(height: 24),
                    Text(
                      'Recent Tasks',
                      style: AppTextStyles.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    TaskList(
                      tasks: state.recentTasks,
                      title: '',
                      emptyMessage: 'No recent tasks. Create a new task to get started.',
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Upcoming Tasks',
                      style: AppTextStyles.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    TaskList(
                      tasks: state.upcomingTasks,
                      title: '',
                      emptyMessage: 'No upcoming tasks with due dates.',
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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

  Widget _buildWelcomeHeader(BuildContext context) {
    final now = DateTime.now();
    String greeting;
    
    if (now.hour < 12) {
      greeting = 'Good morning';
    } else if (now.hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: AppTextStyles.displaySmall,
        ),
        const SizedBox(height: 8),
        Text(
          'What would you like to do today?',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(BuildContext context, DashboardLoaded state) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'To-Do',
                count: state.todoCount,
                icon: Icons.check_circle_outline,
                color: AppColors.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TaskListPage(
                        initialFilter: TaskType.todo,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SummaryCard(
                title: 'Tickets',
                count: state.ticketCount,
                icon: Icons.confirmation_number_outlined,
                color: AppColors.accent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TaskListPage(
                        initialFilter: TaskType.ticket,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Meeting Notes',
                count: state.meetingNoteCount,
                icon: Icons.event_note_outlined,
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TaskListPage(
                        initialFilter: TaskType.meetingNote,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SummaryCard(
                title: 'Chat with Ell-ena',
                count: -1, // No count displayed
                icon: Icons.chat_outlined,
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}