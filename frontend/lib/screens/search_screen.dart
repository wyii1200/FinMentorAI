import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class SearchScreen extends StatefulWidget {
  final VoidCallback onBack;
  final Function(int) onNavigate;

  const SearchScreen({
    super.key,
    required this.onBack,
    required this.onNavigate,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _recentSearches = const [
    'BNPL',
    'Savings Goal',
    'Resilience Score',
    'Spending Analyzer',
  ];

  final List<_SearchItem> _items = const [
    _SearchItem(
      icon: '🔍',
      title: 'Spending Analyzer',
      subtitle: 'Review income, expenses, and monthly allocation',
      index: 1,
      keywords: ['spending', 'analyzer', 'expenses', 'income', 'budget'],
    ),
    _SearchItem(
      icon: '📈',
      title: 'Future Simulator',
      subtitle: 'See how today’s choices affect your future finances',
      index: 2,
      keywords: ['future', 'simulator', 'projection', 'scenario', 'forecast'],
    ),
    _SearchItem(
      icon: '💳',
      title: 'BNPL Risk',
      subtitle: 'Estimate repayment pressure and debt risk',
      index: 3,
      keywords: ['bnpl', 'debt', 'loan', 'repayment', 'risk'],
    ),
    _SearchItem(
      icon: '🛡️',
      title: 'Resilience Score',
      subtitle: 'Understand your financial stability and stress readiness',
      index: 4,
      keywords: ['resilience', 'score', 'stability', 'emergency', 'buffer'],
    ),
    _SearchItem(
      icon: '💰',
      title: 'Income Overview',
      subtitle: 'Review your monthly income and cash flow health',
      index: 6,
      keywords: ['income', 'salary', 'cash flow', 'earnings'],
    ),
    _SearchItem(
      icon: '💸',
      title: 'Spending Breakdown',
      subtitle: 'See your estimated expense categories',
      index: 7,
      keywords: ['spending', 'expenses', 'breakdown', 'categories'],
    ),
    _SearchItem(
      icon: '🏦',
      title: 'Savings Goals',
      subtitle: 'Track your current savings and goal progress',
      index: 8,
      keywords: ['savings', 'goal', 'saved', 'emergency fund'],
    ),
    _SearchItem(
      icon: '🔔',
      title: 'Notifications',
      subtitle: 'View reminders, alerts, and financial tips',
      index: 9,
      keywords: ['notifications', 'alerts', 'reminders', 'tips'],
    ),
    _SearchItem(
      icon: '👤',
      title: 'Profile Settings',
      subtitle: 'Manage your account and financial profile',
      index: 10,
      keywords: ['profile', 'settings', 'account'],
    ),
  ];

  String get _query => _searchController.text.trim().toLowerCase();

  List<_SearchItem> get _filteredItems {
    if (_query.isEmpty) {
      return _items.take(4).toList();
    }

    return _items.where((item) {
      return item.title.toLowerCase().contains(_query) ||
          item.subtitle.toLowerCase().contains(_query) ||
          item.keywords.any((keyword) => keyword.contains(_query));
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredItems = _filteredItems;

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
          onPressed: widget.onBack,
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
            controller: _searchController,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search tools, insights, screens...',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textSecondary,
              ),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : const Icon(
                      Icons.auto_awesome_rounded,
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
            if (_query.isEmpty) ...[
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
                children: _recentSearches
                    .map(
                      (tag) => ActionChip(
                        label: Text(tag),
                        onPressed: () {
                          _searchController.text = tag;
                          setState(() {});
                        },
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
            ],
            Text(
              _query.isEmpty ? 'Quick Access' : 'Search Results',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            if (filteredItems.isEmpty)
              _buildEmptyState(theme)
            else
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: filteredItems.asMap().entries.map((entry) {
                    final item = entry.value;
                    final isLast = entry.key == filteredItems.length - 1;

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
                              item.icon,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                          title: Text(
                            item.title,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            item.subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.35,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          onTap: () => widget.onNavigate(item.index),
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
                      'Search helps users quickly navigate across savings, BNPL, resilience, and analysis tools in one place.',
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

  Widget _buildEmptyState(ThemeData theme) {
    return AppCard(
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.subtleInfoBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: AppColors.info,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No matches found',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching for terms like BNPL, savings, resilience, or analyzer.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchItem {
  final String icon;
  final String title;
  final String subtitle;
  final int index;
  final List<String> keywords;

  const _SearchItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.index,
    required this.keywords,
  });
}
