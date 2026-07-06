// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_providers.dart';

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
String _$chatMessagesHash() => r'44e7701310def459c5abc19b0b402a8b770fdcc9';

/// See also [ChatMessages].
@ProviderFor(ChatMessages)
final chatMessagesProvider =
    AutoDisposeNotifierProvider<
      ChatMessages,
      List<domain.ChatMessage>
    >.internal(
      ChatMessages.new,
      name: r'chatMessagesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$chatMessagesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ChatMessages = AutoDisposeNotifier<List<domain.ChatMessage>>;
String _$activeConversationIdHash() =>
    r'60f5494e2be20c6acee8008be6f8c3842ed7b5fa';

/// See also [ActiveConversationId].
@ProviderFor(ActiveConversationId)
final activeConversationIdProvider =
    AutoDisposeNotifierProvider<ActiveConversationId, String>.internal(
      ActiveConversationId.new,
      name: r'activeConversationIdProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeConversationIdHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ActiveConversationId = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
