// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:nawy_ai_app/app/core/injection/injection_module.dart' as _i237;
import 'package:nawy_ai_app/app/core/services/auth_service.dart' as _i292;
import 'package:nawy_ai_app/app/core/utils/app_logger.dart' as _i642;
import 'package:nawy_ai_app/app/core/utils/dio_client.dart' as _i420;
import 'package:nawy_ai_app/app/core/utils/hive_service.dart' as _i38;
import 'package:nawy_ai_app/app/features/ai_assistant/domain/ai_service.dart'
    as _i994;
import 'package:nawy_ai_app/app/features/favorites/data/favorites_repository.dart'
    as _i641;
import 'package:nawy_ai_app/app/features/favorites/data/sources/local/favorites_local_source.dart'
    as _i667;
import 'package:nawy_ai_app/app/features/favorites/presentation/bloc/favorites_bloc.dart'
    as _i378;
import 'package:nawy_ai_app/app/features/property_search/domain/property_search_repository.dart'
    as _i737;
import 'package:nawy_ai_app/app/features/property_search/presentation/bloc/property_search_bloc.dart'
    as _i288;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final injectionModule = _$InjectionModule();
    await gh.singletonAsync<_i38.HiveService>(
      () => injectionModule.hiveService,
      preResolve: true,
    );
    await gh.singletonAsync<_i642.AppLogger>(
      () => injectionModule.appLogger,
      preResolve: true,
    );
    gh.singleton<_i292.AuthService>(() => _i292.AuthService());
    gh.singleton<_i994.AiService>(() => _i994.AiService());
    gh.singleton<_i737.PropertySearchRepository>(
      () => _i737.PropertySearchRepository(),
    );
    gh.singleton<_i420.DioClient>(() => _i420.DioClient(gh<_i642.AppLogger>()));
    gh.factory<_i288.PropertySearchBloc>(
      () => _i288.PropertySearchBloc(gh<_i737.PropertySearchRepository>()),
    );
    gh.factory<_i667.FavoritesLocalSource>(
      () => _i667.FavoritesLocalSource(gh<_i38.HiveService>()),
    );
    gh.singleton<_i641.FavoritesRepository>(
      () => _i641.FavoritesRepository(gh<_i667.FavoritesLocalSource>()),
    );
    gh.factory<_i378.FavoritesBloc>(
      () => _i378.FavoritesBloc(
        gh<_i641.FavoritesRepository>(),
        gh<_i642.AppLogger>(),
      ),
    );
    return this;
  }
}

class _$InjectionModule extends _i237.InjectionModule {}
