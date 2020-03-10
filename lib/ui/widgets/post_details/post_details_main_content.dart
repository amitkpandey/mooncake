import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mooncake/ui/ui.dart';

import 'post_comments_list/export.dart';
import 'post_reactions_list/export.dart';

/// Represents the main content of the post details screen.
class PostDetailsMainContent extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    final padding = PostsTheme.postItemPadding;
    return BlocBuilder<PostDetailsBloc, PostDetailsState>(
      builder: (BuildContext context, PostDetailsState state) {
        final currentState = state as PostDetailsLoaded;
        final post = currentState.post;

        return DefaultTabController(
          length: 2,
          child: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool _) {
              return [
                // Post content
                SliverList(
                  delegate: SliverChildListDelegate([
                    Container(padding: padding, child: PostContent(post: post)),
                    SizedBox(height: PostsTheme.defaultPadding),
                  ]),
                ),
                // Tab bar
                SliverOverlapAbsorber(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                    context,
                  ),
                  sliver: SliverAppBar(
                    elevation: 0,
                    primary: false,
                    stretch: true,
                    floating: false,
                    backgroundColor: Colors.white,
                    leading: Container(),
                    pinned: true,
                    flexibleSpace: TabBar(
                      labelColor: ThemeColors.accentColor,
                      unselectedLabelColor: ThemeColors.textColorLight,
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: <Widget>[
                        Tab(
                          text: PostsLocalizations.of(context)
                              .commentsTabLabel(currentState.commentsCount),
                        ),
                        Tab(
                          text: PostsLocalizations.of(context)
                              .reactionsTabLabel(currentState.reactionsCount),
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: <Widget>[
                PostCommentsList(),
                PostReactionsList(),
              ],
            ),
          ),
        );
      },
    );
  }
}
