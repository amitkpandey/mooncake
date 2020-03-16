import 'package:equatable/equatable.dart';

/// Represents a generic event that is emitted from the
abstract class SetPasswordEvent extends Equatable {
  const SetPasswordEvent();

  @override
  List<Object> get props => [];
}

/// Tells the Bloc that the user has input a different password to be used.
class PasswordChanged extends SetPasswordEvent {
  final String newPassword;

  PasswordChanged(this.newPassword);

  @override
  List<Object> get props => [newPassword];

  @override
  String toString() => 'PasswordChanged { newPassword: $newPassword }';
}

/// Tells the Bloc to invert the current password visibility.
class TriggerPasswordVisibility extends SetPasswordEvent {
  @override
  String toString() => 'TriggerPasswordVisibility';
}
