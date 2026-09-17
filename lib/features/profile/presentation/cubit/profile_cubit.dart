import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../view/profile_placeholder_data.dart';

/// The account details the customer can edit themselves.
class ProfileState extends Equatable {
  const ProfileState({required this.name, required this.phone, this.avatarPath});

  /// Seeded from the placeholder account until the API lands.
  factory ProfileState.initial() => const ProfileState(
    name: ProfilePlaceholderData.userName,
    phone: ProfilePlaceholderData.supportPhone,
  );

  final String name;

  /// Comes from the signed-in account; changed through verification, not here.
  final String phone;

  /// Local file path of a picked photo; null means "show initials".
  final String? avatarPath;

  @override
  List<Object?> get props => [name, phone, avatarPath];
}

/// Holds the profile and persists it, so an edit survives a restart even
/// before there is a backend to save it to.
class ProfileCubit extends HydratedCubit<ProfileState> {
  ProfileCubit() : super(ProfileState.initial());

  void save({required String name, required String? avatarPath}) => emit(
    ProfileState(name: name, phone: state.phone, avatarPath: avatarPath),
  );

  @override
  ProfileState? fromJson(Map<String, dynamic> json) => ProfileState(
    name: json['name'] as String? ?? ProfilePlaceholderData.userName,
    phone: json['phone'] as String? ?? ProfilePlaceholderData.supportPhone,
    avatarPath: json['avatarPath'] as String?,
  );

  @override
  Map<String, dynamic>? toJson(ProfileState state) => {
    'name': state.name,
    'phone': state.phone,
    'avatarPath': state.avatarPath,
  };
}
