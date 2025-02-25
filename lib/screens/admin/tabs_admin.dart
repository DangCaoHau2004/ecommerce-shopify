import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shopify/screens/admin/main/list_chat.dart';
import 'package:shopify/screens/admin/main/product_overview.dart';
import 'package:shopify/screens/admin/widget/product/add_product.dart';

class TabsAdminScreen extends StatefulWidget {
  const TabsAdminScreen({super.key});
  @override
  State<TabsAdminScreen> createState() => _TabsAdminScreenState();
}

class _TabsAdminScreenState extends State<TabsAdminScreen> {
  int _selectedPage = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProductOverviewScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedPage,
        onTap: (value) {
          setState(() {
            _selectedPage = value;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Product'),
          BottomNavigationBarItem(icon: Icon(Icons.redeem), label: 'Coupon'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // showModalBottomSheet(
          //   useSafeArea: true,
          //   isScrollControlled: true,
          //   context: context,
          //   builder: (context) {
          //     // return const AddProduct();
          //   },
          // );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
