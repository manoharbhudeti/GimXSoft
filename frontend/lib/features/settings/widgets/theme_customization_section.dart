import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/states/success/app_toast.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/theme_customization_models.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/status_badge.dart';

class ThemeCustomizationSection extends ConsumerWidget {
  final bool isDark;

  const ThemeCustomizationSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTheme = ref.watch(selectedThemeProvider);
    final themeNotifier = ref.watch(selectedThemeProvider.notifier);
    final activeFontCombo = ref.watch(fontCombinationProvider);
    final fontNotifier = ref.watch(fontCombinationProvider.notifier);

    final primaryAccent = activeTheme.palette.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with Reset Action
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.start,
          spacing: 16,
          runSpacing: 12,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme & Typography Studio',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(isDark),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Personalize your gym CRM interface with six independent theme options and five editorial typography pairings.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary(isDark)),
                  ),
                ],
              ),
            ),
            AppButton(
              label: 'Reset to Defaults',
              icon: Icons.restart_alt_rounded,
              variant: AppButtonVariant.outline,
              size: AppButtonSize.sm,
              onPressed: () async {
                await ref.resetAllCustomizations();
                ref.read(toastProvider.notifier).info(
                      'Theme Reset',
                      message: 'Interface theme and typography reset to default settings (Dark Mode & League Spartan + Inter).',
                    );
              },
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.space20),

        // 1. Independent Theme Selection (6 full-width vertical rows)
        GlassCard(
          padding: const EdgeInsets.all(DesignTokens.space20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.palette_outlined, size: 20, color: primaryAccent),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Theme Selection',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary(isDark)),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryAccent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                    ),
                    child: Text(
                      'Active: ${activeTheme.name}',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: primaryAccent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Six independent theme options. Select any theme to immediately adapt backgrounds, cards, navigation, and accents.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted(isDark)),
              ),
              const SizedBox(height: 16),

              // Theme Options: Single-Column, Full-Width Vertical Row-by-Row Layout
              Column(
                children: AppIndependentTheme.allThemes.map((theme) {
                  final isSelected = activeTheme.id == theme.id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildThemeRow(
                      context: context,
                      theme: theme,
                      isSelected: isSelected,
                      onTap: () {
                        themeNotifier.setTheme(theme);
                        ref.read(toastProvider.notifier).success(
                              'Theme Applied',
                              message: '${theme.name} is now active globally.',
                            );
                      },
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: DesignTokens.space20),

        // 2. Font Selection (5 full-width vertical rows)
        GlassCard(
          padding: const EdgeInsets.all(DesignTokens.space20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.text_fields_rounded, size: 20, color: primaryAccent),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Fonts',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary(isDark)),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryAccent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                    ),
                    child: Text(
                      'Active: ${activeFontCombo.name}',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: primaryAccent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Select typography pairing. Heading fonts establish punchy branding while body fonts ensure maximum legibility.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted(isDark)),
              ),
              const SizedBox(height: 16),

              // Font Options: Single-Column, Full-Width Vertical Row-by-Row Layout
              Column(
                children: AppFontCombination.allCombinations.map((fontCombo) {
                  final isSelected = activeFontCombo.id == fontCombo.id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildFontRow(
                      context: context,
                      fontCombo: fontCombo,
                      isSelected: isSelected,
                      primaryAccent: primaryAccent,
                      onTap: () {
                        fontNotifier.setFontCombination(fontCombo);
                        ref.read(toastProvider.notifier).success(
                              'Typography Updated',
                              message: '${fontCombo.name} font pairing is now active globally.',
                            );
                      },
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: DesignTokens.space20),

        // 3. Live Component Sandbox Preview (Renamed to Fonts Preview, excessive details removed)
        GlassCard(
          padding: const EdgeInsets.all(DesignTokens.space20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 18, color: primaryAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Fonts Preview',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary(isDark)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Live preview of ${activeFontCombo.name} typography with ${activeTheme.name} styling.',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted(isDark)),
              ),
              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.raised(isDark),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  border: Border.all(color: AppColors.border(isDark)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Titan Performance Club',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const StatusBadge(status: 'Active'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Live telemetry streaming with ${activeFontCombo.bodyFontName} styling and ${activeTheme.name} aesthetics.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        AppButton(
                          label: 'Primary Action',
                          icon: Icons.check_circle_outline_rounded,
                          variant: AppButtonVariant.primary,
                          size: AppButtonSize.sm,
                          onPressed: () {},
                        ),
                        AppButton(
                          label: 'Secondary Action',
                          icon: Icons.tune_rounded,
                          variant: AppButtonVariant.secondary,
                          size: AppButtonSize.sm,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Single Full-Width Row for Theme Option
  Widget _buildThemeRow({
    required BuildContext context,
    required AppIndependentTheme theme,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final themePrimary = theme.palette.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      child: AnimatedContainer(
        duration: DesignTokens.durationFast,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? themePrimary.withOpacity(0.08) : AppColors.raised(isDark),
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          border: Border.all(
            color: isSelected ? themePrimary : AppColors.border(isDark),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 620;

            final mainContent = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      theme.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: themePrimary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        theme.isDark ? 'Dark Base' : 'Light Base',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: themePrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${theme.primaryColorName}  •  ${theme.backgroundColorName}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: themePrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  theme.description,
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary(isDark)),
                ),
              ],
            );

            final previewSection = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Swatches Bar
                Row(
                  children: theme.previewSwatches.map((swatch) {
                    return Container(
                      width: 26,
                      height: 22,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: swatch,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.black.withOpacity(0.18), width: 0.5),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(width: 10),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: themePrimary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'ACTIVE',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
              ],
            );

            // Selection Indicator Radio
            final radioIndicator = Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? themePrimary : AppColors.textMuted(isDark),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: themePrimary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            );

            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      radioIndicator,
                      const SizedBox(width: 12),
                      Expanded(child: mainContent),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: previewSection,
                  ),
                ],
              );
            }

            return Row(
              children: [
                radioIndicator,
                const SizedBox(width: 14),
                Expanded(child: mainContent),
                const SizedBox(width: 14),
                previewSection,
              ],
            );
          },
        ),
      ),
    );
  }

  /// Single Full-Width Row for Font Combination Option
  Widget _buildFontRow({
    required BuildContext context,
    required AppFontCombination fontCombo,
    required bool isSelected,
    required Color primaryAccent,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      child: AnimatedContainer(
        duration: DesignTokens.durationFast,
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? primaryAccent.withOpacity(0.08) : AppColors.raised(isDark),
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          border: Border.all(
            color: isSelected ? primaryAccent : AppColors.border(isDark),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row Top: Radio, Title, Category Tag & Active Indicator
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Radio indicator
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? primaryAccent : AppColors.textMuted(isDark),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: primaryAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        fontCombo.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary(isDark),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: primaryAccent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          fontCombo.categoryTag,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: primaryAccent),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryAccent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'ACTIVE',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),

            // Live Typography Preview (Bolder heading, streamlined, zero excessive details)
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TITAN ATHLETICS CLUB',
                    style: fontCombo.headingStyleBuilder(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary(isDark),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Smart gym operations & workout tracking',
                    style: fontCombo.bodyStyleBuilder(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
