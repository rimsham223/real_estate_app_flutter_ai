import 'package:injectable/injectable.dart';
import 'package:nawy_ai_app/app/core/utils/hive_service.dart';
import 'package:nawy_ai_app/app/core/utils/app_logger.dart';

@module
abstract class InjectionModule {
  @preResolve
  @singleton
  Future<HiveService> get hiveService async {
    final service = HiveService();
    await service.initialize();
    return service;
  }

  @preResolve
  @singleton
  Future<AppLogger> get appLogger async {
    final logger = AppLogger();
    logger.initialize();
    return logger;
  }
}
