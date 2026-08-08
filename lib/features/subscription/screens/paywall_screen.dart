import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../core/widgets/standard_app_header.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  int _selectedTier = 1; // Default to yearly

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          StandardAppHeader(
            title: 'Go Premium',
            onBack: () => context.pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.spacingXL),
              child: Column(
                children: [
                  const _PremiumBadge(),
                  const SizedBox(height: AppDimens.spacingXL),
                  Text(
                    'Unlock the Full Experience',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimens.spacingXXL),
                  const _FeatureCard(
                    icon: Icons.backup_outlined,
                    title: 'Unlimited Cloud Backups',
                    description: 'Keep your data safe with automatic backups',
                  ),
                  const SizedBox(height: AppDimens.spacingM),
                  const _FeatureCard(
                    icon: Icons.people_outline,
                    title: 'Unlimited Family Members',
                    description: 'Track health for your entire family',
                  ),
                  const SizedBox(height: AppDimens.spacingM),
                  const _FeatureCard(
                    icon: Icons.insights_outlined,
                    title: 'Advanced Analytics',
                    description: 'Detailed health trends and insights',
                  ),
                  const SizedBox(height: AppDimens.spacingM),
                  const _FeatureCard(
                    icon: Icons.attach_file_outlined,
                    title: 'Document Attachments',
                    description: 'Attach reports, prescriptions, and more',
                  ),
                  const SizedBox(height: AppDimens.spacingXXL),
                  _PricingTile(
                    title: 'Monthly',
                    price: '\$4.99',
                    period: '/month',
                    isSelected: _selectedTier == 0,
                    onTap: () => setState(() => _selectedTier = 0),
                  ),
                  const SizedBox(height: AppDimens.spacingM),
                  _PricingTile(
                    title: 'Yearly',
                    price: '\$29.99',
                    period: '/year',
                    badge: 'Save 50%',
                    isSelected: _selectedTier == 1,
                    onTap: () => setState(() => _selectedTier = 1),
                  ),
                  const SizedBox(height: AppDimens.spacingM),
                  _PricingTile(
                    title: 'Lifetime',
                    price: '\$79.99',
                    period: 'one-time',
                    badge: 'Best Value',
                    isSelected: _selectedTier == 2,
                    onTap: () => setState(() => _selectedTier = 2),
                  ),
                  const SizedBox(height: AppDimens.spacingXXL),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Purchase flow coming soon!'),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF7C4DFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimens.spacingL,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimens.radiusM),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.spacingM),
                  Text(
                    'Cancel anytime. Restore purchases available.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumBadge extends StatelessWidget {
  const _PremiumBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF7C4DFF), Color(0xFFE040FB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C4DFF).withValues(alpha:0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.workspace_premium,
        size: 48,
        color: Colors.white,
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spacingL),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF7C4DFF).withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(AppDimens.radiusS),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF7C4DFF),
              ),
            ),
            const SizedBox(width: AppDimens.spacingL),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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

class _PricingTile extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final String? badge;
  final bool isSelected;
  final VoidCallback onTap;

  const _PricingTile({
    required this.title,
    required this.price,
    required this.period,
    this.badge,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const accentColor = Color(0xFF7C4DFF);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusM),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.spacingL),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          border: Border.all(
            color: isSelected ? accentColor : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? accentColor.withValues(alpha:0.05) : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? accentColor
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppDimens.spacingL),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: AppDimens.spacingS),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.spacingS,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE040FB).withValues(alpha:0.15),
                            borderRadius:
                                BorderRadius.circular(AppDimens.radiusS),
                          ),
                          child: Text(
                            badge!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: const Color(0xFFE040FB),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? accentColor : null,
              ),
            ),
            const SizedBox(width: AppDimens.spacingXS),
            Text(
              period,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
