import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

/// The account details the customer can edit themselves.
class ProfileState extends Equatable {
  const ProfileState({this.name = '', this.phone = '', this.avatarPath});

  /// Empty, not a stand-in person: until an account is signed in and the
  /// customer has actually typed a name, there is nothing true to show, and
  /// a placeholder name reads as though someone else is signed in.
  factory ProfileState.initial() => const ProfileState();

  /// May be empty — the account only ever requires a phone number.
  final String name;

  bool get hasName => name.trim().isNotEmpty;

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

  /// Takes what the signed-in account knows about the customer: always the
  /// number, since that is the account's identity, and the name only while
  /// nothing has been typed here — an edit made locally must not be undone
  /// by the next `/auth/me`.
  void adoptAccount({required String phone, String? name}) {
    final accountName = name?.trim() ?? '';
    final nextName = state.hasName ? state.name : accountName;

    if (state.phone == phone && state.name == nextName) return;
    emit(
      ProfileState(
        name: nextName,
        phone: phone,
        avatarPath: state.avatarPath,
      ),
    );
  }

  /// Signing out must not leave the next person looking at someone else's
  /// name and photo.
  ///
  /// Named for the account rather than `clear()`, which [HydratedMixin]
  /// already defines as the way to drop the persisted record.
  void clearAccount() {
    if (state == ProfileState.initial()) return;
    emit(ProfileState.initial());
  }

  @override
  ProfileState? fromJson(Map<String, dynamic> json) => ProfileState(
    name: json['name'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    avatarPath: json['avatarPath'] as String?,
  );

  @override
  Map<String, dynamic>? toJson(ProfileState state) => {
    'name': state.name,
    'phone': state.phone,
    'avatarPath': state.avatarPath,
  };
}
