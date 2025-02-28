import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopify/providers/setting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingAdminScreen extends ConsumerStatefulWidget {
  const SettingAdminScreen({super.key});
  @override
  ConsumerState<SettingAdminScreen> createState() => _SettingAdminScreenState();
}

class _SettingAdminScreenState extends ConsumerState<SettingAdminScreen> {
  bool light = false;
  bool _isLoading = false;
  void _changeMode(bool value) async {
    setState(() {
      _isLoading = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setBool("darkMode", value);
    ref.read(darkMode.notifier).state = value;
    setState(() {
      _isLoading = false;
      light = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool light = ref.watch(darkMode);

    return SizedBox(
      child: Center(
        child: _isLoading
            ? const CircularProgressIndicator(
                color: Colors.orange,
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                    },
                    child: Text(
                      "Log Out",
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.onTertiary),
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Switch(
                    value: light,
                    activeColor: Colors.orange,
                    onChanged: _changeMode,
                  ),
                ],
              ),
      ),
    );
  }
}
