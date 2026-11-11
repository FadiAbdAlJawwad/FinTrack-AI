// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WalletModel _$WalletModelFromJson(Map<String, dynamic> json) => _WalletModel(
  id: json['id'] as String?,
  name: json['name'] as String,
  icon: json['icon'] as String,
  isDefault: json['isDefault'] as bool? ?? false,
  type:
      $enumDecodeNullable(
        _$WalletTypeEnumMap,
        json['type'],
        unknownValue: WalletType.cash,
      ) ??
      WalletType.cash,
  openingBalanceMinor: (json['openingBalanceMinor'] as num?)?.toInt(),
  openingBalanceCurrency: const _AppCurrencyConverter().fromJson(
    json['openingBalanceCurrency'] as String?,
  ),
);

Map<String, dynamic> _$WalletModelToJson(_WalletModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'isDefault': instance.isDefault,
      'type': _$WalletTypeEnumMap[instance.type]!,
      'openingBalanceMinor': ?instance.openingBalanceMinor,
      'openingBalanceCurrency': ?const _AppCurrencyConverter().toJson(
        instance.openingBalanceCurrency,
      ),
    };

const _$WalletTypeEnumMap = {
  WalletType.cash: 'cash',
  WalletType.bank: 'bank',
  WalletType.eWallet: 'eWallet',
};
