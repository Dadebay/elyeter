import 'package:hydrated_bloc/hydrated_bloc.dart';

/// The ids of the products the customer has favourited.
///
/// Hydrated, like the theme and locale cubits, so the list survives a
/// restart. Ids only: the products themselves come from the catalog, so
/// nothing here goes stale when a price or a photo changes.
class FavoriteCubit extends HydratedCubit<Set<String>> {
  FavoriteCubit() : super(const {});

  bool contains(String id) => state.contains(id);

  /// Adds the product, or removes it when it is already a favourite.
  void toggle(String id) {
    final next = Set<String>.of(state);
    if (!next.remove(id)) next.add(id);
    emit(next);
  }

  /// Empties the list. Named to avoid [HydratedMixin.clear], which throws the
  /// stored copy away without telling the UI.
  void removeAll() => emit(const {});

  @override
  Set<String>? fromJson(Map<String, dynamic> json) =>
      (json['ids'] as List?)?.cast<String>().toSet();

  @override
  Map<String, dynamic>? toJson(Set<String> state) => {'ids': state.toList()};
}
