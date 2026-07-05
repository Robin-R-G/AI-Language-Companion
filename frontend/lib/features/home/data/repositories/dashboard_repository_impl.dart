// lib/features/home/data/repositories/dashboard_repository_impl.dart
import '../../../../core/errors/result.dart';
import '../datasources/dashboard_remote_datasource.dart';

abstract class DashboardRepository {
  Future<Result<DashboardData>> getDashboard(String userId);
}

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;

  DashboardRepositoryImpl({DashboardRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? DashboardRemoteDataSourceImpl();

  @override
  Future<Result<DashboardData>> getDashboard(String userId) {
    return _remoteDataSource.getDashboard(userId);
  }
}
