import 'package:equatable/equatable.dart';

/// One spec row (`Material: Plastik`) or one variant option
/// (`Reňk: Gara`), already localized by the backend.
class ProductAttribute extends Equatable {
  const ProductAttribute({required this.name, required this.value});

  final String name;
  final String value;

  @override
  List<Object?> get props => [name, value];
}
