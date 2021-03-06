import 'package:equatable/equatable.dart';
import 'package:mooncake/entities/entities.dart';

/// Represents a generic event that is emitted during the login procedure.
abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object> get props => [];
}

/// Tells the block to check for the current user status to know if
/// he is already logged in or not.
class CheckStatus extends AccountEvent {
  @override
  String toString() => 'CheckStatus';
}

/// Tells the Bloc that a new account should be generated and properly stored
/// inside the local device. Once the account has been generated, the
/// [AccountGenerated] state should be emitted.
class GenerateAccount extends AccountEvent {
  @override
  String toString() => 'GenerateAccount';
}

/// Tells the bloc to log in the user showing him the home screen.
class LogIn extends AccountEvent {
  @override
  String toString() => 'LogIn';
}

/// Tells the Bloc that the user has forced a refresh of the account
class RefreshAccount extends AccountEvent {
  @override
  String toString() => 'RefreshAccount';
}

/// Tells the Bloc to refresh the currently saved account replacing it
/// with the new one.
class UserRefreshed extends AccountEvent {
  final MooncakeAccount user;

  UserRefreshed(this.user);

  @override
  List<Object> get props => [user];
}

/// Tells the Bloc to log out the user from the application.
class LogOut extends AccountEvent {
  @override
  String toString() => 'LogOut';
}
