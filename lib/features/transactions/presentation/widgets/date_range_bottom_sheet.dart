import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/constant/color_manager.dart';
import '../../../../core/extension/app_sizes.dart';
import '../../../../core/extension/text_style_extension.dart';
import '../../../../core/widgets/bottom_sheet_drag_handle.dart';
import '../../domain/transaction_limits.dart';
import '../utils/localized_date_format.dart';

class DateRangeBottomSheet extends HookWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final Function(DateTime start, DateTime end) onApply;

  const DateRangeBottomSheet({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final startDate = useState<DateTime>(
      initialStartDate ?? DateTime.now().subtract(const Duration(days: 7)),
    );
    final endDate = useState<DateTime>(initialEndDate ?? DateTime.now());
    final selectedPreset = useState<String?>(null);

    void updatePreset(String preset, DateTime start, DateTime end) {
      selectedPreset.value = preset;
      startDate.value = start;
      endDate.value = end;
    }

    Future<void> selectDate(BuildContext context, bool isStart) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: isStart ? startDate.value : endDate.value,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (!context.mounted) return;
      if (picked != null) {
        selectedPreset.value = null;
        if (isStart) {
          if (picked.isAfter(endDate.value)) {
            endDate.value = picked.add(const Duration(days: 1));
          }
          startDate.value = picked;
        } else {
          if (picked.isBefore(startDate.value)) {
            startDate.value = picked.subtract(const Duration(days: 1));
          }
          endDate.value = picked;
        }

        if (endDate.value.difference(startDate.value).inDays > 31) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(context.loc.rangeError)));
          if (isStart) {
            endDate.value = startDate.value.add(const Duration(days: 31));
          } else {
            startDate.value = endDate.value.subtract(const Duration(days: 31));
          }
        }
      }
    }

    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BottomSheetDragHandle(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.loc.selectDateRange,
                    style: context.headlineMedium.copyWith(
                      color: ColorManager.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ColorManager.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: ColorManager.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                context.loc.transactionsWindowNote(transactionWindowMonths),
                style: context.labelSmall.copyWith(
                  color: ColorManager.secondaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                context.loc.quickPresets,
                style: context.labelSmall.copyWith(
                  color: ColorManager.secondaryColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _PresetCard(
                    label: context.loc.thisWeek,
                    isSelected: selectedPreset.value == 'This Week',
                    onTap: () {
                      final now = DateTime.now();
                      updatePreset(
                        'This Week',
                        now.subtract(Duration(days: now.weekday - 1)),
                        now,
                      );
                    },
                  ),
                  _PresetCard(
                    label: context.loc.thisMonth,
                    isSelected: selectedPreset.value == 'This Month',
                    onTap: () {
                      final now = DateTime.now();
                      updatePreset(
                        'This Month',
                        DateTime(now.year, now.month, 1),
                        now,
                      );
                    },
                  ),
                  _PresetCard(
                    label: context.loc.lastMonth,
                    isSelected: selectedPreset.value == 'Last Month',
                    onTap: () {
                      final now = DateTime.now();
                      final lastMonth = DateTime(now.year, now.month - 1, 1);
                      updatePreset(
                        'Last Month',
                        lastMonth,
                        DateTime(now.year, now.month, 0),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                context.loc.customRange,
                style: context.labelSmall.copyWith(
                  color: ColorManager.secondaryColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      label: context.loc.startDate,
                      date: startDate.value,
                      onTap: () => selectDate(context, true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateField(
                      label: context.loc.endDate,
                      date: endDate.value,
                      onTap: () => selectDate(context, false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      startDate.value = DateTime.now().subtract(
                        const Duration(days: 7),
                      );
                      endDate.value = DateTime.now();
                      selectedPreset.value = null;
                    },
                    child: Text(
                      context.loc.reset,
                      style: context.labelMedium.copyWith(
                        color: ColorManager.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IntrinsicWidth(
                    child: ElevatedButton(
                      onPressed: () {
                        if (endDate.value.difference(startDate.value).inDays >
                            31) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(context.loc.rangeError)),
                          );
                          return;
                        }
                        onApply(startDate.value, endDate.value);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorManager.primaryBlue,
                        foregroundColor: ColorManager.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        context.loc.applyFilter,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PresetCard({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorManager.primaryBlue
              : ColorManager.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? ColorManager.primaryBlue
                : ColorManager.white.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check, color: ColorManager.white, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: context.labelMedium.copyWith(
                color: isSelected
                    ? ColorManager.white
                    : ColorManager.secondaryColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.labelSmall.copyWith(
            color: ColorManager.secondaryColor,
            fontSize: 12,
          ),
        ).padStart(4),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ColorManager.white.withValues(alpha: 0.1),
                width: 1.5,
              ),
              color: ColorManager.white.withValues(alpha: 0.02),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatLocalizedDate(context, 'dd MMM yyyy', date),
                  style: context.labelMedium.copyWith(
                    color: ColorManager.white,
                    fontSize: 16,
                  ),
                ),
                const Icon(
                  Icons.calendar_month_outlined,
                  color: ColorManager.secondaryColor,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
