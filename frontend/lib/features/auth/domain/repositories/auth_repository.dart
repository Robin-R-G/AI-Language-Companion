import '../../../../core/errors/result.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Result<AppUser>> signUp(String email, String password);
  Future<Result<AppUser>> signIn(String email, String password);
  Future<Result<void>> signOut();
  AppUser? get currentUser;
  Stream<bool> get authStateChanges;
}
