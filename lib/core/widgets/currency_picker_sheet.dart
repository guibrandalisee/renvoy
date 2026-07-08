import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:renvoy/l10n/app_localizations.dart';

import '../../app/theme/app_colors.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/pressable.dart';

Future<String?> showCurrencyPickerSheet({
  required BuildContext context,
  required String selected,
}) {
  final localeCurrency =
      NumberFormat.simpleCurrency(locale: Platform.localeName).currencyName ??
      'USD';
  final currencies = <String>{
    localeCurrency,
    'USD',
    'EUR',
    'BRL',
    'GBP',
    'JPY',
    'CAD',
    'AUD',
  }.toList();

  return showAppSheet<String>(
    context: context,
    title: AppLocalizations.of(context)!.currency,
    child: _CurrencyPicker(currencies: currencies, selected: selected),
  );
}

class _CurrencyPicker extends StatefulWidget {
  const _CurrencyPicker({required this.currencies, required this.selected});

  final List<String> currencies;
  final String selected;

  @override
  State<_CurrencyPicker> createState() => _CurrencyPickerState();
}

class _CurrencyPickerState extends State<_CurrencyPicker> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filtered = widget.currencies
        .where(
          (currency) => currency.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        TextField(
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.search,
            filled: true,
            fillColor: colors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colors.border),
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final currency in filtered)
          _SheetRow(
            label: currency,
            selected: currency == widget.selected,
            onPressed: () => Navigator.of(context).pop(currency),
          ),
      ],
    );
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Pressable(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: colors.textPrimary),
              ),
            ),
            if (selected) Icon(Icons.check, size: 18, color: colors.accent),
          ],
        ),
      ),
    );
  }
}
