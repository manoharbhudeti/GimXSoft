import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'app_empty_state.dart';

class SearchEmptyState extends StatelessWidget {
  final String searchQuery;
  final VoidCallback onClear;

  const SearchEmptyState({
    super.key,
    required this.searchQuery,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.search_off_rounded,
      iconColor: AppColors.cyan,
      title: 'No Matching Results',
      description: searchQuery.isNotEmpty
          ? 'No items matched your search query "$searchQuery". Try searching with different terms or reset your active filters.'
          : 'No items match your active filters. Try adjusting your filter parameters.',
      primaryActionLabel: 'Clear Search & Filters',
      primaryActionIcon: Icons.clear_rounded,
      onPrimaryAction: onClear,
    );
  }
}
