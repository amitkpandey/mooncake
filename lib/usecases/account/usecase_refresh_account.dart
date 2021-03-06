import 'package:meta/meta.dart';
import 'package:mooncake/usecases/usecases.dart';

/// Allows to easily refresh the account.
class RefreshAccountUseCase {
  UserRepository _userRepository;

  RefreshAccountUseCase({
    @required UserRepository userRepository,
  })  : assert(userRepository != null),
        _userRepository = userRepository;

  /// Refreshes the account an emits any new change using the proper stream.
  Future<void> refresh() {
    return _userRepository.refreshAccount();
  }
}
