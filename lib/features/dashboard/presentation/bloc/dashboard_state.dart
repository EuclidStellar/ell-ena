import 'package:equatable/equatable.dart';
import 'package:ellena/core/models/task.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();
  
  @override
  List<Object> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<Task> recentTasks;
  final int todoCount;
  final int ticketCount;
  final int meetingNoteCount;
  final List<Task> upcomingTasks;
  
  const DashboardLoaded({
    required this.recentTasks,
    required this.todoCount,
    required this.ticketCount,
    required this.meetingNoteCount,
    required this.upcomingTasks,
  });
  
  @override
  List<Object> get props => [
    recentTasks, 
    todoCount, 
    ticketCount, 
    meetingNoteCount, 
    upcomingTasks
  ];
}

class DashboardError extends DashboardState {
  final String message;
  
  const DashboardError({required this.message});
  
  @override
  List<Object> get props => [message];
}