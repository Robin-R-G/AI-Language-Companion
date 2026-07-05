// lib/features/home/presentation/controllers/home_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/dashboard_remote_datasource.dart';
import '../../data/repositories/dashboard_repository_impl.dart';

part 'home_controller.g.dart';

@riverpod
DashboardRepository dashboardRepository(DashboardRepositoryRef ref) {
  return DashboardRepositoryImpl();
}

@riverpod
class HomeController extends _$HomeController {
  @override
  AsyncValue<DashboardData?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> loadDashboard() async {
    state = const AsyncValue.loading();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      state = const AsyncValue.error('Not authenticated', StackTrace.empty);
      return;
    }

    final repository = ref.read(dashboardRepositoryProvider);
    final result = await repository.getDashboard(userId);

    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (data) => state = AsyncValue.data(data),
    );
  }
}
