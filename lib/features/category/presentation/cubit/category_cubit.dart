import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

enum CategoryStatus { initial, loading, loaded, failed }

/// The category tab's tree: `GET /categories/tree`, once per launch.
class CategoryState extends Equatable {
  const CategoryState({
    this.status = CategoryStatus.initial,
    this.categories = const [],
    this.failure,
  });

  final CategoryStatus status;

  /// Root nodes only; each one carries its own [Category.children].
  final List<Category> categories;

  final Failure? failure;

  bool get isLoading =>
      status == CategoryStatus.initial || status == CategoryStatus.loading;

  @override
  List<Object?> get props => [status, categories, failure];
}

/// Loads the category tree and keeps the grid in step with it.
///
/// The repository already caches the tree for the whole launch, so a rebuilt
/// page costs nothing and [load] is safe to call again from a retry.
class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit(this._repository) : super(const CategoryState());

  final CategoryRepository _repository;

  Future<void> load() async {
    // Keep whatever is already on screen while a retry is in flight: the
    // grid should not flash back to placeholders for a re-fetch.
    emit(
      CategoryState(
        status: CategoryStatus.loading,
        categories: state.categories,
      ),
    );

    final result = await _repository.tree();
    switch (result) {
      case Success(:final data):
        emit(CategoryState(status: CategoryStatus.loaded, categories: data));
      case Error(:final failure):
        emit(
          CategoryState(
            status: CategoryStatus.failed,
            categories: state.categories,
            failure: failure,
          ),
        );
    }
  }
}
