import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../currency/domain/models/app_currency.dart';

part 'wallet_model.freezed.dart';
part 'wallet_model.g.dart';

enum WalletType { cash, bank, eWallet }

class _AppCurrencyConverter implements JsonConverter<AppCurrency?, String?> {
  const _AppCurrencyConverter();
  @override
  AppCurrency? fromJson(String? json) => json == null ? null : appCurrencyTryFromCode(json);
  @override
  String? toJson(AppCurrency? object) => object?.code;
}

@freezed
abstract class WalletModel with _$WalletModel {
  const factory WalletModel({
    String? id,
    required String name,
    required String icon,
    @Default(false) bool isDefault,
    @Default(WalletType.cash) @JsonKey(unknownEnumValue: WalletType.cash) WalletType type,
    @JsonKey(includeIfNull: false) int? openingBalanceMinor,
    @JsonKey(includeIfNull: false) @_AppCurrencyConverter() AppCurrency? openingBalanceCurrency,
  }) = _WalletModel;

  const WalletModel._();

  factory WalletModel.fromJson(Map<String, dynamic> json) =>
      _$WalletModelFromJson(json);
}
