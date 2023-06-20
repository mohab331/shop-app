import 'package:dartz/dartz.dart';
import 'package:shop_app_clean_architecture/core/index.dart';
import 'package:shop_app_clean_architecture/shop/data/index.dart';
import 'package:shop_app_clean_architecture/shop/domain/index.dart';
import 'package:shop_app_clean_architecture/utils/index.dart';

class LocalStorageImpl implements BaseLocalStorageRepo {
  const LocalStorageImpl({
    required this.baseLocalDS,
    required this.userDataResponseMapper,
    required this.saveUserDataRequestMapper,
    required this.appThemeRequestMapper,
  });
  final BaseLocalDS baseLocalDS;
  final UserDataResponseMapper userDataResponseMapper;
  final SaveUserDataRequestMapper saveUserDataRequestMapper;
  final AppThemeRequestMapper appThemeRequestMapper;
  @override
  Future<Either<Failure, bool>> clearUserData() async {
    return await _execute(
      tryBlock: () async {
        await baseLocalDS.clearSavedUserData();
        return true;
      },
    );
  }

  @override
  Future<Either<Failure, AppThemeEnum>> getAppThemeMode() async {
    return await _execute(
      tryBlock: () async {
        final response = await baseLocalDS.getAppThemeMode();
        return response == null || !response
            ? AppThemeEnum.light
            : AppThemeEnum.dark;
      },
    );
  }

  @override
  Future<Either<Failure, bool>> getOnBoardingData() async {
    return await _execute(
      tryBlock: () async {
        final response = await baseLocalDS.getShowOnBoarding();
        return (response == null || response);
      },
    );
  }

  @override
  Future<Either<Failure, UserDataResponseEntity>> getUserData() async {
    return await _execute(
      tryBlock: () async {
        final response = await baseLocalDS.getUserData();
        return userDataResponseMapper.mapToEntity(
          model: response,
        );
      },
    );
  }

  @override
  Future<Either<Failure, bool>> setOnBoarding({
    required bool showOnBoarding,
  }) async {
    return await _execute(
      tryBlock: () async {
        await baseLocalDS.saveShowOnBoarding(
          data: showOnBoarding,
        );
        return true;
      },
    );
  }

  @override
  Future<Either<Failure, bool>> setUserData({
    required SaveUserDataRequestEntity saveUserDataRequestEntity,
  }) async {
    return await _execute(
      tryBlock: () async {
        await baseLocalDS.saveUserData(
          saveUserDataRequestModel: saveUserDataRequestMapper.mapToModel(
            entity: saveUserDataRequestEntity,
          ),
        );
        return true;
      },
    );
  }

  @override
  Future<Either<Failure, bool>> toggleAppTheme({
    required AppThemeRequestEntity appThemeRequestEntity,
  }) async {
    return await _execute(
      tryBlock: () async {
        await baseLocalDS.saveThemeMode(
          appThemeRequestModel: appThemeRequestMapper.mapToModel(
            entity: appThemeRequestEntity,
          ),
        );
        return appThemeRequestEntity.isDarkTheme.value;
      },
    );
  }

  Future<Either<Failure, T>> _execute<T>(
      {required Future<T> Function() tryBlock}) async {
    try {
      return Right(await tryBlock());
    } on Exception catch (error) {
      return Left(CacheFailure(
        failureMessage: error.toString(),
      ));
    }
  }
}
