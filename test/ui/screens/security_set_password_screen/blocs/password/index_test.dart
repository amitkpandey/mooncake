import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mooncake/usecases/usecases.dart';
import 'package:mooncake/ui/ui.dart';
import 'package:mooncake/ui/screens/security_set_password_screen/blocs/export.dart';
import 'package:mooncake/entities/entities.dart';

class MockRecoverAccountBloc extends Mock implements RecoverAccountBloc {}

class MockAccountBloc extends Mock implements AccountBloc {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockSetAuthenticationMethodUseCase extends Mock
    implements SetAuthenticationMethodUseCase {}

void main() {
  MockAccountBloc mockAccountBloc;
  MockRecoverAccountBloc mockRecoverAccountBloc;
  MockLoginUseCase mockLoginUseCase;
  MockSetAuthenticationMethodUseCase mockSetAuthenticationMethodUseCase;

  setUp(() {
    mockAccountBloc = MockAccountBloc();
    mockRecoverAccountBloc = MockRecoverAccountBloc();
    mockLoginUseCase = MockLoginUseCase();
    mockSetAuthenticationMethodUseCase = MockSetAuthenticationMethodUseCase();
  });

  group(
    'RestoreBackupBloc',
    () {
      SetPasswordBloc setPasswordBloc;
      MooncakeAccount userAccount = MooncakeAccount(
        profilePicUri: "https://example.com/avatar.png",
        moniker: "john-doe",
        cosmosAccount: CosmosAccount(
          accountNumber: 153,
          address: "desmos1ew60ztvqxlf5kjjyyzxf7hummlwdadgesu3725",
          coins: [
            StdCoin(amount: "10000", denom: "udaric"),
          ],
          sequence: 45,
        ),
      );
      setUp(
        () {
          setPasswordBloc = SetPasswordBloc(
            accountBloc: mockAccountBloc,
            recoverAccountBloc: mockRecoverAccountBloc,
            loginUseCase: mockLoginUseCase,
            setAuthenticationMethodUseCase: mockSetAuthenticationMethodUseCase,
          );
        },
      );

      blocTest(
        'PasswordChanged: work properly',
        build: () async {
          return setPasswordBloc;
        },
        act: (bloc) async {
          bloc.add(PasswordChanged("password"));
        },
        expect: [
          SetPasswordState(
            showPassword: false,
            inputPassword: "password",
            savingPassword: false,
          ),
        ],
      );

      blocTest(
        'PasswordChanged: work properly',
        build: () async {
          return setPasswordBloc;
        },
        act: (bloc) async {
          bloc.add(TriggerPasswordVisibility());
          bloc.add(TriggerPasswordVisibility());
        },
        expect: [
          SetPasswordState(
            showPassword: true,
            inputPassword: "",
            savingPassword: false,
          ),
          SetPasswordState(
            showPassword: false,
            inputPassword: "",
            savingPassword: false,
          ),
        ],
      );

      blocTest(
        'SavePassword: work properly',
        build: () async {
          return setPasswordBloc;
        },
        act: (bloc) async {
          when(mockRecoverAccountBloc.state)
              .thenAnswer((_) => RecoverAccountState.initial());
          when(mockAccountBloc.state).thenReturn(LoggedIn.initial(userAccount));
          when(mockSetAuthenticationMethodUseCase.password(any))
              .thenAnswer((_) => Future.value(null));
          when(mockLoginUseCase.login(any))
              .thenAnswer((_) => Future.value(null));
          bloc.add(SavePassword());
        },
        expect: [
          SetPasswordState(
            showPassword: false,
            inputPassword: "",
            savingPassword: true,
          ),
        ],
      );
    },
  );
}
