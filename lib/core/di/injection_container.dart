import 'package:ellena/core/services/ai_service.dart';
import 'package:ellena/core/services/local_storage_service.dart';
import 'package:ellena/core/services/task_service.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // Services
  sl.registerLazySingleton<LocalStorageService>(() => LocalStorageService(sl()));
  sl.registerLazySingleton<AIService>(() => AIService());
  sl.registerLazySingleton<TaskService>(() => TaskService(sl()));
}