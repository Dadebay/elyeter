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
import '../cubit/profile_cubit.dart';
import '../widgets/about_app_dialog.dart';
import '../widgets/language_dialog.dart';
import '../widgets/profile_summary_cards.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
import '../widgets/support_call_card.dart';
import 'profile_placeholder_data.dart';

/// Account page: identity, app settings and support.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final themeMode = context.watch<ThemeCubit>().state;
    final profile = context.watch<ProfileCubit>().state;
    final locale = context.watch<LocaleCubit>().state;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.profileTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
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
          ProfileSummaryCards(
            name: profile.name,
            avatarPath: profile.avatarPath,
            editLabel: l10n.profileEditProfile,
            ordersTitle: l10n.profileAllOrders,
            ordersSubtitle: l10n.profileOrderCount(ProfilePlaceholderData.orderCount),
            onEditProfile: () => context.pushNamed(AppRoutes.editProfile.name),
            onOrders: () => context.pushNamed(AppRoutes.orders.name),
          ),
          SettingsSection(
            title: l10n.profileSectionGeneral,
            children: [
              SettingsTile(icon: AppAssets.iconBell, label: l10n.profileNotifications, onTap: () => context.pushNamed(AppRoutes.notifications.name)),
              SettingsTile(icon: AppAssets.iconCubic, label: l10n.profileActiveOrders, onTap: () => context.pushNamed(AppRoutes.orders.name)),
              SettingsTile(icon: AppAssets.iconPinLocation, label: l10n.profileSavedLocations, onTap: () => context.pushNamed(AppRoutes.addresses.name)),
              SettingsTile(icon: AppAssets.iconClock, label: l10n.profileOrderHistory, onTap: () => context.pushNamed(AppRoutes.orders.name)),
              SettingsTile(icon: AppAssets.iconNews, label: l10n.profileAnnouncements, onTap: () => context.pushNamed(AppRoutes.notifications.name)),
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
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Text(l10n.profileVersion(AppConstants.appVersion), style: context.textTheme.bodySmall?.copyWith(color: AppColors.grey500)),
          ),
        ],
      ),
    );
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

  /// Hands [url] to the platform: `tel:` opens the dialler with the support
  /// number in it, the rest open in their own app or the browser.
  ///
  /// A phone that cannot take the link — a tablet with no dialler, a missing
  /// WhatsApp — says so rather than swallowing the tap.
  Future<void> _open(BuildContext context, String url) async {
    final messenger = ScaffoldMessenger.of(context);
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

    if (!launched) {
      messenger.showSnackBar(SnackBar(content: Text(failed)));
    }
  }
}
