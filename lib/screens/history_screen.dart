import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../models/learning_record.dart';
import '../providers/history_provider.dart';
import '../providers/locale_provider.dart';
import '../widgets/clay_card.dart';
import '../widgets/clay_text_field.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';
import '../utils/app_icons.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().loadRecords();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final history = context.watch<HistoryProvider>();
    final locale = context.watch<LocaleProvider>().locale.languageCode;
    final records = history.search(_query);

    // Group by date
    final Map<String, List<LearningRecord>> grouped = {};
    for (final rec in records) {
      final key = DateFormatter.groupKey(rec.createdAt);
      grouped.putIfAbsent(key, () => []).add(rec);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l.historyTitle),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.pagePadding, vertical: 8),
              child: ClayTextField(
                controller: _searchController,
                hintText: l.historySearch,
                onChanged: (v) => setState(() => _query = v),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.textLight),
              ),
            ),

            // List
            Expanded(
              child: records.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppIcons.svg(AppIcons.camera, size: 56),
                          const SizedBox(height: 16),
                          Text(
                            l.historyEmpty,
                            style: const TextStyle(
                                fontSize: 18,
                                color: AppColors.textMedium,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(AppConstants.pagePadding),
                      children: [
                        for (final key in grouped.keys.toList()
                          ..sort((a, b) => b.compareTo(a))) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              DateFormatter.formatDate(
                                  _parseDate(key),
                                  locale: locale),
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textLight,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          ...grouped[key]!.map((rec) => _HistoryItem(
                                record: rec,
                                locale: locale,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.historyDetail,
                                  arguments: rec,
                                ),
                                onDelete: () =>
                                    _confirmDelete(context, rec, l),
                              )),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  DateTime _parseDate(String key) {
    final parts = key.split('-');
    return DateTime(
        int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  Future<void> _confirmDelete(
      BuildContext ctx, LearningRecord rec, AppLocalizations l) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (c) => AlertDialog(
        title: Text(l.historyDelete),
        content: Text(l.historyDeleteConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text(l.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: Text(l.confirm,
                  style: const TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<HistoryProvider>().deleteRecord(rec.id);
    }
  }
}

class _HistoryItem extends StatelessWidget {
  final LearningRecord record;
  final String locale;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _HistoryItem({
    required this.record,
    required this.locale,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final lastAttempt = record.quizAttempts.isNotEmpty
        ? record.quizAttempts.last
        : null;

    return Dismissible(
      key: Key(record.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: ClayCard(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Word icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: record.imagePath.isNotEmpty &&
                          File(record.imagePath).existsSync()
                      ? Image.file(
                          File(record.imagePath),
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: Text(
                            record.objectNameZh.isNotEmpty
                                ? record.objectNameZh.substring(0, 1)
                                : '?',
                            style: const TextStyle(
                                fontSize: 26, color: AppColors.textDark),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          record.objectNameZh,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          record.pinyin,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (lastAttempt != null)
                      Row(
                        children: [
                          ...List.generate(
                            3,
                            (i) => Icon(
                              i < lastAttempt.starRating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: i < lastAttempt.starRating
                                  ? AppColors.star
                                  : AppColors.textLight,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${lastAttempt.correctAnswers}/${lastAttempt.totalQuestions}',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textMedium),
                          ),
                        ],
                      )
                    else
                      Text(
                        '未測驗',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textLight),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormatter.formatTime(record.createdAt, locale: locale),
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textLight),
                  ),
                  const SizedBox(height: 4),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: AppColors.textLight),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
