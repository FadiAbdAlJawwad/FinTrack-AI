import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet_model.freezed.dart';
part 'wallet_model.g.dart';

enum WalletType { cash, bank, eWallet }

@freezed
abstract class WalletModel with _$WalletModel {
  const factory WalletModel({
    String? id,
    required String name,
    required String icon,
    @Default(false) bool isDefault,
    @Default(WalletType.cash) @JsonKey(unknownEnumValue: WalletType.cash) WalletType type,
  }) = _WalletModel;

  const WalletModel._();

  factory WalletModel.fromJson(Map<String, dynamic> json) =>
      _$WalletModelFromJson(json);
}
