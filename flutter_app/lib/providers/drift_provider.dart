import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/drift_bottle.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

final myBottlesProvider =
    AsyncNotifierProvider<MyBottlesNotifier, List<MyDriftBottle>>(
        MyBottlesNotifier.new);

class MyBottlesNotifier extends AsyncNotifier<List<MyDriftBottle>> {
  final _api = ApiService();

  @override
  Future<List<MyDriftBottle>> build() async {
    final auth = ref.watch(authProvider);
    if (auth != AuthStatus.authenticated) {
      return [];
    }
    final list = await _api.getMyBottles();
    return list
        .map((e) => MyDriftBottle.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}

final pickBottleProvider = FutureProvider.family<DriftBottle, void>(
  (ref, _) async {
    final json = await ApiService().pickBottle();
    return DriftBottle.fromJson(json);
  },
);

final bottleJourneyProvider = FutureProvider.family<DriftBottle, int>(
  (ref, bottleId) async {
    final json = await ApiService().getBottleJourney(bottleId);
    return DriftBottle.fromJson(json);
  },
);
