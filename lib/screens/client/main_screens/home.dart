import 'package:flutter/material.dart';
import 'package:shopify/utils/navigation_helper.dart';
import 'package:shopify/widgets/main_screens/home_product_list.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
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
        actions: [
          IconButton(
            onPressed: () {
              navigatorToCart(context);
            },
            icon: Icon(
              Icons.shopping_cart,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
          IconButton(
            onPressed: () {
              navigatorToChat(context);
            },
            icon: Icon(
              Icons.chat,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(
              "Discover Product",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.tune,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            ],
            bottom: TabBar(
              tabAlignment: TabAlignment.start,
              dividerColor: Colors.transparent,
              controller: _tabController,
              isScrollable: true,
              unselectedLabelColor: Theme.of(context).colorScheme.secondary,
              tabs: const [
                Tab(
                  child: Text(
                    "All Product",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    "Living Room",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    "Dining Room",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    "Bedroom",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    "Home Accents",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    "Lighting",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: const [
                HomeProductList(
                  physic: false,
                  type: "All",
                  idProductRemove: "",
                ),
                HomeProductList(
                  physic: false,
                  idProductRemove: "",
                  type: "Living Room",
                ),
                HomeProductList(
                  physic: false,
                  idProductRemove: "",
                  type: "Dining Room",
                ),
                HomeProductList(
                  physic: false,
                  idProductRemove: "",
                  type: "Bedroom",
                ),
                HomeProductList(
                  physic: false,
                  idProductRemove: "",
                  type: "Home Accent",
                ),
                HomeProductList(
                  physic: false,
                  idProductRemove: "",
                  type: "Lighting",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
