import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ellena/core/models/task.dart';
import 'package:ellena/core/services/task_service.dart';
import 'package:ellena/core/di/injection_container.dart';
import 'package:ellena/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:ellena/features/dashboard/presentation/bloc/dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final TaskService _taskService = sl<TaskService>();
  
  DashboardBloc() : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
  }
  
  Future<void> _onLoadDashboard(LoadDashboard event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      final allTasks = await _taskService.getAllTasks();
      
      // Get task counts by type
      final todoCount = allTasks.where((task) => task.type == TaskType.todo).length;
      final ticketCount = allTasks.where((task) => task.type == TaskType.ticket).length;
      final meetingNoteCount = allTasks.where((task) => task.type == TaskType.meetingNote).length;
      
      // Get recent tasks (last 5)
      final recentTasks = allTasks
          .where((task) => !task.isDone)
          .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final recent = recentTasks.take(5).toList();
      
      // Get upcoming tasks (due soon)
      final now = DateTime.now();
      final upcomingTasks = allTasks
          .where((task) => 
            !task.isDone && 
            task.dueDate != null && 
            task.dueDate!.isAfter(now) && 
            task.dueDate!.difference(now).inDays <= 7
          )
          .toList()
          ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
      
      emit(DashboardLoaded(
        recentTasks: recent,
        todoCount: todoCount,
        ticketCount: ticketCount,
        meetingNoteCount: meetingNoteCount,
        upcomingTasks: upcomingTasks.take(5).toList(),
      ));
    } catch (e) {
      emit(DashboardError(message: e.toString()));
    }
  }
  
  Future<void> _onRefreshDashboard(RefreshDashboard event, Emitter<DashboardState> emit) async {
    add(LoadDashboard());
  }
}