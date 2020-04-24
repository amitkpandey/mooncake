import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mooncake/entities/entities.dart';
import 'package:mooncake/ui/ui.dart';

class CreatePostImageItem extends StatelessWidget {
  final double size;
  final PostMedia media;

  const CreatePostImageItem({
    Key key,
    @required this.media,
    this.size = 100,
  })  : assert(media != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: media.isLocal
              ? Image.file(
                  File(media.url),
                  height: size,
                  width: size,
                  fit: BoxFit.cover,
                )
              : Image.network(
                  media.url,
                  height: size,
                  width: size,
                  fit: BoxFit.cover,
                ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: (){
              BlocProvider.of<PostInputBloc>(context)
                  .add(ImageRemoved(this.media));
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF000000).withOpacity(0.60),
              ),
              padding: EdgeInsets.all(1),
              child: FaIcon(
                MooncakeIcons.cross,
                size: size / 6,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}