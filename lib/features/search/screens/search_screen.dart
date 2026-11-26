import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_typography.dart';

/// Global search entry point. Real cross-module search needs an aggregator
/// over all 20 record types plus documents (flagged as a data-layer concern
/// in the redesign plan, not just UI) — for now this gives the route and
/// input surface a real home; results wiring lands with the records
/// timeline in a later phase.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Material(
                    color: AppColors.surface,
                    shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => context.pop(),
                      child: const SizedBox(
                        width: 36,
                        height: 36,
                        child: Icon(Icons.arrow_back, size: 19, color: AppColors.textMuted5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.primary, width: 1.5),
                        borderRadius: BorderRadius.circular(AppDimens.radiusChip + 2),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, size: 18, color: AppColors.primary),
                          const SizedBox(width: 9),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              autofocus: true,
                              style: AppTypography.cardTitle,
                              decoration: const InputDecoration(
                                hintText: 'Search records, vitals, documents',
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    _controller.text.isEmpty
                        ? 'Search across every record, vital reading and document once you start adding them.'
                        : 'No matches yet — search wiring lands with the records timeline in a later phase.',
                    textAlign: TextAlign.center,
                    style: AppTypography.body,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
