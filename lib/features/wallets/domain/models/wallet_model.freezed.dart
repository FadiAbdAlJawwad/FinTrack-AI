// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WalletModel {

 String? get id; String get name; String get icon; bool get isDefault;@JsonKey(unknownEnumValue: WalletType.cash) WalletType get type;@JsonKey(includeIfNull: false) int? get openingBalanceMinor;@JsonKey(includeIfNull: false)@_AppCurrencyConverter() AppCurrency? get openingBalanceCurrency;
/// Create a copy of WalletModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletModelCopyWith<WalletModel> get copyWith => _$WalletModelCopyWithImpl<WalletModel>(this as WalletModel, _$identity);

  /// Serializes this WalletModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WalletModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&(identical(other.isDefault, _this.isDefault) || other.isDefault == _this.isDefault)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.openingBalanceMinor, _this.openingBalanceMinor) || other.openingBalanceMinor == _this.openingBalanceMinor)&&(identical(other.openingBalanceCurrency, _this.openingBalanceCurrency) || other.openingBalanceCurrency == _this.openingBalanceCurrency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WalletModel;
  return Object.hash(runtimeType,_this.id,_this.name,_this.icon,_this.isDefault,_this.type,_this.openingBalanceMinor,_this.openingBalanceCurrency);
}

@override
String toString() {
  final _this = this as WalletModel;
  return 'WalletModel(id: ${_this.id}, name: ${_this.name}, icon: ${_this.icon}, isDefault: ${_this.isDefault}, type: ${_this.type}, openingBalanceMinor: ${_this.openingBalanceMinor}, openingBalanceCurrency: ${_this.openingBalanceCurrency})';
}


}

/// @nodoc
abstract mixin class $WalletModelCopyWith<$Res>  {
  factory $WalletModelCopyWith(WalletModel value, $Res Function(WalletModel) _then) = _$WalletModelCopyWithImpl;
@useResult
$Res call({
 String? id, String name, String icon, bool isDefault,@JsonKey(unknownEnumValue: WalletType.cash) WalletType type,@JsonKey(includeIfNull: false) int? openingBalanceMinor,@JsonKey(includeIfNull: false)@_AppCurrencyConverter() AppCurrency? openingBalanceCurrency
});




}
/// @nodoc
class _$WalletModelCopyWithImpl<$Res>
    implements $WalletModelCopyWith<$Res> {
  _$WalletModelCopyWithImpl(this._self, this._then);

  final WalletModel _self;
  final $Res Function(WalletModel) _then;

/// Create a copy of WalletModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = null,Object? icon = null,Object? isDefault = null,Object? type = null,Object? openingBalanceMinor = freezed,Object? openingBalanceCurrency = freezed,}) {
  return _then(WalletModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as WalletType,openingBalanceMinor: freezed == openingBalanceMinor ? _self.openingBalanceMinor : openingBalanceMinor // ignore: cast_nullable_to_non_nullable
as int?,openingBalanceCurrency: freezed == openingBalanceCurrency ? _self.openingBalanceCurrency : openingBalanceCurrency // ignore: cast_nullable_to_non_nullable
as AppCurrency?,
  ));
}

}


