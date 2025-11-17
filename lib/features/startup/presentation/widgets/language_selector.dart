// lib/features/startup/presentation/widgets/language_selector.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/core/localization/language_provider.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<LanguageProvider>(context);
    final isEn = provider.locale.languageCode == 'en';

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            l10n.selectLanguage ?? 'Select Language',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),

          // Chips (always centered)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LangChip(
                  label: 'English',
                  isSelected: isEn,
                  onTap: () => provider.setLocale(const Locale('en')),
                ),
                const SizedBox(width: 4),
                _LangChip(
                  label: 'Kiswahili',
                  isSelected: !isEn,
                  onTap: () => provider.setLocale(const Locale('sw')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Private chip with smooth colour transition
class _LangChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LangChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}