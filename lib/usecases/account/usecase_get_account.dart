import 'package:meta/meta.dart';
import 'package:mooncake/entities/entities.dart';
import 'package:mooncake/usecases/usecases.dart';

/// Allows to retrieve the current user of the application.
class GetAccountUseCase {
  final UserRepository _userRepository;

  GetAccountUseCase({@required UserRepository userRepository})
      : this._userRepository = userRepository;

  /// Returns the current user of the application.
  Future<MooncakeAccount> single() {
    return _userRepository.getAccount();
  }

  /// Returns all accounts of the application.
  Future<List<MooncakeAccount>> all() {
    return _userRepository.getAccounts();
  }

  /// Returns the [Stream] that emits all the [MooncakeAccount] objects
  /// as soon as they are stored.
  Stream<MooncakeAccount> stream() {
    return _userRepository.accountStream;
  }
}
