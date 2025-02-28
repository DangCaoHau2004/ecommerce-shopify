import 'package:flutter/material.dart';
import 'package:shopify/screens/client/main_screens/favorite.dart';
import 'package:shopify/screens/client/main_screens/home.dart';
import 'package:shopify/screens/client/main_screens/profile.dart';
import 'package:shopify/screens/client/main_screens/search.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});
  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedPage = 0;
  final List<Widget> _tabs = [
    const Home(),
    const FavoriteScreen(),
    const SearchScreen(),
    // const NotificationScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_selectedPage],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedPage,
        onTap: (value) {
          setState(() {
            _selectedPage = value;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Catalog'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favorite'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          // BottomNavigationBarItem(
          //     icon: Icon(Icons.notifications), label: 'Notification'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
