import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_code_box/core/database/isar_service.dart';
import 'package:ai_code_box/features/spaces/models/space.dart';
import 'package:ai_code_box/features/spaces/repositories/space_repository.dart';

final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService();
});

final spaceRepositoryProvider = Provider<SpaceRepository>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return SpaceRepository(isarService);
});

final spacesProvider = FutureProvider<List<Space>>((ref) async {
  final repository = ref.watch(spaceRepositoryProvider);
  return await repository.getAllSpaces();
});

final defaultSpaceProvider = FutureProvider<Space>((ref) async {
  final repository = ref.watch(spaceRepositoryProvider);
  return await repository.getOrCreateDefaultSpace();
});

final spaceProvider = FutureProvider.family<Space?, int>((ref, spaceId) async {
  final repository = ref.watch(spaceRepositoryProvider);
  return await repository.getSpaceById(spaceId);
});

final childSpacesProvider = FutureProvider.family<List<Space>, int>((ref, parentSpaceId) async {
  final repository = ref.watch(spaceRepositoryProvider);
  return await repository.getChildSpaces(parentSpaceId);
});

