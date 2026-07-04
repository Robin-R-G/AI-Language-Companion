// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$voiceRepositoryHash() => r'972551c3ab38c41050ec53f5c5f4e4a23e595ad6';

/// See also [voiceRepository].
@ProviderFor(voiceRepository)
final voiceRepositoryProvider = AutoDisposeProvider<VoiceRepository>.internal(
  voiceRepository,
  name: r'voiceRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$voiceRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VoiceRepositoryRef = AutoDisposeProviderRef<VoiceRepository>;
String _$currentVoiceSessionHash() =>
    r'3354eda14217e52ae722083abc84c29c69a40ad0';

/// See also [CurrentVoiceSession].
@ProviderFor(CurrentVoiceSession)
final currentVoiceSessionProvider =
    AutoDisposeNotifierProvider<CurrentVoiceSession, VoiceSession?>.internal(
      CurrentVoiceSession.new,
      name: r'currentVoiceSessionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentVoiceSessionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CurrentVoiceSession = AutoDisposeNotifier<VoiceSession?>;
String _$pronunciationScoreStateHash() =>
    r'5033d3a6f82b77f4525ea07fa8f383a4ecff5a7e';

/// See also [PronunciationScoreState].
@ProviderFor(PronunciationScoreState)
final pronunciationScoreStateProvider =
    AutoDisposeNotifierProvider<
      PronunciationScoreState,
      PronunciationScore?
    >.internal(
      PronunciationScoreState.new,
      name: r'pronunciationScoreStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pronunciationScoreStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PronunciationScoreState = AutoDisposeNotifier<PronunciationScore?>;
String _$voiceSessionsHistoryHash() =>
    r'43fea295d39e4f532ac48050f0d8363d5daf20e9';

/// See also [VoiceSessionsHistory].
@ProviderFor(VoiceSessionsHistory)
final voiceSessionsHistoryProvider =
    AutoDisposeNotifierProvider<
      VoiceSessionsHistory,
      List<VoiceSession>
    >.internal(
      VoiceSessionsHistory.new,
      name: r'voiceSessionsHistoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$voiceSessionsHistoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$VoiceSessionsHistory = AutoDisposeNotifier<List<VoiceSession>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
