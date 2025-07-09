
import '../entities/user.dart';
import '../repositories/startup_repository.dart';

class GetProfileUseCase {
  final StartupRepository repository;

  GetProfileUseCase(this.repository);

  Future<User> call() async {
    return await repository.getProfile();
  }
}
