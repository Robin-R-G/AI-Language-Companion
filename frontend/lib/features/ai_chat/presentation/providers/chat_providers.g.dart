// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatRepositoryHash() => r'7eed17632817dcc2271151a9ba7f29236109bb4b';

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
String _$chatMessagesHash() => r'cd53234fcce3220cc1ba1ac27b432a51d5e512f6';

/// See also [ChatMessages].
@ProviderFor(ChatMessages)
final chatMessagesProvider =
    AutoDisposeNotifierProvider<ChatMessages, List<ChatMessage>>.internal(
      ChatMessages.new,
      name: r'chatMessagesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$chatMessagesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ChatMessages = AutoDisposeNotifier<List<ChatMessage>>;
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
String _$conversationsListHash() => r'c44d442f51d5c60adc0447bcf723a20986d9330d';

/// See also [ConversationsList].
@ProviderFor(ConversationsList)
final conversationsListProvider =
    AutoDisposeNotifierProvider<
      ConversationsList,
      List<Map<String, dynamic>>
    >.internal(
      ConversationsList.new,
      name: r'conversationsListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$conversationsListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ConversationsList = AutoDisposeNotifier<List<Map<String, dynamic>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
