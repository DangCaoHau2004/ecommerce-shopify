import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopify/widgets/setting/change_password.dart';
import 'package:shopify/widgets/setting/change_profile.dart';

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

  void _changePassword() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        return const EditPassword();
      },
    );
  }

  bool light = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Setting",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      body: Padding(
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
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
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
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
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
                  onChanged: (bool value) {
                    setState(() {
                      light = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
