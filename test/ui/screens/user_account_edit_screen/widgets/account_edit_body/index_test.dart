import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import '../../../../helper.dart';
import 'package:mooncake/ui/screens/user_account_edit_screen/widgets/account_edit_body/widgets/export.dart';
import 'package:mooncake/ui/screens/user_account_edit_screen/blocs/edit/export.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mooncake/entities/entities.dart';
import 'package:mooncake/ui/screens/user_account_edit_screen/widgets/export.dart';

class MockEditAccountBloc extends MockBloc<EditAccountEvent, EditAccountState>
    implements EditAccountBloc {}

void main() {
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

  testWidgets('AccountEditorBody: Displays correctly',
      (WidgetTester tester) async {
    MockEditAccountBloc mockEditAccountBloc = MockEditAccountBloc();
    when(mockEditAccountBloc.state)
        .thenAnswer((_) => EditAccountState.initial(userAccount));
    await tester.pumpWidget(
      makeTestableWidget(
        child: MultiBlocProvider(
          providers: [
            BlocProvider<EditAccountBloc>(
              create: (_) => mockEditAccountBloc,
            ),
          ],
          child: AccountEditorBody(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("saveAccountButton"), findsWidgets);
    expect(find.byType(ListView), findsWidgets);
    expect(find.byType(AccountCoverImageEditor), findsWidgets);
    expect(find.byType(AccountTextInfoEditor), findsWidgets);
  });
}
