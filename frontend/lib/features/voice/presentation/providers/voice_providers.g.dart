// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$voicePlatformServiceHash() =>
    r'f1fd38f741f59ab88e1a1d53613ba242ce6d1961';

/// See also [voicePlatformService].
@ProviderFor(voicePlatformService)
final voicePlatformServiceProvider =
    AutoDisposeProvider<VoicePlatformService>.internal(
      voicePlatformService,
      name: r'voicePlatformServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$voicePlatformServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VoicePlatformServiceRef = AutoDisposeProviderRef<VoicePlatformService>;
String _$currentVoiceSessionHash() =>
    r'9c629f6affd917a96f85f6bcda66d4bd1585ee8e';

/// See also [CurrentVoiceSession].
@ProviderFor(CurrentVoiceSession)
final currentVoiceSessionProvider =
    AutoDisposeNotifierProvider<
      CurrentVoiceSession,
      VoiceSessionResult?
    >.internal(
      CurrentVoiceSession.new,
      name: r'currentVoiceSessionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentVoiceSessionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CurrentVoiceSession = AutoDisposeNotifier<VoiceSessionResult?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
