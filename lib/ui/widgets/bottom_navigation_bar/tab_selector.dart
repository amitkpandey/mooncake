import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mooncake/entities/app/app_tab.dart';
import 'package:mooncake/ui/ui.dart';

import 'bottom_navigation_button.dart';

/// Allows the user to select which tab should be visible inside
/// the [HomeScreen].
class TabSelector extends StatelessWidget {
  TabSelector({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(color: PostsTheme.borderColor, width: 0.5),
          )),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        key: PostsKeys.tabs,
        children: [
          BottomNavigationButton(
            key: PostsKeys.allPostsTab,
            tab: AppTab.allPosts,
          ),

          // TODO: Implement this again
//          BottomNavigationButton(
//            key: PostsKeys.likedPostsTab,
//            tab: AppTab.likedPosts,
//          ),

          MaterialButton(
            textColor: Colors.white,
            padding: EdgeInsets.all(0),
            onPressed: () => Navigator.of(context).push(_createRoute()),
            shape: CircleBorder(),
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: PostsTheme.gradient,
              ),
              child: Icon(MooncakeIcons.wallet),
            ),
          ),

          // TODO: Implement this again
//          BottomNavigationButton(
//            key: PostsKeys.yourPostsTab,
//            tab: AppTab.notifications,
//          ),

          BottomNavigationButton(
            key: PostsKeys.notificationsTab,
            tab: AppTab.account,
          ),
        ],
      ),
    );
  }

  Route _createRoute() {
    return MaterialPageRoute(builder: (BuildContext context) {
      return CreatePostScreen(callback: (post) {
        // ignore: close_sinks
        final bloc = BlocProvider.of<PostsListBloc>(context);
        // TODO: Implement AddPost again
//        bloc.add(AddPost(post));
      });
    });
  }
}
