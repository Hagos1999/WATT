import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_dimensions.dart';
import '../../data/models/sensor_reading.dart';
import '../../data/providers/sensor_providers.dart';
import 'widgets/energy_chart.dart';
import 'widgets/filter_chips.dart';

/// History/analytics screen with line chart and summary statistics.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(readingsHistoryProvider);
    final filter = ref.watch(dateRangeFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text(AppStrings.history),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter chips
            const FilterChips(),
            const SizedBox(height: AppDimensions.lg),

            // Content
            Expanded(
              child: historyAsync.when(
                loading: () => _buildLoadingState(),
                error: (error, stack) => _buildErrorState(context, ref, error),
                data: (readings) {
                  if (readings.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  return _buildContent(context, readings, filter);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<SensorReading> readings,
    DateRangeFilter filter,
  ) {
    // Calculate summary stats
    final totalEnergy = readings.isNotEmpty
        ? readings.last.energy - readings.first.energy
        : 0.0;
    final avgPower = readings.isNotEmpty
        ? readings.map((r) => r.power).reduce((a, b) => a + b) /
            readings.length
        : 0.0;
    final peakPower = readings.isNotEmpty
        ? readings.map((r) => r.power).reduce((a, b) => a > b ? a : b)
        : 0.0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart
          EnergyChart(readings: readings, filter: filter),
          const SizedBox(height: AppDimensions.lg),

          // Summary stats
          Text(
            'Summary',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              _SummaryCard(
                label: AppStrings.totalEnergy,
                value: '${totalEnergy.toStringAsFixed(3)} kWh',
                icon: Icons.battery_charging_full_rounded,
                color: const Color(0xFF66BB6A),
              ),
              const SizedBox(width: AppDimensions.md),
              _SummaryCard(
                label: AppStrings.avgPower,
                value: '${avgPower.toStringAsFixed(1)} W',
                icon: Icons.analytics_rounded,
                color: const Color(0xFFFFA726),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              _SummaryCard(
                label: AppStrings.peakPower,
                value: '${peakPower.toStringAsFixed(1)} W',
                icon: Icons.trending_up_rounded,
                color: const Color(0xFFEF5350),
              ),
              const SizedBox(width: AppDimensions.md),
              _SummaryCard(
                label: 'Readings',
                value: '${readings.length}',
                icon: Icons.data_usage_rounded,
                color: const Color(0xFF4FC3F7),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: AppColors.cardBg,
      highlightColor: AppColors.surfaceDark,
      child: Column(
        children: [
          Container(
            height: 280,
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.lg),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.show_chart_rounded,
              size: 48,
              color: AppColors.mutedGold,
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
          Text(
            AppStrings.noReadings,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            'Try selecting a different time range',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.offline),
          const SizedBox(height: AppDimensions.md),
          Text(
            AppStrings.connectionError,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppDimensions.lg),
          ElevatedButton.icon(
            onPressed: () => ref.invalidate(readingsHistoryProvider),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text(AppStrings.retry),
          ),
        ],
      ),
    );
  }
}

/// Small summary stat card used in the history screen.
class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
