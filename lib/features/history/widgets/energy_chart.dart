import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/sensor_reading.dart';
import '../../../data/providers/sensor_providers.dart';

/// Line chart displaying energy (kWh) over time with gold gradient.
class EnergyChart extends StatelessWidget {
  final List<SensorReading> readings;
  final DateRangeFilter filter;

  const EnergyChart({
    super.key,
    required this.readings,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return const SizedBox.shrink();
    }

    final spots = _buildSpots();
    final minY = _getMinY();
    final maxY = _getMaxY();

    return Container(
      height: 280,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.sm,
        AppDimensions.lg,
        AppDimensions.md,
        AppDimensions.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _getGridInterval(minY, maxY),
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.divider,
              strokeWidth: 0.5,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      value.toStringAsFixed(1),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: _getBottomInterval(),
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= readings.length) {
                    return const SizedBox.shrink();
                  }
                  final dt = readings[index].createdAt;
                  final label = filter == DateRangeFilter.today
                      ? AppDateUtils.formatChartTime(dt)
                      : AppDateUtils.formatChartDay(dt);
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (readings.length - 1).toDouble(),
          minY: minY,
          maxY: maxY,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (spot) => AppColors.cardBgElevated,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final index = spot.x.toInt();
                  final reading =
                      index < readings.length ? readings[index] : null;
                  final time = reading != null
                      ? AppDateUtils.formatFull(reading.createdAt)
                      : '';
                  return LineTooltipItem(
                    '${spot.y.toStringAsFixed(3)} kWh\n$time',
                    const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
            handleBuiltInTouches: true,
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: AppColors.gold,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: readings.length < 30,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: AppColors.gold,
                    strokeWidth: 1.5,
                    strokeColor: AppColors.scaffoldBg,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.gold.withValues(alpha: 0.25),
                    AppColors.gold.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  List<FlSpot> _buildSpots() {
    return readings.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.energy);
    }).toList();
  }

  double _getMinY() {
    if (readings.isEmpty) return 0;
    final min =
        readings.map((r) => r.energy).reduce((a, b) => a < b ? a : b);
    return (min * 0.95).clamp(0, double.infinity);
  }

  double _getMaxY() {
    if (readings.isEmpty) return 1;
    final max =
        readings.map((r) => r.energy).reduce((a, b) => a > b ? a : b);
    return max * 1.05 + 0.001; // Small offset to avoid flat line at 0
  }

  double _getGridInterval(double minY, double maxY) {
    final range = maxY - minY;
    if (range <= 0) return 1;
    return (range / 4).clamp(0.001, double.infinity);
  }

  double _getBottomInterval() {
    if (readings.length <= 6) return 1;
    return (readings.length / 5).roundToDouble();
  }
}
