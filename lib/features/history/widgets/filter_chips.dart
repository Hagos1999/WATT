import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/providers/sensor_providers.dart';

/// Filter chips for selecting the date range on the history screen.
class FilterChips extends ConsumerWidget {
  const FilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(dateRangeFilterProvider);

    return Row(
      children: DateRangeFilter.values.map((filter) {
        final isSelected = filter == selectedFilter;
        final label = switch (filter) {
          DateRangeFilter.today => AppStrings.today,
          DateRangeFilter.last7Days => AppStrings.last7Days,
          DateRangeFilter.last30Days => AppStrings.last30Days,
        };

        return Padding(
          padding: const EdgeInsets.only(right: AppDimensions.sm),
          child: ChoiceChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (_) {
              ref.read(dateRangeFilterProvider.notifier).setFilter(filter);
            },
            backgroundColor: AppColors.surfaceDark,
            selectedColor: AppColors.gold,
            labelStyle: TextStyle(
              color: isSelected ? Colors.black : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              side: BorderSide(
                color: isSelected ? AppColors.gold : AppColors.divider,
              ),
            ),
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.md,
              vertical: AppDimensions.xs,
            ),
          ),
        );
      }).toList(),
    );
  }
}
