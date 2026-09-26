import 'package:equatable/equatable.dart';

class ProductImage extends Equatable {
  const ProductImage({
    required this.id,
    required this.url,
    this.isMain = false,
    this.sortOrder = 0,
  });

  final int id;

  /// Already an absolute URL.
  final String url;
  final bool isMain;
  final int sortOrder;

  @override
  List<Object?> get props => [id, url, isMain, sortOrder];
}
