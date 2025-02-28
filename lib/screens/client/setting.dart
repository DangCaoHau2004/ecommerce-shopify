import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopify/providers/setting.dart';
import 'package:shopify/widgets/setting/change_password.dart';
import 'package:shopify/widgets/setting/change_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});
  @override
  ConsumerState<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
  void _changeProfile() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        return const ChangeProfile();
      },
    );
  }

  void _changePassword() async {
    final result = await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        return const EditPassword();
      },
    );
    if (result != null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$result"),
          action: SnackBarAction(label: "Ok", onPressed: () {}),
        ),
      );
    }
  }

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
    light = ref.watch(darkMode);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Setting",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        "Change Profile:",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _changeProfile,
                        child: Text(
                          "Change Profile",
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Colors.orange,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Text(
                        "Change Password:",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _changePassword,
                        child: Text(
                          "Change Password",
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Colors.orange,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Text(
                        "Dark Mode:",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      Switch(
                        value: light,
                        activeColor: Colors.orange,
                        onChanged: _changeMode,
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
