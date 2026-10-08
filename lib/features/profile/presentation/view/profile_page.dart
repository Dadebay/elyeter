import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/cubit/locale_cubit.dart';
import '../../../../app/cubit/theme_cubit.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/media_url.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/widgets/sign_in_required_dialog.dart';
import '../cubit/profile_cubit.dart';
import '../widgets/about_app_dialog.dart';
import '../widgets/delete_account_card.dart';
import '../widgets/delete_account_dialog.dart';
import '../widgets/guest_summary_card.dart';
import '../widgets/language_dialog.dart';
import '../widgets/profile_summary_cards.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
import '../widgets/support_call_card.dart';
import 'profile_placeholder_data.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/widgets/app_snack_bar.dart';

/// Account page: identity, app settings and support.
///
/// It draws the same list in two states. Signed in, the header shows the
/// account and the page ends with a way out of it; signed out, the header
/// invites the customer in and the account-only rows ask them to sign in
/// before they open. Everything that works without an account — the
/// language, the theme, the legal pages, support — stays reachable either
/// way, so the tab is never a dead end.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      // Keeps the editable profile in step with the session: it takes the
      // account's number on sign-in and is wiped on sign-out, so the next
      // person to use the phone does not meet someone else's name.
      listenWhen: (previous, current) =>
          previous.status != current.status || previous.user != current.user,
      listener: (context, state) {
        final cubit = context.read<ProfileCubit>();
        final user = state.user;
        if (state.isAuthenticated && user != null) {
          cubit.adoptAccount(phone: user.phone, name: user.username);
        } else if (state.status == AuthStatus.unauthenticated) {
          cubit.clearAccount();
        }
      },
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final themeMode = context.watch<ThemeCubit>().state;
    final profile = context.watch<ProfileCubit>().state;
    final locale = context.watch<LocaleCubit>().state;
    final auth = context.watch<AuthCubit>().state;
    final signedIn = auth.isAuthenticated;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.sm,
          AppSpacing.page,
          // Clearance for the floating navigation bar.
          120,
        ),
        children: [
          if (signedIn)
            ProfileSummaryCards(
              // Whatever the account actually knows, in the order it is
              // worth showing: the name typed here, then the one stored on
              // the account, then the number the account is — never a
              // stand-in person.
              name: _accountName(profile, auth),
              phone: auth.user?.phone ?? profile.phone,
              avatarUrl: MediaUrl.resolve(auth.user?.image),
              avatarPath: profile.avatarPath,
              editLabel: l10n.profileEditProfile,
              ordersTitle: l10n.profileAllOrders,
              ordersSubtitle: l10n.profileOrderCount(ProfilePlaceholderData.orderCount),
              onEditProfile: () => context.pushNamed(AppRoutes.editProfile.name),
              onOrders: () => context.pushNamed(AppRoutes.orders.name),
            )
          else
            GuestSummaryCard(
              title: l10n.profileGuestTitle,
              message: l10n.profileGuestMessage,
              actionLabel: l10n.authSignIn,
              onSignIn: () => context.pushNamed(AppRoutes.login.name),
            ),
          SettingsSection(
            title: l10n.profileSectionGeneral,
            children: [
              SettingsTile(icon: AppAssets.iconBell, label: l10n.profileNotifications, onTap: () => _openAccountPage(context, signedIn, AppRoutes.notifications.name)),
              SettingsTile(icon: AppAssets.iconCubic, label: l10n.profileActiveOrders, onTap: () => _openAccountPage(context, signedIn, AppRoutes.activeOrders.name)),
              SettingsTile(icon: AppAssets.iconPinLocation, label: l10n.profileSavedLocations, onTap: () => _openAccountPage(context, signedIn, AppRoutes.addresses.name)),
              SettingsTile(icon: AppAssets.iconClock, label: l10n.profileOrderHistory, onTap: () => _openAccountPage(context, signedIn, AppRoutes.orders.name)),
              // Announcements read the same for everyone — no account needed.
              SettingsTile(icon: AppAssets.iconNews, label: l10n.profileAnnouncements, onTap: () => context.pushNamed(AppRoutes.announcements.name)),
              SettingsTile(icon: AppAssets.iconGlobe, label: l10n.settingsLanguage, trailing: TileValue(_languageLabel(context, locale)), onTap: () => _pickLanguage(context)),
              SettingsTile(
                icon: AppAssets.iconMoon,
                label: l10n.profileDarkMode,
                trailing: TileSwitch(value: _isDark(context, themeMode), onChanged: (on) => context.read<ThemeCubit>().setThemeMode(on ? ThemeMode.dark : ThemeMode.light)),
              ),
            ],
          ),
          SettingsSection(
            title: l10n.profileSectionOther,
            children: [
              SettingsTile(icon: AppAssets.iconPhone, label: l10n.profileAboutApp, onTap: () => showAboutAppDialog(context)),
              SettingsTile(icon: AppAssets.iconQuestion, label: l10n.profileFaq, onTap: () => context.pushNamed(AppRoutes.faq.name)),
              SettingsTile(icon: AppAssets.iconDocumentCheck, label: l10n.profileTerms, onTap: () => context.pushNamed(AppRoutes.terms.name)),
              SettingsTile(icon: AppAssets.iconLock, label: l10n.profilePrivacy, onTap: () => context.pushNamed(AppRoutes.privacy.name)),
            ],
          ),
          SettingsSection(
            title: l10n.profileSectionContact,
            children: [
              SettingsTile(icon: AppAssets.iconInstagram, label: l10n.profileInstagram, trailing: const TileExternal(), onTap: () => _open(context, ProfilePlaceholderData.instagramUrl)),
              SettingsTile(icon: AppAssets.iconTiktok, label: l10n.profileTiktok, trailing: const TileExternal(), onTap: () => _open(context, ProfilePlaceholderData.tiktokUrl)),
              SettingsTile(icon: AppAssets.iconWhatsapp, label: l10n.profileWhatsapp, trailing: const TileExternal(), onTap: () => _open(context, ProfilePlaceholderData.whatsappUrl)),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          SupportCallCard(
            title: l10n.profileCallTitle,
            phone: ProfilePlaceholderData.supportPhoneDisplay,
            hours: l10n.profileCallHours,
            hoursHighlight: ProfilePlaceholderData.supportHours,
            actionLabel: l10n.profileCallAction,
            onCall: () => _open(context, 'tel:${ProfilePlaceholderData.supportPhone}'),
          ),
          if (signedIn) ...[
            const SizedBox(height: AppSpacing.xl),
            DeleteAccountCard(
              label: l10n.profileDeleteAccount,
              onPressed: () => _deleteAccount(context, auth.user?.phone),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Text(l10n.profileVersion(AppConstants.appVersion), style: context.textTheme.bodySmall?.copyWith(color: AppColors.grey500)),
          ),
        ],
      ),
    );
  }

  /// What the profile card puts above "edit profile".
  ///
  /// The phone number is the account's identity and is always known, so it
  /// stands in for a name that has not been given — an empty header reads
  /// as a page that failed to load rather than as an invitation.
  String _accountName(ProfileState profile, AuthState auth) {
    if (profile.hasName) return profile.name;
    final username = auth.user?.username?.trim() ?? '';
    if (username.isNotEmpty) return username;
    return auth.user?.phone ?? profile.phone;
  }

  bool _isDark(BuildContext context, ThemeMode mode) => switch (mode) {
    ThemeMode.dark => true,
    ThemeMode.light => false,
    ThemeMode.system => MediaQuery.platformBrightnessOf(context) == Brightness.dark,
  };

  String _languageLabel(BuildContext context, Locale? locale) {
    final l10n = context.l10n;
    // Nothing picked yet: show the language actually in use, resolved from
    // the device against what the app supports.
    final code =
        locale?.languageCode ?? Localizations.localeOf(context).languageCode;
    return switch (code) {
      'tk' => l10n.settingsLanguageTurkmen,
      'ru' => l10n.settingsLanguageRussian,
      _ => l10n.settingsLanguageEnglish,
    };
  }

  Future<void> _pickLanguage(BuildContext context) async {
    final cubit = context.read<LocaleCubit>();
    final picked = await showLanguageDialog(
      context,
      current: cubit.state?.languageCode,
    );
    if (picked != null) cubit.setLanguageCode(picked);
  }

  /// Orders, addresses and notifications all describe one account, so a
  /// signed-out tap asks for the account first and then carries on to the
  /// page that was tapped.
  Future<void> _openAccountPage(
    BuildContext context,
    bool signedIn,
    String routeName,
  ) async {
    if (signedIn) {
      await context.pushNamed(routeName);
      return;
    }
    if (await promptSignIn(context) && context.mounted) {
      await context.pushNamed(routeName);
    }
  }

  /// `DELETE /auth/me`, behind the confirmation dialog that owns the request
  /// and reports its own failures. Nothing is done here on a refusal — the
  /// dialog has already said why, and the account is untouched.
  Future<void> _deleteAccount(BuildContext context, String? phone) async {
    final deleted = await showDeleteAccountDialog(
      context,
      auth: context.read<AuthCubit>(),
      phone: phone,
    );

    // The session is already gone, so the page has swapped itself back to
    // the guest header by now; this only confirms what happened.
    if (deleted && context.mounted) {
      AppSnackBar.show(context, context.l10n.profileDeleteDone, overNavBar: true);
    }
  }

  /// Hands [url] to the platform: `tel:` opens the dialler with the support
  /// number in it, the rest open in their own app or the browser.
  ///
  /// A phone that cannot take the link — a tablet with no dialler, a missing
  /// WhatsApp — says so rather than swallowing the tap.
  Future<void> _open(BuildContext context, String url) async {
    final failed = context.l10n.commonOpenFailed(url);

    var launched = false;
    try {
      launched = await launchUrl(
        Uri.parse(url),
        // The dialler and WhatsApp are separate apps; only a plain web link
        // has any business inside an in-app browser.
        mode: LaunchMode.externalApplication,
      );
    } on PlatformException {
      launched = false;
    }

    if (!launched && context.mounted) {
      AppSnackBar.show(
        context,
        failed,
        icon: AppIcons.error,
        iconColor: AppColors.error,
        overNavBar: true,
      );
    }
  }
}
