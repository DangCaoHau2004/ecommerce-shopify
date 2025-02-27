import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shopify/screens/admin/main/coupon_overview.dart';
import 'package:shopify/screens/admin/main/list_chat.dart';
import 'package:shopify/screens/admin/main/product_overview.dart';
import 'package:shopify/screens/admin/main/setting_admin.dart';
import 'package:shopify/screens/admin/widget/coupon/add_coupon.dart';
import 'package:shopify/screens/admin/widget/product/add_product.dart';
import 'package:shopify/screens/chat/chat.dart';

class TabsAdminScreen extends StatefulWidget {
  const TabsAdminScreen({super.key});
  @override
  State<TabsAdminScreen> createState() => _TabsAdminScreenState();
}

class _TabsAdminScreenState extends State<TabsAdminScreen> {
  int _selectedPage = 0;
  List<Widget> mainScreen = [
    const ListChatScreen(),
    const ProductOverviewScreen(),
    const CouponOverviewScreen(),
    const SettingAdminScreen()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: mainScreen[_selectedPage],
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
      floatingActionButton: _selectedPage == 0 || _selectedPage == 3
          ? null
          : FloatingActionButton(
              onPressed: () async {
                if (_selectedPage == 1) {
                  final response = await showModalBottomSheet<String>(
                    useSafeArea: true,
                    isScrollControlled: true,
                    context: context,
                    builder: (context) {
                      return const AddProduct();
                    },
                  );
                  if (response.toString().isNotEmpty) {
                    ScaffoldMessenger.of(context).clearMaterialBanners();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Success"),
                        action: SnackBarAction(
                            label: "Undo",
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection("products")
                                  .doc(response.toString())
                                  .delete();
                            }),
                      ),
                    );
                  }
                } else if (_selectedPage == 2) {
                  final response = await showModalBottomSheet(
                    useSafeArea: true,
                    isScrollControlled: true,
                    context: context,
                    builder: (context) {
                      return const AddCoupon();
                    },
                  );
                  if (response.toString().isNotEmpty) {
                    ScaffoldMessenger.of(context).clearMaterialBanners();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Success"),
                        action: SnackBarAction(
                            label: "Undo",
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection("discount_codes")
                                  .doc(response.toString())
                                  .delete();
                            }),
                      ),
                    );
                  }
                }
              },
              child: const Icon(Icons.add),
            ),
    );
  }
}
