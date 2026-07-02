import 'package:flutter/material.dart';
import 'tu_audit_screen.dart';
import 'tu_berita_screen.dart';
import '../../../core/theme.dart';

class TuSistemTabsScreen extends StatefulWidget {
  final int initialTab;
  const TuSistemTabsScreen({super.key, this.initialTab = 0});

  @override
  State<TuSistemTabsScreen> createState() => _TuSistemTabsScreenState();
}

class _TuSistemTabsScreenState extends State<TuSistemTabsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  @override
  void didUpdateWidget(covariant TuSistemTabsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _tabController.animateTo(widget.initialTab);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.primaryColor,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.textLight,
            tabs: const [
              Tab(text: 'Audit Trail'),
              Tab(text: 'Berita Login'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          TuAuditScreen(),
          TuBeritaScreen(),
        ],
      ),
    );
  }
}
