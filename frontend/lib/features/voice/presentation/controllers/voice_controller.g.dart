// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$voiceRepositoryHash() => r'7a42405c8bc53e84afdd1ce379896219ad2f3b37';

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
String _$voiceControllerHash() => r'a2928aa22bb003f7d98ec2753b7bc37e4ed7a2c0';

/// See also [VoiceController].
@ProviderFor(VoiceController)
final voiceControllerProvider =
    AutoDisposeNotifierProvider<
      VoiceController,
      AsyncValue<VoiceSessionResult?>
    >.internal(
      VoiceController.new,
      name: r'voiceControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$voiceControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$VoiceController =
    AutoDisposeNotifier<AsyncValue<VoiceSessionResult?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
