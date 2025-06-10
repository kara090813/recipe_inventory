// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_badge_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserBadgeProgress _$UserBadgeProgressFromJson(Map<String, dynamic> json) {
  return _UserBadgeProgress.fromJson(json);
}

/// @nodoc
mixin _$UserBadgeProgress {
  @HiveField(0)
  String get badgeId => throw _privateConstructorUsedError;
  @HiveField(1)
  int get currentProgress => throw _privateConstructorUsedError;
  @HiveField(2)
  bool get isUnlocked => throw _privateConstructorUsedError;
  @HiveField(3)
  DateTime? get unlockedAt => throw _privateConstructorUsedError;
  @HiveField(4)
  bool get isMainBadge => throw _privateConstructorUsedError; // 메인 뱃지로 설정 여부
  @HiveField(5)
  DateTime? get progressUpdatedAt =>
      throw _privateConstructorUsedError; // 추가 메타데이터
  @HiveField(6)
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserBadgeProgressCopyWith<UserBadgeProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserBadgeProgressCopyWith<$Res> {
  factory $UserBadgeProgressCopyWith(
          UserBadgeProgress value, $Res Function(UserBadgeProgress) then) =
      _$UserBadgeProgressCopyWithImpl<$Res, UserBadgeProgress>;
  @useResult
  $Res call(
      {@HiveField(0) String badgeId,
      @HiveField(1) int currentProgress,
      @HiveField(2) bool isUnlocked,
      @HiveField(3) DateTime? unlockedAt,
      @HiveField(4) bool isMainBadge,
      @HiveField(5) DateTime? progressUpdatedAt,
      @HiveField(6) Map<String, dynamic> metadata});
}

/// @nodoc
class _$UserBadgeProgressCopyWithImpl<$Res, $Val extends UserBadgeProgress>
    implements $UserBadgeProgressCopyWith<$Res> {
  _$UserBadgeProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? badgeId = null,
    Object? currentProgress = null,
    Object? isUnlocked = null,
    Object? unlockedAt = freezed,
    Object? isMainBadge = null,
    Object? progressUpdatedAt = freezed,
    Object? metadata = null,
  }) {
    return _then(_value.copyWith(
      badgeId: null == badgeId
          ? _value.badgeId
          : badgeId // ignore: cast_nullable_to_non_nullable
              as String,
      currentProgress: null == currentProgress
          ? _value.currentProgress
          : currentProgress // ignore: cast_nullable_to_non_nullable
              as int,
      isUnlocked: null == isUnlocked
          ? _value.isUnlocked
          : isUnlocked // ignore: cast_nullable_to_non_nullable
              as bool,
      unlockedAt: freezed == unlockedAt
          ? _value.unlockedAt
          : unlockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isMainBadge: null == isMainBadge
          ? _value.isMainBadge
          : isMainBadge // ignore: cast_nullable_to_non_nullable
              as bool,
      progressUpdatedAt: freezed == progressUpdatedAt
          ? _value.progressUpdatedAt
          : progressUpdatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserBadgeProgressImplCopyWith<$Res>
    implements $UserBadgeProgressCopyWith<$Res> {
  factory _$$UserBadgeProgressImplCopyWith(_$UserBadgeProgressImpl value,
          $Res Function(_$UserBadgeProgressImpl) then) =
      __$$UserBadgeProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String badgeId,
      @HiveField(1) int currentProgress,
      @HiveField(2) bool isUnlocked,
      @HiveField(3) DateTime? unlockedAt,
      @HiveField(4) bool isMainBadge,
      @HiveField(5) DateTime? progressUpdatedAt,
      @HiveField(6) Map<String, dynamic> metadata});
}

/// @nodoc
class __$$UserBadgeProgressImplCopyWithImpl<$Res>
    extends _$UserBadgeProgressCopyWithImpl<$Res, _$UserBadgeProgressImpl>
    implements _$$UserBadgeProgressImplCopyWith<$Res> {
  __$$UserBadgeProgressImplCopyWithImpl(_$UserBadgeProgressImpl _value,
      $Res Function(_$UserBadgeProgressImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? badgeId = null,
    Object? currentProgress = null,
    Object? isUnlocked = null,
    Object? unlockedAt = freezed,
    Object? isMainBadge = null,
    Object? progressUpdatedAt = freezed,
    Object? metadata = null,
  }) {
    return _then(_$UserBadgeProgressImpl(
      badgeId: null == badgeId
          ? _value.badgeId
          : badgeId // ignore: cast_nullable_to_non_nullable
              as String,
      currentProgress: null == currentProgress
          ? _value.currentProgress
          : currentProgress // ignore: cast_nullable_to_non_nullable
              as int,
      isUnlocked: null == isUnlocked
          ? _value.isUnlocked
          : isUnlocked // ignore: cast_nullable_to_non_nullable
              as bool,
      unlockedAt: freezed == unlockedAt
          ? _value.unlockedAt
          : unlockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isMainBadge: null == isMainBadge
          ? _value.isMainBadge
          : isMainBadge // ignore: cast_nullable_to_non_nullable
              as bool,
      progressUpdatedAt: freezed == progressUpdatedAt
          ? _value.progressUpdatedAt
          : progressUpdatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserBadgeProgressImpl implements _UserBadgeProgress {
  _$UserBadgeProgressImpl(
      {@HiveField(0) required this.badgeId,
      @HiveField(1) this.currentProgress = 0,
      @HiveField(2) this.isUnlocked = false,
      @HiveField(3) this.unlockedAt,
      @HiveField(4) this.isMainBadge = false,
      @HiveField(5) this.progressUpdatedAt,
      @HiveField(6) final Map<String, dynamic> metadata = const {}})
      : _metadata = metadata;

  factory _$UserBadgeProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserBadgeProgressImplFromJson(json);

  @override
  @HiveField(0)
  final String badgeId;
  @override
  @JsonKey()
  @HiveField(1)
  final int currentProgress;
  @override
  @JsonKey()
  @HiveField(2)
  final bool isUnlocked;
  @override
  @HiveField(3)
  final DateTime? unlockedAt;
  @override
  @JsonKey()
  @HiveField(4)
  final bool isMainBadge;
// 메인 뱃지로 설정 여부
  @override
  @HiveField(5)
  final DateTime? progressUpdatedAt;
// 추가 메타데이터
  final Map<String, dynamic> _metadata;
// 추가 메타데이터
  @override
  @JsonKey()
  @HiveField(6)
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  String toString() {
    return 'UserBadgeProgress(badgeId: $badgeId, currentProgress: $currentProgress, isUnlocked: $isUnlocked, unlockedAt: $unlockedAt, isMainBadge: $isMainBadge, progressUpdatedAt: $progressUpdatedAt, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserBadgeProgressImpl &&
            (identical(other.badgeId, badgeId) || other.badgeId == badgeId) &&
            (identical(other.currentProgress, currentProgress) ||
                other.currentProgress == currentProgress) &&
            (identical(other.isUnlocked, isUnlocked) ||
                other.isUnlocked == isUnlocked) &&
            (identical(other.unlockedAt, unlockedAt) ||
                other.unlockedAt == unlockedAt) &&
            (identical(other.isMainBadge, isMainBadge) ||
                other.isMainBadge == isMainBadge) &&
            (identical(other.progressUpdatedAt, progressUpdatedAt) ||
                other.progressUpdatedAt == progressUpdatedAt) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      badgeId,
      currentProgress,
      isUnlocked,
      unlockedAt,
      isMainBadge,
      progressUpdatedAt,
      const DeepCollectionEquality().hash(_metadata));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserBadgeProgressImplCopyWith<_$UserBadgeProgressImpl> get copyWith =>
      __$$UserBadgeProgressImplCopyWithImpl<_$UserBadgeProgressImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserBadgeProgressImplToJson(
      this,
    );
  }
}

abstract class _UserBadgeProgress implements UserBadgeProgress {
  factory _UserBadgeProgress(
          {@HiveField(0) required final String badgeId,
          @HiveField(1) final int currentProgress,
          @HiveField(2) final bool isUnlocked,
          @HiveField(3) final DateTime? unlockedAt,
          @HiveField(4) final bool isMainBadge,
          @HiveField(5) final DateTime? progressUpdatedAt,
          @HiveField(6) final Map<String, dynamic> metadata}) =
      _$UserBadgeProgressImpl;

  factory _UserBadgeProgress.fromJson(Map<String, dynamic> json) =
      _$UserBadgeProgressImpl.fromJson;

  @override
  @HiveField(0)
  String get badgeId;
  @override
  @HiveField(1)
  int get currentProgress;
  @override
  @HiveField(2)
  bool get isUnlocked;
  @override
  @HiveField(3)
  DateTime? get unlockedAt;
  @override
  @HiveField(4)
  bool get isMainBadge;
  @override // 메인 뱃지로 설정 여부
  @HiveField(5)
  DateTime? get progressUpdatedAt;
  @override // 추가 메타데이터
  @HiveField(6)
  Map<String, dynamic> get metadata;
  @override
  @JsonKey(ignore: true)
  _$$UserBadgeProgressImplCopyWith<_$UserBadgeProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BadgeStats _$BadgeStatsFromJson(Map<String, dynamic> json) {
  return _BadgeStats.fromJson(json);
}

/// @nodoc
mixin _$BadgeStats {
  @HiveField(0)
  int get totalBadges => throw _privateConstructorUsedError;
  @HiveField(1)
  int get unlockedBadges => throw _privateConstructorUsedError;
  @HiveField(2)
  int get weakBadges => throw _privateConstructorUsedError;
  @HiveField(3)
  int get mediumBadges => throw _privateConstructorUsedError;
  @HiveField(4)
  int get strongBadges => throw _privateConstructorUsedError;
  @HiveField(5)
  int get hellBadges => throw _privateConstructorUsedError;
  @HiveField(6)
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BadgeStatsCopyWith<BadgeStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BadgeStatsCopyWith<$Res> {
  factory $BadgeStatsCopyWith(
          BadgeStats value, $Res Function(BadgeStats) then) =
      _$BadgeStatsCopyWithImpl<$Res, BadgeStats>;
  @useResult
  $Res call(
      {@HiveField(0) int totalBadges,
      @HiveField(1) int unlockedBadges,
      @HiveField(2) int weakBadges,
      @HiveField(3) int mediumBadges,
      @HiveField(4) int strongBadges,
      @HiveField(5) int hellBadges,
      @HiveField(6) DateTime? lastUpdated});
}

/// @nodoc
class _$BadgeStatsCopyWithImpl<$Res, $Val extends BadgeStats>
    implements $BadgeStatsCopyWith<$Res> {
  _$BadgeStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalBadges = null,
    Object? unlockedBadges = null,
    Object? weakBadges = null,
    Object? mediumBadges = null,
    Object? strongBadges = null,
    Object? hellBadges = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(_value.copyWith(
      totalBadges: null == totalBadges
          ? _value.totalBadges
          : totalBadges // ignore: cast_nullable_to_non_nullable
              as int,
      unlockedBadges: null == unlockedBadges
          ? _value.unlockedBadges
          : unlockedBadges // ignore: cast_nullable_to_non_nullable
              as int,
      weakBadges: null == weakBadges
          ? _value.weakBadges
          : weakBadges // ignore: cast_nullable_to_non_nullable
              as int,
      mediumBadges: null == mediumBadges
          ? _value.mediumBadges
          : mediumBadges // ignore: cast_nullable_to_non_nullable
              as int,
      strongBadges: null == strongBadges
          ? _value.strongBadges
          : strongBadges // ignore: cast_nullable_to_non_nullable
              as int,
      hellBadges: null == hellBadges
          ? _value.hellBadges
          : hellBadges // ignore: cast_nullable_to_non_nullable
              as int,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BadgeStatsImplCopyWith<$Res>
    implements $BadgeStatsCopyWith<$Res> {
  factory _$$BadgeStatsImplCopyWith(
          _$BadgeStatsImpl value, $Res Function(_$BadgeStatsImpl) then) =
      __$$BadgeStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) int totalBadges,
      @HiveField(1) int unlockedBadges,
      @HiveField(2) int weakBadges,
      @HiveField(3) int mediumBadges,
      @HiveField(4) int strongBadges,
      @HiveField(5) int hellBadges,
      @HiveField(6) DateTime? lastUpdated});
}

/// @nodoc
class __$$BadgeStatsImplCopyWithImpl<$Res>
    extends _$BadgeStatsCopyWithImpl<$Res, _$BadgeStatsImpl>
    implements _$$BadgeStatsImplCopyWith<$Res> {
  __$$BadgeStatsImplCopyWithImpl(
      _$BadgeStatsImpl _value, $Res Function(_$BadgeStatsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalBadges = null,
    Object? unlockedBadges = null,
    Object? weakBadges = null,
    Object? mediumBadges = null,
    Object? strongBadges = null,
    Object? hellBadges = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(_$BadgeStatsImpl(
      totalBadges: null == totalBadges
          ? _value.totalBadges
          : totalBadges // ignore: cast_nullable_to_non_nullable
              as int,
      unlockedBadges: null == unlockedBadges
          ? _value.unlockedBadges
          : unlockedBadges // ignore: cast_nullable_to_non_nullable
              as int,
      weakBadges: null == weakBadges
          ? _value.weakBadges
          : weakBadges // ignore: cast_nullable_to_non_nullable
              as int,
      mediumBadges: null == mediumBadges
          ? _value.mediumBadges
          : mediumBadges // ignore: cast_nullable_to_non_nullable
              as int,
      strongBadges: null == strongBadges
          ? _value.strongBadges
          : strongBadges // ignore: cast_nullable_to_non_nullable
              as int,
      hellBadges: null == hellBadges
          ? _value.hellBadges
          : hellBadges // ignore: cast_nullable_to_non_nullable
              as int,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BadgeStatsImpl implements _BadgeStats {
  _$BadgeStatsImpl(
      {@HiveField(0) this.totalBadges = 0,
      @HiveField(1) this.unlockedBadges = 0,
      @HiveField(2) this.weakBadges = 0,
      @HiveField(3) this.mediumBadges = 0,
      @HiveField(4) this.strongBadges = 0,
      @HiveField(5) this.hellBadges = 0,
      @HiveField(6) this.lastUpdated});

  factory _$BadgeStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$BadgeStatsImplFromJson(json);

  @override
  @JsonKey()
  @HiveField(0)
  final int totalBadges;
  @override
  @JsonKey()
  @HiveField(1)
  final int unlockedBadges;
  @override
  @JsonKey()
  @HiveField(2)
  final int weakBadges;
  @override
  @JsonKey()
  @HiveField(3)
  final int mediumBadges;
  @override
  @JsonKey()
  @HiveField(4)
  final int strongBadges;
  @override
  @JsonKey()
  @HiveField(5)
  final int hellBadges;
  @override
  @HiveField(6)
  final DateTime? lastUpdated;

  @override
  String toString() {
    return 'BadgeStats(totalBadges: $totalBadges, unlockedBadges: $unlockedBadges, weakBadges: $weakBadges, mediumBadges: $mediumBadges, strongBadges: $strongBadges, hellBadges: $hellBadges, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BadgeStatsImpl &&
            (identical(other.totalBadges, totalBadges) ||
                other.totalBadges == totalBadges) &&
            (identical(other.unlockedBadges, unlockedBadges) ||
                other.unlockedBadges == unlockedBadges) &&
            (identical(other.weakBadges, weakBadges) ||
                other.weakBadges == weakBadges) &&
            (identical(other.mediumBadges, mediumBadges) ||
                other.mediumBadges == mediumBadges) &&
            (identical(other.strongBadges, strongBadges) ||
                other.strongBadges == strongBadges) &&
            (identical(other.hellBadges, hellBadges) ||
                other.hellBadges == hellBadges) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, totalBadges, unlockedBadges,
      weakBadges, mediumBadges, strongBadges, hellBadges, lastUpdated);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BadgeStatsImplCopyWith<_$BadgeStatsImpl> get copyWith =>
      __$$BadgeStatsImplCopyWithImpl<_$BadgeStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BadgeStatsImplToJson(
      this,
    );
  }
}

abstract class _BadgeStats implements BadgeStats {
  factory _BadgeStats(
      {@HiveField(0) final int totalBadges,
      @HiveField(1) final int unlockedBadges,
      @HiveField(2) final int weakBadges,
      @HiveField(3) final int mediumBadges,
      @HiveField(4) final int strongBadges,
      @HiveField(5) final int hellBadges,
      @HiveField(6) final DateTime? lastUpdated}) = _$BadgeStatsImpl;

  factory _BadgeStats.fromJson(Map<String, dynamic> json) =
      _$BadgeStatsImpl.fromJson;

  @override
  @HiveField(0)
  int get totalBadges;
  @override
  @HiveField(1)
  int get unlockedBadges;
  @override
  @HiveField(2)
  int get weakBadges;
  @override
  @HiveField(3)
  int get mediumBadges;
  @override
  @HiveField(4)
  int get strongBadges;
  @override
  @HiveField(5)
  int get hellBadges;
  @override
  @HiveField(6)
  DateTime? get lastUpdated;
  @override
  @JsonKey(ignore: true)
  _$$BadgeStatsImplCopyWith<_$BadgeStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
