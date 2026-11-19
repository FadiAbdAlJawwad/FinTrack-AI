enum CurrencyCode {
  ils('ILS', 2, 100),
  usd('USD', 2, 100),
  jod('JOD', 3, 1000);

  const CurrencyCode(this.isoCode, this.decimals, this.minorFactor);

  final String isoCode;
  final int decimals;
  final int minorFactor;

  static CurrencyCode? fromIso(String code) => throw UnimplementedError();
}
