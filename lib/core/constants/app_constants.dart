class AppConstants {
  // App info
  static const String appName = 'Ell-ena';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'AI-powered product manager';
  
  // Navigation routes
  static const String homeRoute = '/';
  static const String chatRoute = '/chat';
  static const String tasksRoute = '/tasks';
  static const String taskDetailRoute = '/tasks/detail';
  static const String createTaskRoute = '/tasks/create';
  static const String settingsRoute = '/settings';
  
  // App settings
  static const int maxChatHistory = 50;
  static const int chatHistoryThreshold = 40;
  
  // AI Service
  static const String defaultAIGreeting = "Hello! I'm Ell-ena, your AI product manager assistant. How can I help you today?";
  
  // Task defaults
  static const int defaultTasksPerPage = 20;
  
  // Animations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
}