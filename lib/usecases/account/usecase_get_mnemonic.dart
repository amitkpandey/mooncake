import 'package:meta/meta.dart';
import 'package:mooncake/usecases/usecases.dart';

/// Allows to easily get the mnemonic that is currently stored inside the
/// user device.
/// Please note that this use case exposes a highly secret information, so
/// it should not be used unless the user has been asked explicit consent first.
class GetMnemonicUseCase {
  final UserRepository _userRepository;

  GetMnemonicUseCase({
    @required UserRepository userRepository,
  })  : assert(userRepository != null),
        _userRepository = userRepository;

  /// Returns the mnemonic phrase of the current user.
  Future<List<String>> get() {
    return _userRepository.getMnemonic();
  }
}
