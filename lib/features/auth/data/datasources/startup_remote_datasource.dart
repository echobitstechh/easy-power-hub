
import 'package:wahala_hq/features/startup/data/models/user_dto.dart';

import '../../../../core/network/interceptors.dart';

abstract class StartupRemoteDataSource {
  Future<UserDto> getProfile();
}

class StartupRemoteDataSourceImpl implements StartupRemoteDataSource {
  @override
  Future<UserDto> getProfile() async {
    final res = await repo.getProfile();
    if (res.statusCode == 200) {
      return UserDto.fromJson(Map<String, dynamic>.from(res.data['data']));
    } else {
      throw Exception("Failed to fetch profile");
    }
  }
}
