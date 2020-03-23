import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:mooncake/dependency_injection/dependency_injection.dart';
import 'package:mooncake/entities/entities.dart';
import 'package:mooncake/ui/ui.dart';
import 'package:mooncake/usecases/usecases.dart';

/// Handles the login events and emits the proper state instances.
class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final GenerateMnemonicUseCase _generateMnemonicUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetAccountUseCase _getUserUseCase;
  final FirebaseAnalytics _analytics;

  final NavigatorBloc _navigatorBloc;

  StreamSubscription _accountSubscription;

  AccountBloc({
    @required GenerateMnemonicUseCase generateMnemonicUseCase,
    @required LogoutUseCase logoutUseCase,
    @required GetAccountUseCase getUserUseCase,
    @required NavigatorBloc navigatorBloc,
    @required FirebaseAnalytics analytics,
  })  : assert(generateMnemonicUseCase != null),
        _generateMnemonicUseCase = generateMnemonicUseCase,
        assert(logoutUseCase != null),
        _logoutUseCase = logoutUseCase,
        assert(getUserUseCase != null),
        _getUserUseCase = getUserUseCase,
        assert(navigatorBloc != null),
        _navigatorBloc = navigatorBloc,
        assert(analytics != null),
        _analytics = analytics {
    // Listen for account changes so that we know when to refresh
    _accountSubscription = _getUserUseCase.stream().listen((account) {
      add(Refresh(account));
    });
  }

  factory AccountBloc.create(BuildContext context) {
    return AccountBloc(
      generateMnemonicUseCase: Injector.get(),
      logoutUseCase: Injector.get(),
      getUserUseCase: Injector.get(),
      navigatorBloc: BlocProvider.of(context),
      analytics: Injector.get(),
    );
  }

  @override
  AccountState get initialState => Loading();

  @override
  Stream<AccountState> mapEventToState(AccountEvent event) async* {
    if (event is CheckStatus) {
      yield* _mapCheckStatusEventToState();
    } else if (event is GenerateAccount) {
      yield* _mapGenerateAccountEventToState();
    } else if (event is LogIn) {
      yield* _mapLogInEventToState(event);
    } else if (event is LogOut) {
      yield* _mapLogOutEventToState();
    } else if (event is Refresh) {
      yield* _mapRefreshEventToState(event);
    }
  }

  /// Checks the current user state, determining if it is logged in or not.
  /// After the check, either [LoggedIn] or [LoggedOut] are emitted.
  Stream<AccountState> _mapCheckStatusEventToState() async* {
    final account = await _getUserUseCase.single();
    if (account != null) {
      yield LoggedIn(account);
    } else {
      yield LoggedOut();
    }
  }

  /// Handle the [GenerateAccount] event, which is emitted when the user wants
  /// to create a new account. It creates a new account, stores it locally
  /// and later yield the [LoggedIn] state.
  Stream<AccountState> _mapGenerateAccountEventToState() async* {
    yield CreatingAccount();
    final mnemonic = await _generateMnemonicUseCase.generate();
    yield AccountCreated(mnemonic);
  }

  /// Handle the [LogIn] event, emitting the [LoggedIn] state as well
  /// as sending the user to the Home screen.
  Stream<AccountState> _mapLogInEventToState(LogIn event) async* {
    _analytics.logLogin();
    final account = await _getUserUseCase.single();
    yield LoggedIn(account);
    _navigatorBloc.add(NavigateToHome());
  }

  /// Handles the [LogOut] event emitting the [LoggedOut] state after
  /// effectively logging out the user.
  Stream<AccountState> _mapLogOutEventToState() async* {
    _analytics.logEvent(name: Constants.EVENT_LOGOUT);
    await _logoutUseCase.logout();
    yield LoggedOut();
  }

  Stream<AccountState> _mapRefreshEventToState(Refresh event) async* {
    final currentState = state;
    if (currentState is LoggedIn) {
      yield LoggedIn(event.user);
    }
  }

  @override
  Future<Function> close() {
    _accountSubscription?.cancel();
    return super.close();
  }
}
