import 'package:flutter_test/flutter_test.dart';
import 'package:mooncake/entities/entities.dart';
import 'package:mooncake/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:mooncake/ui/widgets/posts_list_item/widgets/post_actions_bar/widgets/export.dart';
import '../../../../../../helper.dart';
import '../../../../../../../mocks/posts.dart';

void main() {
  testWidgets('PostLikesCounter: Displays export correctly',
      (WidgetTester tester) async {
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
    List<Reaction> reactionTest = [
      Reaction(user: userAccount, value: Constants.LIKE_REACTION, code: "123"),
    ];
    StateSetter setStateController;

    await tester.pumpWidget(
      makeTestableWidget(
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            setStateController = setState;

            return PostLikesCounter(
              post: testPost.copyWith(reactions: reactionTest),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(AccountAvatar), findsOneWidget);

    setStateController(() {
      reactionTest.add(
        Reaction(
            user: userAccount, value: Constants.LIKE_REACTION, code: "123"),
      );
    });
    await tester.pumpAndSettle();
    expect(find.byType(AccountAvatar), findsNWidgets(2));

    setStateController(() {
      reactionTest.add(
        Reaction(
            user: userAccount, value: Constants.LIKE_REACTION, code: "123"),
      );
    });
    await tester.pumpAndSettle();
    expect(find.byType(AccountAvatar), findsNWidgets(3));

    setStateController(() {
      reactionTest.add(
        Reaction(
            user: userAccount, value: Constants.LIKE_REACTION, code: "123"),
      );
    });
    await tester.pumpAndSettle();
    // should not be more than 3
    expect(find.byType(AccountAvatar), findsNWidgets(3));
  });
}
