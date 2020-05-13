import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:mooncake/entities/entities.dart';
import 'package:mooncake/entities/posts/export.dart';
import 'package:mooncake/repositories/repositories.dart';
import 'package:sembast/sembast.dart';

import 'converter.dart';

/// Implementation of [LocalPostsSource] that deals with local data.
class LocalPostsSourceImpl implements LocalPostsSource {
  final StoreRef _store = StoreRef.main();
  final Database _database;

  /// Public constructor
  LocalPostsSourceImpl({@required Database database})
      : assert(database != null),
        _database = database;

  /// Returns the keys that should be used inside the database to store the
  /// given [post].
  @visibleForTesting
  String getPostKey(Post post) {
    return DateFormat(Post.DATE_FORMAT).format(post.dateTime) +
        post.owner.address;
  }

  @override
  Stream<List<Post>> get postsStream {
    final finder = Finder(
      filter: Filter.equals(Post.HIDDEN_FIELD, false),
      sortOrders: [SortOrder(Post.DATE_FIELD, false)],
    );

    return _store
        .query(finder: finder)
        .onSnapshots(_database)
        .asyncMap(PostsConverter.deserializePosts);
  }

  /// Given a [limit], returns the [Finder] that should be used to get
  /// the home posts returning a list of the [limit] size.
  Finder _homeFinder(int limit) {
    return Finder(
      filter: Filter.and([
        Filter.or([
          Filter.equals(Post.PARENT_ID_FIELD, null),
          Filter.equals(Post.PARENT_ID_FIELD, ""),
        ]),
        Filter.equals(Post.HIDDEN_FIELD, false),
      ]),
      sortOrders: [SortOrder(Post.DATE_FIELD, false)],
      limit: limit,
    );
  }

  @override
  Stream<List<Post>> homePostsStream(int limit) {
    return _store
        .query(finder: _homeFinder(limit))
        .onSnapshots(_database)
        .asyncMap(PostsConverter.deserializePosts);
  }

  /// Given a [postId], returns the [Finder] that should be used to filter
  /// the posts and find the one having the given id.
  Finder _postFinder(String postId) {
    return Finder(filter: Filter.equals(Post.ID_FIELD, postId));
  }

  @override
  Stream<Post> singlePostStream(String postId) {
    return _store
        .query(finder: _postFinder(postId))
        .onSnapshots(_database)
        .asyncMap(PostsConverter.deserializePosts)
        .map((event) => event.isEmpty ? null : event.first);
  }

  @override
  Future<Post> getSinglePost(String postId) async {
    final record = await _store.findFirst(
      _database,
      finder: _postFinder(postId),
    );
    return record == null ? null : PostsConverter.deserializePost(record);
  }

  @override
  Future<List<Post>> getPostsByTxHash(String txHash) async {
    final finder = Finder(
      filter: Filter.and([
        Filter.equals(Post.STATUS_VALUE_FIELD, PostStatusValue.TX_SENT.value),
        Filter.equals(Post.STATUS_DATA_FIELD, txHash),
      ]),
    );

    final records = await _store.find(_database, finder: finder);
    return PostsConverter.deserializePosts(records);
  }

  /// Given a [postId] returns the [Finder] that should be used in order
  /// to get all the comments for the post having such id.
  Finder _commentsFinder(String postId) {
    return Finder(
      filter: Filter.and([
        Filter.equals(Post.HIDDEN_FIELD, false),
        Filter.equals(Post.PARENT_ID_FIELD, postId),
      ]),
      sortOrders: [SortOrder(Post.DATE_FIELD, false)],
    );
  }

  @override
  Stream<List<Post>> getPostCommentsStream(String postId) {
    return _store
        .query(finder: _commentsFinder(postId))
        .onSnapshots(_database)
        .asyncMap(PostsConverter.deserializePosts);
  }

  @override
  Future<List<Post>> getPostComments(String postId) async {
    final records = await _store.find(
      _database,
      finder: _commentsFinder(postId),
    );
    return PostsConverter.deserializePosts(records);
  }

  @override
  Future<List<Post>> getPostsToSync() async {
    final finder = Finder(
      filter: Filter.or([
        Filter.equals(
          Post.STATUS_VALUE_FIELD,
          PostStatusValue.STORED_LOCALLY.value,
        ),
        Filter.equals(
          Post.STATUS_VALUE_FIELD,
          PostStatusValue.ERRORED.value,
        ),
      ]),
    );

    final records = await _store.find(_database, finder: finder);
    return PostsConverter.deserializePosts(records);
  }

  @override
  Future<void> savePost(Post post) async {
    final value = await PostsConverter.serializePost(post);
    await _database.transaction((txn) async {
      await _store.record(getPostKey(post)).put(txn, value);
    });
  }

  /// Takes a list of [existingPosts] and a list of [newPosts], and merges
  /// them together.
  /// Merging means that the reactions and comments ids will be unified, but
  /// all the other information will be taken from the [newPosts] list elements.
  ///
  /// The two lists should have the same length, and for each `i`,
  /// then `newPosts[i]` should represent the same post as `existingPosts[i]`.
  /// If [existingPosts] does not contain al posts present inside [newPosts],
  /// then the associated post can be null.
  @visibleForTesting
  List<Post> mergePosts(List<Post> existingPosts, List<Post> newPosts) {
    final merged = List<Post>()..addAll(newPosts);

    for (int index = 0; index < merged.length; index++) {
      final existing = existingPosts[index];
      final updated = merged[index];

      final successfulExisting = existing.copyWith(
        status: PostStatus(value: PostStatusValue.TX_SUCCESSFULL),
      );
      if (updated == successfulExisting) {
        // The updated one is identical to the local, with only the status
        // changed. For this reason we can use the updated to go faster.
        continue;
      }

      Set<Reaction> reactions = updated.reactions.toSet();
      if (existing?.reactions != null) {
        reactions.addAll(existing.reactions);
      }

      Set<String> commentIds = updated.commentsIds.toSet();
      if (existing?.commentsIds != null) {
        commentIds.addAll(existing.commentsIds);
      }

      PostPoll postPoll = updated.poll;
      if (existing?.poll != null && updated.poll != null) {
        Set<PollAnswer> answers = (updated.poll.userAnswers ?? []).toSet();
        answers.addAll(existing.poll.userAnswers ?? []);
        postPoll = postPoll.copyWith(userAnswers: answers.toList());
      }

      merged[index] = updated.copyWith(
        status: existing?.status,
        reactions: reactions.toList(),
        commentsIds: commentIds.toList(),
        poll: postPoll,
      );
    }

    return merged;
  }

  @override
  Future<void> savePosts(List<Post> posts, {bool merge = false}) async {
    final keys = posts.map((e) => getPostKey(e)).toList();

    await _database.transaction((txn) async {
      if (merge) {
        final existingValues = await PostsConverter.deserializePosts(
          await _store.records(keys).get(txn),
        );
        posts = mergePosts(existingValues, posts);
      }

      final values = await PostsConverter.serializePosts(posts);
      await _store.records(keys).put(txn, values);
    });
  }

  @override
  Future<void> deletePosts() async {
    await _store.delete(_database);
  }
}
