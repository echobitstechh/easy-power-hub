
import '../entities/user.dart';

abstract class StartupRepository {
  Future<User> getProfile();
}
