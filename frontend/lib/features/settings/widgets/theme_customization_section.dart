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
    final activeThemeMode = ref.watch(themeModeProvider);
    final themeNotifier = ref.watch(themeModeProvider.notifier);
    final activePalette = ref.watch(themePaletteProvider);
    final paletteNotifier = ref.watch(themePaletteProvider.notifier);
    final activeFontCombo = ref.watch(fontCombinationProvider);
    final fontNotifier = ref.watch(fontCombinationProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with Reset Action
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
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
                  'Personalize your gym CRM interface with curated color palettes and editorial typography combinations',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary(isDark)),
                ),
              ],
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
                      message: 'Interface theme and typography reset to default settings.',
                    );
              },
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.space20),

        // 1. Appearance Mode: Dark vs Light Mode
        GlassCard(
          padding: const EdgeInsets.all(DesignTokens.space20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.brightness_6_rounded, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Appearance Mode',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary(isDark)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Choose between high-contrast dark room aesthetics or clean daylight surfaces',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted(isDark)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildAppearanceCard(
                      title: 'Dark Mode (Recommended)',
                      subtitle: 'Obsidian void with luminous accents & reduced glare',
                      icon: Icons.dark_mode_rounded,
                      isSelected: isDark,
                      onTap: () {
                        if (!isDark) themeNotifier.setMode(ThemeMode.dark);
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildAppearanceCard(
                      title: 'Light Mode',
                      subtitle: 'Crisp porcelain slate surfaces with high daytime contrast',
                      icon: Icons.light_mode_rounded,
                      isSelected: !isDark,
                      onTap: () {
                        if (isDark) themeNotifier.setMode(ThemeMode.light);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: DesignTokens.space20),

        // 2. Color Theme Customization (4 Themes)
        GlassCard(
          padding: const EdgeInsets.all(DesignTokens.space20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.palette_outlined, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Color Palette Themes',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary(isDark)),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                    ),
                    child: Text(
                      'Active: ${activePalette.name}',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Select a signature brand palette. Buttons, indicators, cards, and backgrounds dynamically adapt.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted(isDark)),
              ),
              const SizedBox(height: 16),

              // Theme Cards Grid (2x2 on desktop)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;
                  final itemWidth = isWide ? (constraints.maxWidth - 14) / 2 : constraints.maxWidth;

                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: AppThemePalette.allPalettes.map((palette) {
                      final isSelected = activePalette.id == palette.id;
                      return SizedBox(
                        width: itemWidth,
                        child: _buildPaletteCard(
                          palette: palette,
                          isSelected: isSelected,
                          onTap: () {
                            paletteNotifier.setPalette(palette);
                            ref.read(toastProvider.notifier).success(
                                  'Theme Applied',
                                  message: '${palette.name} theme is now active globally.',
                                );
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: DesignTokens.space20),

        // 3. Typography Customization (5 Font Combinations)
        GlassCard(
          padding: const EdgeInsets.all(DesignTokens.space20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.text_fields_rounded, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Typography & Font Combinations',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary(isDark)),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                    ),
                    child: Text(
                      'Active: ${activeFontCombo.name}',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Carefully balanced display headings paired with high-legibility body typefaces.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted(isDark)),
              ),
              const SizedBox(height: 16),

              // Font Cards List
              Column(
                children: AppFontCombination.allCombinations.map((fontCombo) {
                  final isSelected = activeFontCombo.id == fontCombo.id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildFontCombinationCard(
                      fontCombo: fontCombo,
                      isSelected: isSelected,
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

        // 4. Live Component Sandbox Preview
        GlassCard(
          padding: const EdgeInsets.all(DesignTokens.space20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Live Component Sandbox Preview',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary(isDark)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Demonstrates how native buttons, cards, status pills, and fonts interact in your active configuration',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted(isDark)),
              ),
              const SizedBox(height: 16),

              Container(
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
                        Text(
                          'Titan Performance Club',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const StatusBadge(status: 'Active'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Live telemetry streaming over WhatsApp Business Platform with ${activeFontCombo.bodyFontName} body styling and ${activePalette.name} aesthetics.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
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
                          label: 'Secondary Button',
                          icon: Icons.tune_rounded,
                          variant: AppButtonVariant.secondary,
                          size: AppButtonSize.sm,
                          onPressed: () {},
                        ),
                        AppButton(
                          label: 'Outline Button',
                          icon: Icons.download_rounded,
                          variant: AppButtonVariant.outline,
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

  Widget _buildAppearanceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      child: AnimatedContainer(
        duration: DesignTokens.durationFast,
        padding: const EdgeInsets.all(DesignTokens.space16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.08)
              : AppColors.raised(isDark),
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border(isDark),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.card(isDark),
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textMuted(isDark),
                size: 22,
              ),
            ),
            const SizedBox(width: DesignTokens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(isDark),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary(isDark)),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPaletteCard({
    required AppThemePalette palette,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      child: AnimatedContainer(
        duration: DesignTokens.durationFast,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? palette.primary.withOpacity(0.08) : AppColors.raised(isDark),
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          border: Border.all(
            color: isSelected ? palette.primary : AppColors.border(isDark),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title, Palette Color Names & Checkmark
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: palette.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        palette.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: palette.primary,
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
            ),
            const SizedBox(height: 6),

            // Combination Specifier
            Text(
              '${palette.primaryColorName}  •  ${palette.backgroundColorName}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: palette.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              palette.description,
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary(isDark)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Color Swatches Bar
            Row(
              children: palette.previewSwatches.map((swatch) {
                return Expanded(
                  child: Container(
                    height: 24,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: swatch,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.black.withOpacity(0.15), width: 0.5),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),

            // Mini Mockup Preview
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: palette.background(isDark),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: palette.border(isDark)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: palette.primary, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Live Interface',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: palette.textPrimary(isDark)),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: palette.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Action',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
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

  Widget _buildFontCombinationCard({
    required AppFontCombination fontCombo,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      child: AnimatedContainer(
        duration: DesignTokens.durationFast,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.08) : AppColors.raised(isDark),
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border(isDark),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Role Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      fontCombo.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        fontCombo.categoryTag,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                if (isSelected)
                  Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
              ],
            ),
            const SizedBox(height: 4),

            Text(
              'Heading: ${fontCombo.headingFontName}  •  Body: ${fontCombo.bodyFontName}',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.primary),
            ),
            const SizedBox(height: 2),
            Text(
              fontCombo.description,
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary(isDark)),
            ),
            const SizedBox(height: 10),

            // Live Typography Preview Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.card(isDark),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border(isDark)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TITAN ATHLETICS CLUB 2026',
                    style: fontCombo.headingStyleBuilder(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(isDark),
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Automated check-ins, WhatsApp telemetry, heart rate metrics, and periodized training splits.',
                    style: fontCombo.bodyStyleBuilder(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary(isDark),
                      height: 1.3,
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
