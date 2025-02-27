import 'package:flutter/material.dart';
import 'package:shopify/widgets/status_tracking.dart';

class TabviewTrackingScreen extends StatefulWidget {
  const TabviewTrackingScreen({super.key, required this.tab});
  final int tab;
  @override
  State<TabviewTrackingScreen> createState() => _TabviewTrackingScreenState();
}

class _TabviewTrackingScreenState extends State<TabviewTrackingScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.tab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Tracking",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        bottom: TabBar(
          tabAlignment: TabAlignment.start,
          dividerColor: Colors.transparent,
          controller: _tabController,
          isScrollable: true,
          unselectedLabelColor: Theme.of(context).colorScheme.secondary,
          tabs: const [
            Tab(
              child: Text(
                "Waiting",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            Tab(
              child: Text(
                "Prepare",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            Tab(
              child: Text(
                "Send",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            Tab(
              child: Text(
                "Success",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            Tab(
              child: Text(
                "Cancellations",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                StatusTracking(
                  type: "waiting",
                ),
                StatusTracking(
                  type: "prepare",
                ),
                StatusTracking(
                  type: "send",
                ),
                StatusTracking(
                  type: "success",
                ),
                StatusTracking(
                  type: "cancle",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
