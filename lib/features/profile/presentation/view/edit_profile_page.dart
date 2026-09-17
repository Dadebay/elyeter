import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_asset_image.dart';
import '../../../../core/widgets/app_page_app_bar.dart';
import '../cubit/profile_cubit.dart';
import '../widgets/edit_profile_avatar.dart';
import '../widgets/edit_profile_field.dart';

/// Two things a customer can change about their account: the photo and the
/// display name. The phone number identifies the account, so it is shown
/// but not editable here.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  static const nameLimit = 40;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final ProfileState _initial;
  late String? _avatarPath;

  @override
  void initState() {
    super.initState();
    _initial = context.read<ProfileCubit>().state;
    _name = TextEditingController(text: _initial.name);
    _avatarPath = _initial.avatarPath;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  /// Save stays disabled until there is actually something to save.
  bool get _dirty =>
      _name.text.trim() != _initial.name || _avatarPath != _initial.avatarPath;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final phone = context.select((ProfileCubit c) => c.state.phone);

    return Scaffold(
      appBar: AppPageAppBar(title: l10n.editProfileTitle),
      body: Form(
        key: _formKey,
        // The name field validates as it is typed, so the button's enabled
        // state and the error text stay in step with each other.
        onChanged: () => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.xl,
            AppSpacing.page,
            AppSpacing.xxxl,
          ),
          children: [
            EditProfileAvatar(
              name: _name.text.isEmpty ? _initial.name : _name.text,
              imagePath: _avatarPath,
              size: 104,
              onTap: _pickPhoto,
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: TextButton(
                onPressed: _pickPhoto,
                child: Text(l10n.editProfilePhoto),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            EditProfileTextField(
              label: l10n.editProfileName,
              controller: _name,
              hint: l10n.editProfileNameHint,
              textCapitalization: TextCapitalization.words,
              maxLength: EditProfilePage.nameLimit,
              counter: l10n.editProfileNameCounter(_name.text.characters.length),
              validator: (value) => (value ?? '').trim().isEmpty
                  ? l10n.editProfileNameRequired
                  : null,
            ),
            const SizedBox(height: AppSpacing.xl),
            EditProfileField(
              label: l10n.editProfilePhone,
              note: l10n.editProfilePhoneNote,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      phone,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                  ),
                  const AppAssetImage(
                    AppAssets.iconLock,
                    width: 18,
                    height: 18,
                    color: AppColors.iconSoft,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Pinned: a two-field form should not make anyone scroll to save.
      bottomNavigationBar: _SaveBar(
        enabled: _dirty,
        label: l10n.commonSave,
        onPressed: _save,
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final l10n = context.l10n;

    final action = await showModalBottomSheet<_PhotoAction>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.editProfilePhoto,
              style: Theme.of(sheetContext).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.editProfilePhotoCamera),
              onTap: () => Navigator.pop(sheetContext, _PhotoAction.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.editProfilePhotoGallery),
              onTap: () => Navigator.pop(sheetContext, _PhotoAction.gallery),
            ),
            if (_avatarPath != null)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                ),
                title: Text(
                  l10n.editProfilePhotoRemove,
                  style: const TextStyle(color: AppColors.error),
                ),
                onTap: () => Navigator.pop(sheetContext, _PhotoAction.remove),
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
    if (action == null || !mounted) return;

    if (action == _PhotoAction.remove) {
      setState(() => _avatarPath = null);
      return;
    }

    final picked = await ImagePicker().pickImage(
      source: action == _PhotoAction.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      // The avatar is never drawn larger than ~104pt; anything beyond this
      // is bytes the phone carries for nothing.
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;
    setState(() => _avatarPath = picked.path);
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<ProfileCubit>().save(
      name: _name.text.trim(),
      avatarPath: _avatarPath,
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.editProfileSaved)));
    Navigator.of(context).pop();
  }
}

/// Bottom bar holding the save button, above the home indicator.
class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.enabled,
    required this.label,
    required this.onPressed,
  });

  final bool enabled;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.grey700 : AppColors.surfaceMuted,
          ),
        ),
      ),
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.md,
          AppSpacing.page,
          AppSpacing.md,
        ),
        child: FilledButton(
          onPressed: enabled ? onPressed : null,
          child: Text(label),
        ),
      ),
    );
  }
}

enum _PhotoAction { camera, gallery, remove }
