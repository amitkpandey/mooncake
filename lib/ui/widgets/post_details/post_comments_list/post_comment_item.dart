import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mooncake/entities/entities.dart';
import 'package:mooncake/ui/ui.dart';
import 'package:mooncake/ui/widgets/post_content/images/post_images_previewer.dart';

/// Represents single item entry inside the list of post comments.
class PostCommentItem extends StatelessWidget {
  static const ICON_SIZE = 20.0;

  final Post comment;
  PostCommentItem({Key key, @required this.comment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
        builder: (BuildContext context, AccountState accountState) {
      final state = accountState as LoggedIn;
      final isLiked = state.user.hasLiked(comment);

      return InkWell(
        onTap: () => _onTap(context),
        child: Container(
          padding: PostsTheme.postItemPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              PostItemHeader(post: comment),
              const SizedBox(height: PostsTheme.defaultPadding),
              Text(comment.message),
              const SizedBox(height: PostsTheme.defaultPadding),
              PostImagesPreviewer(post: comment),
              const SizedBox(height: PostsTheme.defaultPadding),
              _commentActions(isLiked),
            ],
          ),
        ),
      );
    });
  }

  Row _commentActions(bool isLiked) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        PostCommentAction(size: ICON_SIZE, post: comment),
        SizedBox(width: ICON_SIZE),
        PostLikeAction(size: ICON_SIZE, isLiked: isLiked, post: comment),
      ],
    );
  }

  void _onTap(BuildContext context) {
    BlocProvider.of<NavigatorBloc>(context)
        .add(NavigateToPostDetails(context, comment.id));
  }
}
