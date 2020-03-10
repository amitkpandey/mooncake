import 'package:flutter/material.dart';
import 'package:mooncake/entities/entities.dart';
import 'package:mooncake/ui/ui.dart';

import 'post_content_header.dart';
import 'post_content_message.dart';
import 'post_content_images.dart';

/// Contains the main content of a post. Such content is made of
/// - The header of the post, indicating the creator and the data
/// - The main message of the post
/// - The image(s) associated to the post
class PostContent extends StatelessWidget {
  final Post post;

  const PostContent({Key key, this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        PostMessage(
          key: PostsKeys.postItemMessage(post.id),
          post: post,
        ),
        const SizedBox(height: PostsTheme.defaultPadding),
        PostImagesPreviewer(
          key: PostsKeys.postItemImagePreviewer(post.id),
          post: post,
        ),
        const SizedBox(height: PostsTheme.defaultPadding),
        PostItemHeader(
          key: PostsKeys.postItemHeader(post.id),
          post: post,
        ),
      ],
    );
  }
}
