import 'package:flutter/material.dart';

import '../../../../core/constant/color_manager.dart';
import '../../../../core/extension/app_sizes.dart';
import '../../../../core/extension/text_style_extension.dart';
import '../../domain/transaction_limits.dart';
import '../utils/localized_date_format.dart';

class TransactionMetadataRow extends StatelessWidget {
  final DateTime selectedDate;
  final TextEditingController notesController;
  final VoidCallback onDateTap;

  const TransactionMetadataRow({
    super.key,
    required this.selectedDate,
    required this.notesController,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InputSelector(
            label: context.loc.date,
            value: formatLocalizedDate(context, 'dd MMM, yyyy', selectedDate),
            icon: Icons.calendar_today_outlined,
            onTap: onDateTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.loc.notes,
                style: context.labelSmall.copyWith(
                  color: ColorManager.secondaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: notesController,
                style: context.labelMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 1,
                maxLength: maxNoteLength,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: context.loc.addNote,
                  hintStyle: context.labelMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface
                        .withValues(alpha: 0.3),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.onSurface
                      .withValues(alpha: 0.05),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InputSelector extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _InputSelector({
    required this.label,
    required this.value,
    required this.icon,
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
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface
                  .withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: ColorManager.secondaryColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: context.labelMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
