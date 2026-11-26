import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../core/widgets/standard_app_header.dart';

class VitalsTabScaffold extends StatefulWidget {
  final String title;
  final Widget recordsTab;
  final Widget chartTab;

  const VitalsTabScaffold({
    super.key,
    required this.title,
    required this.recordsTab,
    required this.chartTab,
  });

  @override
  State<VitalsTabScaffold> createState() => _VitalsTabScaffoldState();
}

class _VitalsTabScaffoldState extends State<VitalsTabScaffold>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          StandardAppHeader(
            title: widget.title,
            onBack: () => context.pop(),
          ),
          Container(
            color: theme.colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              indicatorColor: theme.colorScheme.primary,
              indicatorSize: TabBarIndicatorSize.label,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.spacingL,
              ),
              tabs: const [
                Tab(text: 'Records', icon: Icon(Icons.list, size: 18)),
                Tab(text: 'Chart', icon: Icon(Icons.show_chart, size: 18)),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                widget.recordsTab,
                widget.chartTab,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
