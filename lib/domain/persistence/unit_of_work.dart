abstract interface class UnitOfWork {
  Future<T> run<T>(Future<T> Function() action);
}
