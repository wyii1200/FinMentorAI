import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class SearchScreen extends StatelessWidget {
  final VoidCallback onBack;
  final Function(int) onNavigate;

  const SearchScreen({
    super.key,
    required this.onBack,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final recentSearches = ['Shopee', 'Salary', 'Groceries', 'Maybank'];
    final quickLinks = [
      ('🔍', 'Spending Analyzer', 1),
      ('📈', 'Future Simulator', 2),
      ('💳', 'BNPL Risk', 3),
      ('🛡️', 'Resilience Score', 4),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppColors.textPrimary,
          ),
          onPressed: onBack,
        ),
        titleSpacing: 0,
        title: Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search transactions, tools, insights...',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textSecondary,
              ),
              suffixIcon: const Icon(
                Icons.mic_none_rounded,
                color: AppColors.textSecondary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(color: AppColors.border),
            const SizedBox(height: 20),
            Text(
              'Recent Searches',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recentSearches
                  .map(
                    (tag) => ActionChip(
                      label: Text(tag),
                      onPressed: () {},
                      backgroundColor: AppColors.surface,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      labelStyle: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Quick Access',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: quickLinks.asMap().entries.map((entry) {
                  final item = entry.value;
                  final isLast = entry.key == quickLinks.length - 1;

                  return Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            item.$1,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        title: Text(
                          item.$2,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        onTap: () => onNavigate(item.$3),
                      ),
                      if (!isLast)
                        const Divider(
                          height: 1,
                          indent: 72,
                          endIndent: 16,
                          color: AppColors.border,
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            AppCard(
              color: AppColors.subtleInfoBg,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.tips_and_updates_outlined,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Search helps users quickly find spending records, savings goals, and AI tools in one place.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.45,
                      ),
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
