import 'package:elyeter/core/error/failure.dart';
import 'package:elyeter/core/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Success carries data and folds to the success branch', () {
    const Result<int> result = Success(7);

    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull, 7);
    expect(result.fold((d) => 'ok $d', (f) => 'err'), 'ok 7');
    expect(result.map((d) => d * 2).dataOrNull, 14);
  });

  test('Error carries the failure and folds to the error branch', () {
    const Result<int> result = Error(NetworkFailure());

    expect(result.isError, isTrue);
    expect(result.dataOrNull, isNull);
    expect(result.failureOrNull, const NetworkFailure());
    expect(result.fold((d) => 'ok', (f) => f.code), 'network_error');
  });
}
