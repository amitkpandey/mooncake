import 'package:equatable/equatable.dart';

/// Represents a generic event that is emitted regarding the biometric screen.
abstract class BiometricsEvent extends Equatable {
  const BiometricsEvent();

  @override
  List<Object> get props => [];
}

/// Tells the BLoC that the user wants to be authenticated.
class AuthenticateWithBiometrics extends BiometricsEvent {
  @override
  String toString() => 'Authenticate';
}
