import 'dart:ui';

import 'package:easy_ph/features/Profile/profile_viewModel.dart';
import 'package:easy_ph/features/Profile/widgets/profile_picture_section.dart';
import 'package:easy_ph/ui/components/theme_toggle_widget.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../state.dart';
import '../../ui/common/app_colors.dart';
import '../../ui/common/ui_helpers.dart';
import '../../ui/components/shimmers/profile_view_shimmers.dart';

class ProfileView extends StackedView<ProfileViewModel> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget builder(BuildContext context, ProfileViewModel viewModel, Widget? child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark ? kcDarkBgGradient : kcLightBgGradient,
          ),
        ),
        child: Column(
          children: [
            _GlassProfileHeader(isDark: isDark),
            Expanded(
              child: viewModel.isBusy
                  ? const ProfilePageShimmer()
                  : ValueListenableBuilder<bool>(
                      valueListenable: userLoggedIn,
                      builder: (context, isLoggedIn, _) {
                        return CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: Column(
                                children: [
                                  isLoggedIn
                                      ? ProfilePictureSection(viewModel: viewModel)
                                      : _GuestHeroCard(
                                          isDark: isDark,
                                          viewModel: viewModel,
                                        ),
                                  verticalSpaceSmall,
                                  _buildMenuSection(context, viewModel, isDark,
                                      isLoggedIn: isLoggedIn),
                                  verticalSpaceMedium,
                                  isLoggedIn
                                      ? _buildSignOutSection(
                                          context, viewModel, isDark)
                                      : _buildGuestAuthSection(
                                          context, viewModel, isDark),
                                  _buildAppVersionSection(isDark, viewModel),
                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).padding.bottom +
                                            100,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    ProfileViewModel viewModel,
    bool isDark, {
    required bool isLoggedIn,
  }) {
    final authItems = [
      _ProfileMenuItem(
        icon: Icons.local_shipping_rounded,
        label: 'My Orders',
        color: kcPrimaryColor,
        onTap: viewModel.navigateToOrders,
      ),
      _ProfileMenuItem(
        icon: Icons.location_on_rounded,
        label: 'Shipping Addresses',
        color: const Color(0xFF3B82F6),
        onTap: viewModel.navigateToShippingAddresses,
      ),
      _ProfileMenuItem(
        icon: Icons.share_rounded,
        label: 'Referrals',
        color: kcSecondaryColor,
        onTap: viewModel.navigateToReferrals,
      ),
      _ProfileMenuItem(
        icon: Icons.lock_rounded,
        label: 'Change Password',
        color: const Color(0xFF8B5CF6),
        onTap: viewModel.navigateToChangePassword,
      ),
    ];

    final genericItems = [
      _ProfileMenuItem(
        icon: Icons.support_agent_rounded,
        label: 'Support',
        color: const Color(0xFF10B981),
        onTap: viewModel.navigateToSupport,
      ),
    ];

    final items = isLoggedIn
        ? [...authItems, ...genericItems]
        : genericItems;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? kcGlassSurfaceDark : kcGlassSurfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? kcGlassBorderDark : kcGlassBorderLight,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  _buildMenuTile(context, items[i], isDark),
                  if (i < items.length - 1)
                    Divider(
                      height: 1,
                      indent: 56,
                      color: isDark
                          ? kcGlassBorderDark
                          : Colors.black.withOpacity(0.06),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context,
    _ProfileMenuItem item,
    bool isDark,
  ) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            horizontalSpaceSmall,
            Expanded(
              child: Text(
                item.label,
                style: const TextStyle(
                  fontFamily: 'HostGrotesk',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isDark ? Colors.white38 : Colors.black26,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutSection(
    BuildContext context,
    ProfileViewModel viewModel,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? kcGlassSurfaceDark : kcGlassSurfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? kcGlassBorderDark : kcGlassBorderLight,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: viewModel.onSignOut,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.logout_rounded,
                              color: Colors.orange, size: 20),
                        ),
                        horizontalSpaceSmall,
                        const Text(
                          'Sign Out',
                          style: TextStyle(
                            fontFamily: 'HostGrotesk',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  indent: 56,
                  color: isDark
                      ? kcGlassBorderDark
                      : Colors.black.withOpacity(0.06),
                ),
                InkWell(
                  onTap: viewModel.onDeleteAccount,
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.delete_forever_rounded,
                              color: Colors.red, size: 20),
                        ),
                        horizontalSpaceSmall,
                        const Text(
                          'Delete Account',
                          style: TextStyle(
                            fontFamily: 'HostGrotesk',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuestAuthSection(
    BuildContext context,
    ProfileViewModel viewModel,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? kcGlassSurfaceDark : kcGlassSurfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? kcGlassBorderDark : kcGlassBorderLight,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: viewModel.navigateToLogin,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: kcSecondaryColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.login_rounded,
                              color: kcSecondaryColor, size: 20),
                        ),
                        horizontalSpaceSmall,
                        const Text(
                          'Sign In',
                          style: TextStyle(
                            fontFamily: 'HostGrotesk',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            size: 14, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  indent: 56,
                  color: isDark
                      ? kcGlassBorderDark
                      : Colors.black.withOpacity(0.06),
                ),
                InkWell(
                  onTap: viewModel.navigateToRegister,
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: kcPrimaryColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.person_add_rounded,
                              color: kcPrimaryColor, size: 20),
                        ),
                        horizontalSpaceSmall,
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            fontFamily: 'HostGrotesk',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            size: 14, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppVersionSection(bool isDark, ProfileViewModel viewModel) {
    final versionStr = viewModel.appVersion.isNotEmpty
        ? 'Version ${viewModel.appVersion}'
        : 'Version 25.0.5 (34)';
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 4),
      child: Center(
        child: Text(
          versionStr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'HostGrotesk',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white38 : Colors.black38,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  @override
  void onViewModelReady(ProfileViewModel viewModel) {
    viewModel.getProfile();
    viewModel.loadAppVersion();
  }

  @override
  ProfileViewModel viewModelBuilder(BuildContext context) => ProfileViewModel();
}

// ── Glass app bar ─────────────────────────────────────────────────────────────

class _GlassProfileHeader extends StatelessWidget {
  final bool isDark;
  const _GlassProfileHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            right: 8,
            bottom: 12,
          ),
          decoration: BoxDecoration(
            color: isDark ? kcGlassSurfaceDark : kcGlassSurfaceLight,
            border: Border(
              bottom: BorderSide(
                color: isDark ? kcGlassBorderDark : kcGlassBorderLight,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    locator<NavigationService>().clearStackAndShow(Routes.homeView);
                  }
                },
              ),
              Expanded(
                child: Text(
                  'Profile',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'HostGrotesk',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const ThemeToggleWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Guest hero card ───────────────────────────────────────────────────────────

class _GuestHeroCard extends StatelessWidget {
  final bool isDark;
  final ProfileViewModel viewModel;
  const _GuestHeroCard({required this.isDark, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: isDark ? kcGlassSurfaceDark : kcGlassSurfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? kcGlassBorderDark : kcGlassBorderLight,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kcSecondaryColor.withOpacity(0.12),
                    border: Border.all(
                        color: kcSecondaryColor.withOpacity(0.3), width: 2),
                  ),
                  child: const Icon(Icons.person_rounded,
                      size: 40, color: kcSecondaryColor),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Welcome to EasyPower Hub',
                  style: TextStyle(
                    fontFamily: 'HostGrotesk',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sign in to access orders, addresses, referrals and more.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'HostGrotesk',
                    fontSize: 13,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _AuthButton(
                        label: 'Sign In',
                        filled: true,
                        onTap: viewModel.navigateToLogin,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _AuthButton(
                        label: 'Create Account',
                        filled: false,
                        onTap: viewModel.navigateToRegister,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;
  const _AuthButton(
      {required this.label, required this.filled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: filled ? kcSecondaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: filled
              ? null
              : Border.all(color: kcSecondaryColor.withOpacity(0.6), width: 1),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'HostGrotesk',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: filled ? Colors.white : kcSecondaryColor,
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
