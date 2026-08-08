import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/widgets/standard_app_header.dart';

class ManageSubscriptionScreen extends StatelessWidget {
  const ManageSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Column(
        children: [
          StandardAppHeader(
            title: 'Subscription',
            onBack: () => context.pop(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.spacingXL),
              child: Column(
                children: [
                  const SizedBox(height: AppDimens.spacingXXL),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.spacingXL),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person_outline,
                              size: 32,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppDimens.spacingL),
                          Text(
                            'Free Plan',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppDimens.spacingS),
                          Text(
                            'You are currently on the free plan with limited features.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.spacingXL),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.spacingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Free Plan Includes:',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppDimens.spacingM),
                          _PlanFeature(
                            label: 'Up to 2 family members',
                            theme: theme,
                          ),
                          const SizedBox(height: AppDimens.spacingS),
                          _PlanFeature(
                            label: 'Basic health tracking',
                            theme: theme,
                          ),
                          const SizedBox(height: AppDimens.spacingS),
                          _PlanFeature(
                            label: 'Manual backups',
                            theme: theme,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => context.push(Routes.paywall),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF7C4DFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimens.spacingL,
                        ),
                      ),
                      child: const Text('Upgrade to Premium'),
                    ),
                  ),
                  const SizedBox(height: AppDimens.spacingM),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Restoring purchases...'),
                        ),
                      );
                    },
                    child: const Text('Restore Purchases'),
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

class _PlanFeature extends StatelessWidget {
  final String label;
  final ThemeData theme;

  const _PlanFeature({
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: AppDimens.spacingM),
        Text(label, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
