part of 'drift_unit_of_work.dart';

final Object _unitOfWorkZoneKey = Object();

bool get inUnitOfWork => Zone.current[_unitOfWorkZoneKey] == true;

Future<T> _runInUnitOfWorkZone<T>(Future<T> Function() body) {
  return runZoned(body, zoneValues: {_unitOfWorkZoneKey: true});
}

void assertInUnitOfWork() {
  if (!inUnitOfWork) {
    throw StateError('Must be inside UnitOfWork');
  }
}

void assertNotInUnitOfWork() {
  assert(!inUnitOfWork, 'Must not be inside UnitOfWork');
}