/// Adds pattern-matching-related methods to [WalletModel].
extension WalletModelPatterns on WalletModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WalletModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WalletModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WalletModel value)  $default,){
final _that = this;
switch (_that) {
case _WalletModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WalletModel value)?  $default,){
final _that = this;
switch (_that) {
case _WalletModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String name,  String icon,  bool isDefault, @JsonKey(unknownEnumValue: WalletType.cash)  WalletType type, @JsonKey(includeIfNull: false)  int? openingBalanceMinor, @JsonKey(includeIfNull: false)@_AppCurrencyConverter()  AppCurrency? openingBalanceCurrency)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WalletModel() when $default != null:
return $default(_that.id,_that.name,_that.icon,_that.isDefault,_that.type,_that.openingBalanceMinor,_that.openingBalanceCurrency);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String name,  String icon,  bool isDefault, @JsonKey(unknownEnumValue: WalletType.cash)  WalletType type, @JsonKey(includeIfNull: false)  int? openingBalanceMinor, @JsonKey(includeIfNull: false)@_AppCurrencyConverter()  AppCurrency? openingBalanceCurrency)  $default,) {final _that = this;
switch (_that) {
case _WalletModel():
return $default(_that.id,_that.name,_that.icon,_that.isDefault,_that.type,_that.openingBalanceMinor,_that.openingBalanceCurrency);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String name,  String icon,  bool isDefault, @JsonKey(unknownEnumValue: WalletType.cash)  WalletType type, @JsonKey(includeIfNull: false)  int? openingBalanceMinor, @JsonKey(includeIfNull: false)@_AppCurrencyConverter()  AppCurrency? openingBalanceCurrency)?  $default,) {final _that = this;
switch (_that) {
case _WalletModel() when $default != null:
return $default(_that.id,_that.name,_that.icon,_that.isDefault,_that.type,_that.openingBalanceMinor,_that.openingBalanceCurrency);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WalletModel extends WalletModel {
  const _WalletModel({this.id, required this.name, required this.icon, this.isDefault = false, @JsonKey(unknownEnumValue: WalletType.cash) this.type = WalletType.cash, @JsonKey(includeIfNull: false) this.openingBalanceMinor, @JsonKey(includeIfNull: false)@_AppCurrencyConverter() this.openingBalanceCurrency}): super._();
  factory _WalletModel.fromJson(Map<String, dynamic> json) => _$WalletModelFromJson(json);

@override final  String? id;
@override final  String name;
@override final  String icon;
@override@JsonKey() final  bool isDefault;
@override@JsonKey(unknownEnumValue: WalletType.cash) final  WalletType type;
@override@JsonKey(includeIfNull: false) final  int? openingBalanceMinor;
@override@JsonKey(includeIfNull: false)@_AppCurrencyConverter() final  AppCurrency? openingBalanceCurrency;

/// Create a copy of WalletModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalletModelCopyWith<_WalletModel> get copyWith => __$WalletModelCopyWithImpl<_WalletModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WalletModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WalletModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.type, type) || other.type == type)&&(identical(other.openingBalanceMinor, openingBalanceMinor) || other.openingBalanceMinor == openingBalanceMinor)&&(identical(other.openingBalanceCurrency, openingBalanceCurrency) || other.openingBalanceCurrency == openingBalanceCurrency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,icon,isDefault,type,openingBalanceMinor,openingBalanceCurrency);
}

@override
String toString() {
    return 'WalletModel(id: $id, name: $name, icon: $icon, isDefault: $isDefault, type: $type, openingBalanceMinor: $openingBalanceMinor, openingBalanceCurrency: $openingBalanceCurrency)';
}


}

/// @nodoc
abstract mixin class _$WalletModelCopyWith<$Res> implements $WalletModelCopyWith<$Res> {
  factory _$WalletModelCopyWith(_WalletModel value, $Res Function(_WalletModel) _then) = __$WalletModelCopyWithImpl;
@override @useResult
$Res call({
 String? id, String name, String icon, bool isDefault,@JsonKey(unknownEnumValue: WalletType.cash) WalletType type,@JsonKey(includeIfNull: false) int? openingBalanceMinor,@JsonKey(includeIfNull: false)@_AppCurrencyConverter() AppCurrency? openingBalanceCurrency
});




}
/// @nodoc
class __$WalletModelCopyWithImpl<$Res>
    implements _$WalletModelCopyWith<$Res> {
  __$WalletModelCopyWithImpl(this._self, this._then);

  final _WalletModel _self;
  final $Res Function(_WalletModel) _then;

/// Create a copy of WalletModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = null,Object? icon = null,Object? isDefault = null,Object? type = null,Object? openingBalanceMinor = freezed,Object? openingBalanceCurrency = freezed,}) {
  return _then(_WalletModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as WalletType,openingBalanceMinor: freezed == openingBalanceMinor ? _self.openingBalanceMinor : openingBalanceMinor // ignore: cast_nullable_to_non_nullable
as int?,openingBalanceCurrency: freezed == openingBalanceCurrency ? _self.openingBalanceCurrency : openingBalanceCurrency // ignore: cast_nullable_to_non_nullable
as AppCurrency?,
  ));
}


}

// dart format on
