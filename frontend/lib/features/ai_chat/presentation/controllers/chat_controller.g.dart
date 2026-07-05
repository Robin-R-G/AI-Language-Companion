// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatRepositoryHash() => r'9c001779362f0b69d23af145f78c76b3dd2728c1';

/// See also [chatRepository].
@ProviderFor(chatRepository)
final chatRepositoryProvider = AutoDisposeProvider<ChatRepository>.internal(
  chatRepository,
  name: r'chatRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$chatRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ChatRepositoryRef = AutoDisposeProviderRef<ChatRepository>;
String _$chatControllerHash() => r'cb9ae02c69803f3f7ccc61de734623b72a612de8';

/// See also [ChatController].
@ProviderFor(ChatController)
final chatControllerProvider =
    AutoDisposeNotifierProvider<
      ChatController,
      AsyncValue<List<ChatMessage>>
    >.internal(
      ChatController.new,
      name: r'chatControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$chatControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ChatController = AutoDisposeNotifier<AsyncValue<List<ChatMessage>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
